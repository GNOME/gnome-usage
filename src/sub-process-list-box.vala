using Gee;

namespace Usage
{
     public class SubProcessListBox : Gtk.Box
        {
            private Gee.ArrayList<SubProcessSubRow> sub_rows;
            HashTable<uint, SubProcessSubRow> process_sub_rows_table;

            public SubProcessListBox()
            {
                orientation = Gtk.Orientation.VERTICAL;
                sub_rows = new Gee.ArrayList<SubProcessSubRow>();
                process_sub_rows_table = new HashTable<uint, SubProcessSubRow>(direct_hash, direct_equal);
            }

            public string get_first_name()
            {
                return sub_rows[0].get_name();
            }

            public uint get_first_pid()
            {
                return sub_rows[0].get_pid();
            }

            public int get_first_value()
            {
                return sub_rows[0].get_value();
            }

            public uint get_sub_rows_count()
            {
                return sub_rows.size;
            }

            public bool is_in_table(uint pid)
            {
                return (pid in process_sub_rows_table);
            }

            public void pre_update()
            {
                foreach(SubProcessSubRow sub_row in sub_rows)
                    sub_row.set_alive(false);
            }

            public void post_update()
            {
                sort();
                this.forall ((element) => this.remove (element)); //clear box

                foreach(unowned SubProcessSubRow sub_row in process_sub_rows_table.get_values())
                {
                    if(sub_row.get_alive() == false)
                    {
                        process_sub_rows_table.remove(sub_row.get_pid());
                        sub_rows.remove(sub_row);
                    }
                }

                for(int i = 0; i < sub_rows.size; i++)
                    if(sub_rows[i].get_alive())
                        this.add(sub_rows[i]);
            }

            public void add_sub_row(uint pid, int value, string name)
            {
                SubProcessSubRow sub_row = new SubProcessSubRow(pid, value, name);
                sub_rows.add(sub_row);
                process_sub_rows_table.insert (pid, sub_row);
            }

            public void update_sub_row(uint pid, int value)
            {
                unowned SubProcessSubRow sub_row = process_sub_rows_table[pid];
                sub_row.set_value(value);
            }

            public void remove_all()
            {
                this.forall ((element) => this.remove (element)); //clear box
                process_sub_rows_table.remove_all();
                sub_rows.clear();
            }

            public Gee.ArrayList<int> get_values()
            {
                var list = new Gee.ArrayList<int>();

                foreach(SubProcessSubRow sub_row in sub_rows)
                    list.add(sub_row.get_value());

                return list;
            }

            public int get_values_sum()
            {
                int sum = 0;

                foreach(SubProcessSubRow sub_row in sub_rows)
                    sum += sub_row.get_value();

                return sum;
            }

            private void sort()
            {
                sub_rows.sort((a, b) => {
                    return(b as SubProcessSubRow).get_value() - ( a as SubProcessSubRow).get_value();
                });
            }
        }
}
