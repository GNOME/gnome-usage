#GNOME Usage

New GNOME Usage!

## Actual TODO:
- [x] Processor Usage
- [x] Memory usage
- [x] Network usage
- [x] Add loading ProcessListBox when open app 
- [x] Show fancy clear Process Box
- [x] Tweak network usage
- [x] Add Running/Sleeping/Dead label
- [x] Support other architectures than x86_64 (netinfo precompiled library) 
- [ ] Fix bug with refreshing ProcessListBox 50% (focus, and click when refresh)
- [ ] Search in processes 
- [ ] Storage view - 1%
- [ ] Power view (Design?)
- [ ] Disk usage (What library we can use?)
- [ ] Data view - 0%

##Installation from RPM
[Download RPM](https://github.com/petr-stety-stetka/gnome-usage/releases/download/v0.3.8/gnome-usage-0.3.8-1.x86_64.rpm)

##Run
In terminal run ```gnome-usage``` command or run GNOME Usage application from app launcher.

##Version
Actual version is 0.3.8

##Notes
For correctly showing what processor core application/process use, you must have Libgtop library updated to version 2.34.2!

##Compilation from sources:
```
autovala update
mkdir build && cd build
cmake ..
make
sudo make install
sudo setcap cap_net_raw,cap_net_admin=eip /usr/local/bin/gnome-usage
```

##License
Code is under GNU GPLv3 license.

##Screenshots:
More screenshots is in screenshots subdirectory (sorry screenshots may not be current).

![Screenshot](screenshots/screenshot11.png?raw=true )

![Screenshot](screenshots/screenshot10.png?raw=true )

##Design:
<img src="https://raw.githubusercontent.com/gnome-design-team/gnome-mockups/master/usage/usage-wires.png">
