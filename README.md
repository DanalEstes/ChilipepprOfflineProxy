# ChilipepprOfflineProxy
Allow Chilipeppr to run without an Internet connection. 

## Table of Contents

- [ChilipepprOfflineProxy V0.9](#)
	- [Quick Setup (TL;DR)](#quick-setup)
	- [Usage](#usage)
	- [Installation](#installation)
	- [Todo](#todo)
	- [Contributing](#contributing)
	- [Rationale](#rationale)
	- [License](#license)


<a name="quick-setup"></a>
## Quick Setup (TL;DR)

1. Install proxy binary (and/oror source) on an Internet connected machine. 
2. Run proxy with the -offline flag, launch browser, clear browser cache, and launch chilipeppr.com/tinyg
   Expect much slower load than normal; retry if timouts or other errors. 
3. Copy the OfflineHTML directory (and the ChilipepprOffline executable) to the non Internet connected machine. 
4. Run proxy with -offline flag, lauch browser, and launch chilipeppr.com/tinyg

## Installation

1. Windows
  * a. Download the .zip file and extract ChilipepprProxy.exe.  Put it where you can find it.
  * b. Create a directory called "C:\OfflineHTML".  Other names and/or locations are acceptable by specifying a flag at runtime (see #Usage)
2. Linux
  * a. Download the PERL source.  Put it where you can find it. 
  * b. Edit the header of the source file to add the proper first line for your system.  This is usually something like **#!/usr/local/bin/perl**
3. Mac
  * Coming Soon. 
4. Other
  * Do whatever it takes to run a PERL program on your platform. 
## Usage

chilipeppr.pl -h

Chilipeppr Proxy: Command line flag -offline or -online required; all other flags optional.
  Flags are:
  -online
  -offline
  -pathprefix    Directory path used to save files when online, or serve them when offline. Read/Write access required.   Anything that works on your OS is acceptable.
  -v             Verbosity. Supplying one or more -v flags prints additional diagnostic information.
  -noauto        Supresses auto-config of Browser Proxy and clear of Browser Cache. Use only if these are causing problems.
  -noanim        Supresses backspaces used for animation of console.


## Rationale

When I discovered Chilipeppr and showed it to others, the number one question was "Will it run offline?"

## Inspiration and special thanks

### Also thanks to the many contributors:
* [contributors list](https://github.com/DanalEstes/ChilipepprOfflineProxy/graphs/contributors)

## License

See [LICENSE](LICENSE)
