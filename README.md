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

1. Install the binary or PERL source
   _[(» More details... «)](#installation)_
2. Run at least once on an Internet connected machine with -online flag. 
   _[(» More details... «)](#online)_
3. Copy all files in the OfflineHTML directory to the disconnected machine  _[(» More details... «)](#offline)_
  * a. **xxx**: 
  * b. **yyy**: More Instructions

## Installation

1. Windows
  * a. Download the .zip file and extrace ChilipepprProxy.exe.  Put it where you can find it.
  * b. Create a directory called "C:\OfflineHTML".  Other names and/or locations are acceptable by specifying a flag at runtime (see #Usage)
2. Linux
  * a. Download the PERL source.  Put it where you can find it. 
  * b. Edit the header of the source file to add the proper first line for your system.  This is usually something liek **#!/usr/local/bin/perl**
3. Mac
  * Coming Soon. 
4. Other
  * Do whatever it takes to run a PERL program on your platform. 
## Usage

## Rationale

When I discovered Chilipeppr and showed it to others, the number one question was "Will it run offline?"

## Inspiration and special thanks

### Also thanks to the many contributors:
* [contributors list](https://github.com/DanalEstes/ChilipepprOfflineProxy/graphs/contributors)

## License

See [LICENSE](LICENSE)
