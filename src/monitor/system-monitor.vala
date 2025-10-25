/* system-monitor.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
 * Copyright (C) 2025 Markus Göllnitz
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Petr Štětka <pstetka@redhat.com>
 *          Markus Göllnitz <camelcasenick@bewares.it>
 */

private enum MonitorState {
    ACTIVE,
    SLOWED,
    PAUSED;
}

[SingleInstance]
public class Usage.SystemMonitor : Object {
    public bool process_list_ready { get; private set; default = false; }
    public double cpu_load { get; private set; }
    public double[] x_cpu_load { get; private set; }
    public uint64 ram_usage { get; private set; }
    public uint64 ram_total { get; private set; }
    public uint64 swap_usage { get; private set; }
    public uint64 swap_total { get; private set; }
    public bool group_system_apps { get; set; default = true; }

    private BackgroundMonitor background_monitor;
    private CpuMonitor cpu_monitor;
    private GameModeMonitor gamemode_monitor;
    private MemoryMonitor memory_monitor;
    private ProcessMonitor process_monitor;
    public Monitor[] monitors { get; private set; }

    public HashTable<string, AppItem> app_table { get; private set; }

    private uint update_source_id = 0;
    private MonitorState state = MonitorState.PAUSED;
    private uint active_users = 0;
    private uint update_cycle = 0;

    public signal void updated (bool list_cycle);

    public List<unowned AppItem> get_apps () {
        return app_table.get_values ();
    }

    public unowned AppItem get_app_by_name (string name) {
        return app_table.@get (name);
    }

    construct {
        GTop.init ();
        AppItem.init ();

        this.background_monitor = new BackgroundMonitor (this);
        this.cpu_monitor = new CpuMonitor ();
        this.gamemode_monitor = new GameModeMonitor ();
        this.memory_monitor = new MemoryMonitor ();
        this.process_monitor = new ProcessMonitor (this);
        this.monitors = {
            this.background_monitor,
            this.cpu_monitor,
            this.gamemode_monitor,
            this.memory_monitor,
            this.process_monitor,
        };

        app_table = new HashTable<string, AppItem> (str_hash, str_equal);

        init ();
        this.notify["group-system-apps"].connect ((sender, property) => {
            init ();
        });

        this.check_update ();
        new Settings ().notify["efficiency-state"].connect (this.check_update);
        this.notify["process-list-ready"].connect (this.check_update);
    }

    private void check_update () {
        MonitorState state = this.state;
        Settings settings = new Settings ();

        switch (settings.efficiency_state) {
            case EfficiencyState.SCREEN_OFF:
                if (state != MonitorState.PAUSED) {
                    debug ("Turning off monitor as screen was locked.");
                }
                state = MonitorState.PAUSED;
                break;
            case EfficiencyState.POWER_SAVING:
                if (this.active_users == 0) {
                    if (state != MonitorState.PAUSED) {
                        debug ("Turning off monitor in power saving mode.");
                    }
                    state = MonitorState.PAUSED;
                } else {
                    state = MonitorState.ACTIVE;
                }
                break;
            case EfficiencyState.DEFAULT:
            default:
                if (this.active_users == 0 && this.process_list_ready) {
                    if (state != MonitorState.SLOWED) {
                        debug ("Slowing down as there is no active window.");
                    }
                    state = MonitorState.SLOWED;
                } else {
                    state = MonitorState.ACTIVE;
                }
                break;
        }

        if (this.state == state)
            return;

        this.state = state;

        uint interval = 0;

        switch (this.state) {
            case MonitorState.ACTIVE:
                interval = settings.data_update_interval;
                break;
            case MonitorState.SLOWED:
                interval = settings.data_update_interval_slowed;
                break;
            case MonitorState.PAUSED:
                interval = 0;
                break;
        }

        if (this.update_source_id > 0) {
            Source.remove (this.update_source_id);
            this.update_source_id = 0;
        }

        if (interval > 0) {
            if (interval % 1000 == 0) {
                this.update_source_id = Timeout.add_seconds ((uint) interval / 1000, this.update_data);
            } else {
                this.update_source_id = Timeout.add (interval, this.update_data);
            }
        }
    }

    public void activate () {
        this.active_users++;
        this.check_update ();
    }

    public void deactivate () requires (this.active_users > 0) {
        this.active_users--;
        this.check_update ();
    }

    private void init () {
        this.app_table.remove_all ();
        this.process_list_ready = false;

        if (this.group_system_apps) {
            AppItem system = new AppItem.system ();
            this.app_table.insert ("system", system);
        }

        this.process_monitor.init ();

        this.check_update ();
    }

    private bool update_data () requires (this.state != MonitorState.PAUSED) {
        foreach (Monitor monitor in this.monitors) {
            monitor.update ();
        }

        cpu_load = cpu_monitor.get_cpu_load ();
        x_cpu_load = cpu_monitor.get_x_cpu_load ();
        ram_usage = memory_monitor.get_ram_usage ();
        ram_total = memory_monitor.get_ram_total ();
        swap_usage = memory_monitor.get_swap_usage ();
        swap_total = memory_monitor.get_swap_total ();

        uint list_cycles = new Settings ().list_update_multiple;
        this.updated (this.update_cycle % list_cycles == 0);
        this.update_cycle = (this.update_cycle + 1) % list_cycles;

        this.process_list_ready = true;

        return Source.CONTINUE;
    }
}
