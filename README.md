#GNOME Usage

New GNOME Usage!

## Actual TODO:
- [x] Processor Usage
- [x] Memory usage
- [x] Network usage
- [x] Search in processes 
- [ ] Fix bug with refreshing ProcessListBox - 50% (focus, and click when refresh)
- [ ] Storage view - 75%
- [ ] Power view (Design?)
- [ ] Disk usage (What library we can use?)
- [ ] Data view - 0%

##Run
In terminal run ```gnome-usage``` command or run Usage from app launcher.

##Version
Actual version is 0.4.1

##Dependencies
- [libnetinfo >= 0.3.1](https://github.com/kaegi/netinfo-ffi)
- libgtop >= 2.34.2

##Compilation:
```
cd gnome-usage
meson build && cd build
ninja-build #or ninja
sudo ninja-build install #or sudo ninja install
sudo setcap cap_net_raw,cap_net_admin=eip /usr/local/bin/gnome-usage
```

##License
Code is under GNU GPLv3 license.

##Screenshots:
More screenshots is in screenshots subdirectory (However screenshots may not be current).

![Screenshot](screenshots/screenshot11.png?raw=true )

![Screenshot](screenshots/screenshot10.png?raw=true )

##Design:
<img src="https://raw.githubusercontent.com/gnome-design-team/gnome-mockups/master/usage/usage-wires.png">
