#GNOME Usage

New GNOME Usage!

## Actual TODO:
- [x] Processor Usage
- [x] Memory usage
- [x] Network usage
- [ ] Tweak network usage
- [x] RPM packages
- [ ] DEB packages
- [ ] Show fancy clear Process Box
- [ ] Storage view - 0%
- [ ] Power view (Design?)
- [ ] Disk usage (What library we can use?)
- [ ] Data view - 0%

##Installation from RPM
[Download RPM](https://github.com/petr-stety-stetka/gnome-usage/raw/master/rpmbuild/RPMS/x86_64/gnome-usage-0.3.2-1.x86_64.rpm)

##Run
In terminal run ```gnome-usage``` command or run GNOME Usage application from app launcher.

##Version
Actual version is 0.3.2

##Compilation from sources:
```
autovala update
cd build
cmake ..
make
sudo make install
sudo setcap cap_net_raw,cap_net_admin=eip /usr/local/bin/gnome-usage
```

##Building RPMs:
```
TODO
```

##License
Code is under GNU GPLv3 license.

##Screenshots:
More screenshots is in screenshots subdirectory. (Sorry screenshot are)

![Screenshot](screenshots/screenshot9.png?raw=true )

![Screenshot](screenshots/screenshot4.png?raw=true )

##Design:
<img src="https://raw.githubusercontent.com/gnome-design-team/gnome-mockups/master/usage/usage-wires.png">
