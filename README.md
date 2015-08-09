# ChilipepprOfflineProxy
Allow Chilipeppr to run without an Internet connection. 

## Table of Contents

- [ChilipepprOfflineProxy V0.9](#)
	- [Quick Setup (TL;DR)](#quick-setup)
	- [Usage](#usage)
	- [Installation](#installation)
	- [Rationale](#rationale)
	- [Todo](#todo)
	- [Contributing](#contributing)
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
3. Mac OSX
  * Coming Soon. If you already know how to run PERL programs from the command line on your Mac, go for it! 
4. Other
  * Do whatever it takes to run a PERL program on your platform.

## Usage

```
chilipeppr.pl -h  
Chilipeppr Proxy: Command line flag -offline or -online required; all other flags optional.  
Flags are:  
  -online
  -offline  
  -pathprefix=   Directory path used to save files when online, or serve them when offline. Read/Write access required.   Anything that works on your OS is acceptable. 
  -proxyport=    Port number that goes in browser proxy config. 
  -v             Verbosity. Supplying one or more -v flags prints additional diagnostic information.  
  -noauto        Supresses auto-config of Browser Proxy and clear of Browser Cache. Use only if these are causing problems.  
  -noanim        Supresses backspaces used for animation of console.  
```
Flags explained:  

1. **-online**  
Requests are fetched from the Internet AND stored in local files for later use.  
2. **-offline**  
Requests are fetched from local files only.  If a file cannot be found, a 404 "Not Found" HTML page is returned.  
1. **-pathprefix=**  
The location where files will be created and stored or fetched.  
  * Read/Write access requried for -online mode.  Also must be able to create new directories and new files.  
  * Read access is find for -offline mode.  
  * Default is "/OfflineHTML"  
1. **-noauto**  
  * When running on Windows, an attempt is made to auto-confiure the Windows proxy settings. These are the same settings controlled by the "Lan Settings" dialog in Internet Explorer. These tend to affect **all** clients on Windows, so it is a good idea to not run much else when capturing the online session.  
  * The proxy attempts to put activate this configuration when starting, and remove it when cleanly stopping.  If the proxy crashes, it may be easist to re-start it, and cleanly stop it (Ctl-C) to turn these settings off. You can also use the dialog in Internet Explorer, or you can click start and type "Configure Proxy Server" and press enter.  
  * Other platforms: Configure your proxy as appropriate. 
  * Default configuration is an IP address of "127.0.0.1" in the hostname field, and "8888" in the port number field. 
1. **-proxyport=**
  * This is the port the browser should use in proxy settings.  Default is 8888.
1. **-noanim**  
  * Some parts of the console interface use backspaces (\b) to overtype, and therefore animiate.  Specifying this flag supresses all use of backspaces (and therefore all animation).  Useful if redirecting STDOUT and/or STDERR to a file. 

## Rationale
When I discovered Chilipeppr and showed it to others, the number one question was "Will it run offline?"

## Thanks to the contributors:
* [Contributors list](https://github.com/DanalEstes/ChilipepprOfflineProxy/graphs/contributors)

## ToDo
* Allow both -online and -offline to be specified.  -offline will cause the proxy to service requests from content in local files, just like normal. Additionally specifying the -online flag will direct the proxy to attempt an online fetch if the local file is not found.  Useful for "fill in the gaps". 

##Contributing
Contact me to join the project, and/or clone and create a pull request when you are ready. 

## License

See [LICENSE](LICENSE)
