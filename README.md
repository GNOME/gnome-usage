#GNOME Usage

A nice way to view information about use of system resources, like memory and disk space.

## Actual TODO:
- [x] Processor Usage
- [x] Memory usage
- [x] Network usage
- [x] Search in processes 
- [ ] UI for file operations errors (as duplicate file, not enough space, permission...)
- [ ] UI for show progress about file operations
- [ ] Notification for file operations with undo action
- [ ] Storage support for more users (multiuser system)
- [ ] Application in storage 
- [ ] Power view (Design?)
- [ ] Disk usage (What library we can use?)
- [ ] Data view - 0%

##Run
In terminal run ```gnome-usage``` command or run Usage from app launcher.

##Dependencies
- libgtop >= 2.34.2

##Compilation:
```
cd gnome-usage
meson build && cd build
ninja-build #or ninja
sudo ninja-build install #or sudo ninja install
```

##License
Code is under GNU GPLv3 license.

##Screenshots:
More screenshots is in screenshots subdirectory (However screenshots may not be current).

![Screenshot](screenshots/screenshot11.png?raw=true )

![Screenshot](screenshots/screenshot10.png?raw=true )

##Design:
<img src="https://raw.githubusercontent.com/gnome-design-team/gnome-mockups/master/usage/usage-wires.png">
