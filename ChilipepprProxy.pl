# PERL program to allow chilipeppr to run offline.
#
# Copyright 2015 by danal.estes@gmail.com; all rights reserved.
# Distributed under the MIT license.

# Make animation print statements work, by asking for no buffering.
select(STDERR);
$| = 1;
select(STDOUT);
$| = 1;

# Instantiate dependencies and class objects
use strict;
use warnings;
use LWP 5.64;
my $browser = LWP::UserAgent->new;
$browser->agent('Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36');
use IO::Socket::INET;
use IO::Select;
my $IOselect = IO::Select->new();
use File::Path;
use Time::HiRes qw(gettimeofday tv_interval);
use Data::Dumper;
use Data::Hexdumper qw(hexdump);
use Carp;

# Globals
my $online         = 0;
my $ofline         = 0;
my $animCounter    = 0;
my $animchars      = '\|/-';
my $browserSockets = '';
my $browserSocket  = '';
my $peerSocket     = '';
my $getURL         = '';
my $getHostName    = '';
my $getPort        = '';
my $getPath        = '';
my $getQuer        = '';
my $getFrag        = '';
my $request        = '';
my $localPort      = abs(int(rand((65535 - 5001) + 1) + 5001));
my $response       = '';
my $respHeaders    = '';
my $respBody       = '';
my $code           = '';
my $tranChunked    = 1;
my $reqlen         = 0;                                           # Request Length (this is not parsed or checked, so it is 'total'; in the real world, requests don't have bodies, so defacto this is just headers, no body;)
my $resplen        = 0;                                           # Body    Length                 (response)
my $TCPbufCounter  = 0;
my $M404file       = 'M404.html';
my $autoconfig     = '';                                          # See commandLineArgs() for default value.
my $anim           = '';                                          # See commandLineArgs() for default value.
my $proxyPort      = '';                                          # See commandLineArgs() for default value.
my $verbosity      = '';                                          # See commandLineArgs() for default value.
my $pathPrefix     = '';                                          # See commandLineArgs() for default value.
my $fileName       = '';
my $pathName       = '';

# Other Startup
commandLineArgs();
makeNotFoundFile();
enableProxy();
openListenSocket();

print "\n";
print "Chilipeppr Proxy: Session start. Initial internet facing port: $localPort\n" if ($online);
print "Chilipeppr Proxy: Waiting for new browser connections on port: $proxyPort\n";
print "\n";

#####################################################################################################
# Loop ##############################################################################################
#####################################################################################################
while (1)
{
    next if (!receiveProxyRequest());
    if ($request =~ /^GET /i)
    {
        parseRequestURL();
        URLtoFileName();
        fixupFileName();

        if ($online)
        {
            removeRequestCacheHeaders();
            createLWPrequestHeaders();
            getResponseFromInternet();
            removeResponseClientHeaders();
            fixupResponseOnline();
            sendResponseToBrowser();
            sendResponseToFile();
        }    # End of online get from server, send to browser, and write to file.
        else
        {
            getResponseFromFile();
            fixupResponseOffline();
            sendResponseToBrowser();
        }    # End of offline read from file and send to browser.
        printQueryFini();
    }    # GET Request
}    # While forever loop

# End   of Main #################################################################################################################################
# Start of Subs #################################################################################################################################

sub receiveProxyRequest
{
    print substr($animchars, $animCounter++ % 4, 1) if ($anim);
    $browserSocket = $browserSockets->accept();
    print "\b"              if ($anim);
    return 0                if (not defined $browserSocket);
    print " \b \b \b \b \b" if ($anim);                        # Don't know why this is required to make animation work, even with STDOUT->autoflush(1);
    $browserSocket->recv($request, 65535);
    return 1;
}

sub parseRequestURL
{
    my $rc;
    $rc = $request =~ m"GET\s+(?<getURL>.*?)\s"i;
    warn "\nFailed to parse request URL from GET request header\n" unless $rc;
    $getURL = $+{'getURL'};
    $rc     = $getURL =~ m"(?=[^&])(?:(?<scheme>[^:/?#]+):)?(?://)?(?<authority>[^/?#]*)?(?<path>[^?#]*)(?:\?(?<query>[^#]*))?(?:#(?<fragment>.*))?";
    warn "\nFailed to parse GET request URL into component pieces\n" unless $rc;
    $getHostName = $+{'authority'};
    $getPort     = $+{'port'} if $getHostName =~ s"(\S+):(?<port>\d+)"$1";
    $getPort     = 80 unless $getPort;
    $getPath     = $+{'path'};
    $getQuer     = $+{'query'};
    $getQuer     = '' unless $getQuer;
    $getFrag     = $+{'fragment'};
    $getFrag     = '' unless $getFrag;

    printf '|%-25.25s|%s|%-25.25s|', $getHostName, $getPort, $getPath;

    if ($verbosity > 1)
    {
        print "\n";
        print "Request: |$getHostName|$getPort|$getPath|$getQuer|$getFrag|";
        print "\n";
    }

}

sub createLWPrequestHeaders
{
    return;

    # Make an object to hold the headers for the outgoing request
    my $h = HTTP::Headers->new();
    $h->clear();    # Just in case, since we are looping.
    $browser->default_headers($h);

    #Request from browser: Break into headers v body.
    my $rc = $request =~ m"^(?<reqHeaders>.*?\n)\n(?<reqBody>.*)"s;
    warn "\nFailed to parse Request headers\n" unless $rc;
    my $rh = $+{'reqHeaders'};

    my @reqHeaders = split /^/, $rh;
    $rh =~ s@\s*GET\s+.+$@@img;
    foreach my $reqHeader (@reqHeaders)
    {
        #print "$reqHeader";
        $reqHeader =~ /(.+):(.+)/;

        #print "|$1|$2|\n\n";
        $h->push_header($1 => $2);
    }
    $browser->default_headers($h);
}

sub removeRequestCacheHeaders
{
    if ($verbosity > 3)
    {
        print "\nbefore\n";
        $request =~ s/cookie.+\n//isg;    # Remove Cookies for printing
        print $request;
        print hexdump($request) if ($verbosity > 4);
        print "\n\n";
    }

    $request =~ s@\s*Cache-Control:.+$@@im;
    $request =~ s@\s*If-Modified-Since:.+$@@im;
    $request =~ s@\s*If-Unmodified-Since:.+$@@im;
    $request =~ s@\s*If-Match:.+$@@im;
    $request =~ s@\s*If-None-Match:.+$@@im;
    $request =~ s@\s*If-Range:.+$@@im;
    $request =~ s@\s*Only-If-Cached:.+$@@im;
    $request =~ s@^\s*Accept-Encoding:.+$@Accept-Encoding: identity@im;

    if ($verbosity > 3)
    {
        print "\nafter\n";
        $request =~ s/cookie.+\n//isg;    # Remove Cookies for printing
        print $request;
        print "\n\n";
    }
}

sub getResponseFromInternet
{
    my $t0 = [gettimeofday];
    $response = $browser->get($getURL);
    if ($response->is_error)
    {
        my $response2 = $browser->get($getURL . '.js');
        if ($response2->is_success)
        {
            print "|auto js|";
            $getURL   = $getURL . '.js';
            $response = $response2;
        }
        else
        {
            carp "Can't get $getURL\nResponse: " . ($response->status_line) . "\nRepsonse: " . ($response2->status_line) . " when .js is appended.\n";
        }
    }
    printf '|code=%3d|', $response->code;
    printf 'web t=%07.4f|', tv_interval($t0, [gettimeofday]);
}

sub getResponseFromFile
{
    openFileR($pathName . '/' . $fileName);
    local $/ = undef;
    $response = <IN>;
    close IN;

    my $rc = $response =~ m"HTTP/1.1\s+(?<code>\d\d\d)\s";
    warn "\nFailed to parse response code\n" unless $rc;
    $code = $+{'code'};
    printf '|code=%3d|', $code;

    $resplen = length $response;
    printf 'len=%6.6s|', $resplen;
}

sub removeResponseClientHeaders
{
    $response->remove_header('Client-Date');            # Remove headers inserted by LWP
    $response->remove_header('Client-Peer');            # Remove headers inserted by LWP
    $response->remove_header('Client-Response-Num');    # Remove headers inserted by LWP
}

sub sendResponseToBrowser
{
    my $t0 = [gettimeofday];
    my $r = $online ? $response->as_string : $response;
    printf 'len=%6.6s|', length $r;
    $browserSocket->send($r);
    $browserSocket->close();
    printf 'browser t=%07.4f|', tv_interval($t0, [gettimeofday]);

}

sub sendResponseToFile
{
    my $t0 = [gettimeofday];
    mkpath($pathName);
    my $pf = $pathName . '/' . $fileName;
    open(OUT, '>', $pf) or carp "Could not open output file $pf $!";
    binmode OUT;
    print OUT $response->as_string;
    close OUT or carp "Could not close $pathName/$fileName $!";
    printf 'file t=%07.4f|', tv_interval($t0, [gettimeofday]);

}

sub URLtoFileName
{
    #build an absolute pathName and fileName.  Use a prefix, then the hostname, for first part of path.
    $pathName = $pathPrefix . '/' . $getHostName . '/' . $getPath;
    $pathName =~ s@//@/@g;    #Strip double slash
    $pathName =~ s@/$@@;      #Strip trailing slash

    $fileName = 'index.html';
    my ($lastNode) = $getPath =~ m@.*\/(.*?)$@;    #Find last node after last slash
    if ($lastNode =~ m@(?:\.js$)|(?:\.html$)|(?:\.css$)@ix)    # If there is a file extension, honor it
    {
        $fileName = $lastNode;
        $pathName =~ s@(.*\/)(.*?)$@$1@;
    }
    if (($pathName =~ m@(?:\/js\/|jquery)@) && (!($fileName =~ /\.js$/)))    # Is this a javascript file without the .js extension?
    {
        $fileName = $lastNode . '.js';
        $pathName =~ s@(.*\/)(.*?)$@$1@;
    }

    if ($verbosity > 2)
    {
        print "|pathName = $pathName|";
        print "|filename = $fileName|";
    }
    return;
}

sub printQueryFini
{
    #Special case for "jsfiddle" calls: Show the jsfiddle unique name as the query.
    $getQuer = $+{'cpname'} if ($request =~ m"geturl.+?/.+?(?<cpname>/.+?)/show/light"i);

    printf '%-40.40s', $getQuer;
    print "\n";
}

# Fixups ########################################################################################################################################
# MAINTENANCE NOTE:  If Chilipeppr code changes, that might necessitate changes to these fixups.
# DESIGN NOTE: The content of files stored for later use is never changed; all fixups occur on the fly.

sub fixupResponseOffline
{
    # Chilipeppr uses two approaches to loading fiddles.  Change the actual 'if' statement in app.js to force the one that works for files.
    $response =~ s/window.location.origin.indexOf\("fiddle.jshell.net"\) != -1/1/i if ($pathName =~ m@www.chilipeppr.com.js.app.js@);

    # Cross-site security tends to break file responses.  Remove it.
    # First, Change the call; make the jsonp call into a simple json call, because a static file cannot match the dynamic key in a jsonp request/response.
    $response =~ s/&callback=\?//im if ($getURL =~ /2H9us/);

    # Second, respond as though the original call was asking for json, not jsonp
    if ($getURL =~ /dataget/)
    {
        # Provide an Allow Origin header to make getJSON happy
        #$response =~ s@^(.*)(\r\n|\n{2,})@$1\nAccess-Control-Allow-Origin: http://chilipeppr.com \n\n@is;

        # And make the internals of the file being fetched into simple json as well.
        $response =~ s@jQuery.*\({@{@sm;
        $response =~ s@}\);@}@;
    }
}

sub fixupResponseOnline
{
    if ($getURL =~ /dataget/)
    {
        # Provide an Allow Origin header to make getJSON happy
        $response->push_header('Access-Control-Allow-Origin' => 'http://chilipeppr.com');
    }
}

sub fixupFileName
{
    # For chilipeppr.com/geturl?url=blah requests, extract and parse the ?url=blah url to derive filenames.
    # This avoids overlaying multiple requests into a single "www.chilipeppr.com/geturl/index.html" file.
    my $geturlURL = $+{'url'} if ($request =~ m"geturl\?url=(?<url>\S+)"im);
    if ($geturlURL)
    {
        my $rc = $geturlURL =~ m"(?=[^&])(?:(?<scheme>[^:/?#]+):)?(?://)?(?<authority>[^/?#]*)?(?<path>[^?#]*)(?:\?(?<query>[^#]*))?(?:#(?<fragment>.*))?";
        warn "\nFailed to parse GET request special geturl\?url= sub URL into component pieces\n" unless $rc;
        $pathName = $pathPrefix . '/' . $+{'authority'} . '/' . $+{'path'};
        $fileName = 'index.html';
    }

    # For 'dataget' and 'datagetall' requests, change filenames to the name in the key.
    # Example: GET http://www.chilipeppr.com/dataget?key=userUrl:tinyg HTTP/1.1
    my $datagetURL = $+{'url'} if ($request =~ m"dataget\?key=userUrl:(?<url>.+?)(\&|\s)"i);
    if ($datagetURL)
    {
        $pathName = $pathPrefix . '/' . $getHostName . '/' . $getPath . '/' . $datagetURL;
        $fileName = 'index.html';
    }
}

sub openFileR
{
    my $pf = shift;
    if (-e $pf)
    {
        open(IN, '<', $pf) or print " $pf $! ";
    }
    else
    {
        open(IN, '<', $M404file) or print " $pf $! ";
    }
    binmode IN;
}

# One Shot Subs; mostly startup.  ########################################################################

sub commandLineArgs
{

    # Defaults if not supplied
    # $online and $ofline do not have defaults; they must be supplied.
    $proxyPort  = 8888;
    $pathPrefix = '/OfflineHTML';
    $verbosity  = 1;
    $autoconfig = 1;
    $anim       = 1;

    foreach my $arg (@ARGV)
    {
        print "\n$arg\n";
        $online     = 1  if $arg =~ /^-online$/i;
        $ofline     = 1  if $arg =~ /^-offline$/i;
        $proxyPort  = $1 if (($arg =~ /^-proxyport=(.+)$/i));
        $pathPrefix = $1 if (($arg =~ /^-pathprefix=(.+)$/i));
        $verbosity++ if (($arg =~ /^-v$/i));
        $autoconfig = 0 if (($arg =~ /^-noauto$/i));
        $anim       = 0 if (($arg =~ /^-noanim$/i));
        usage() if (($arg =~ /^-h$/i));
    }

    if (!($online || $ofline))
    {
        print "Chilipeppr Proxy: Must specify either -online or -offline command line flag. \n";
        print "\n";
        exit 8;
    }
    else
    {
        print "\n";
        print "Chilipeppr Proxy : -pathprefix = \"$pathPrefix\" (used for " . ($online ? "Writing" : "Reading") . " files).\n";
        print "Chilipeppr Proxy: -port=$proxyPort  (configure browser to IP=127.0.0.1 and Port=$proxyPort).\n";
        print "Chilipeppr Proxy: -v verbosity set for level $verbosity.\n";
        print "Chilipeppr Proxy: ONLINE: Fetching files from the Internet and saving to local storage"                                                   if ($online    && (!$ofline));
        print "Chilipeppr Proxy: OFFLINE: Serving files from local storage"                                                                              if ((!$online) && $ofline);
        print "Chilipeppr Proxy: OFFLINE: Serving files from local storage & will attempt to fetch any missing files form the Internet (and save them)." if ($online    && $ofline);
        print "\n";
    }
}

sub enableProxy
{
    if ($autoconfig && $^O =~ /MSwin/i)
    {
        print "Auto-configuring Microsoft Windows Browser Proxy for host 127.0.0.1 and port $proxyPort.\n";
        print " Note: Exiting  via \'Ctl-C\' will properly remove this setting\n";
        print " Note: If Chilipeppr Proxy crashes, you may wish to restart it and cleanly exit via Ctl-C (to auto-remove proxy).\n";
        `reg add \"HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\" /v ProxyServer /t REG_SZ /d 127.0.0.1:$proxyPort /f`;
        `reg add \"HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\" /v ProxyOverride /t REG_SZ /d  "<local>" /f`;
        `reg add \"HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\" /v ProxyEnable /t REG_DWORD /d 1 /f`;


        my $INTERNET_OPTION_REFRESH          = 95;
        my $INTERNET_OPTION_SETTINGS_CHANGED = 37;
        use Win32::API::Prototype;
        ApiLink('wininet.dll', 'BOOL InternetSetOption(LPVOID hInternet, DWORD dwOption, LPVOID lpBuffer, DWORD dwBufferLength)');
        InternetSetOption(0, $INTERNET_OPTION_REFRESH,          0, 0);
        InternetSetOption(0, $INTERNET_OPTION_SETTINGS_CHANGED, 0, 0);
    }
    else
    {
        print "\nPlease set your browser proxy configuration for host 127.0.0.1 and port $proxyPort\n";
    }

    # And turn it off if we exit via Ctl-C
    $SIG{INT} = \&sigintHandler;
}

sub sigintHandler
{
    print "\n\nChilipeppr Proxy: Exiting.\n\n";
    if ($autoconfig && $^O =~ /MSwin/i)
    {
        print "Auto-configuring Microsoft Windows Browser Proxy for no proxy. \n";
        `reg add \"HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\" /v ProxyEnable /t REG_DWORD /d 0 /f`;

        my $INTERNET_OPTION_REFRESH          = 95;
        my $INTERNET_OPTION_SETTINGS_CHANGED = 37;
        InternetSetOption(0, $INTERNET_OPTION_REFRESH,          0, 0);
        InternetSetOption(0, $INTERNET_OPTION_SETTINGS_CHANGED, 0, 0);
    }
    else
    {
        print "\nPlease set your browser proxy configuration for no proxy. \n";
    }
    $browserSockets->close();
    sleep 1;
    print "\n\nChilipeppr Proxy: bye bye and Thanks for all the fish!\n\n";
    exit 0;
}

sub makeNotFoundFile
{
    # Prepare a "not found" response file for later use.
    $M404file = $pathPrefix . '/' . $M404file;
    open(OUT, '>', $M404file);
    print OUT '
HTTP/1.1 404 Not Found
Cache-Control	no-cache
Expires	Sat, 01 Aug 2099 12:34:56 GMT
Content-Type	text/html
Content-Encoding identity 

Chilipeppr Proxy: Operating in offline mode and could not locate a file matching browser request.';
    close OUT;
}

sub openListenSocket
{    # Open a listen socket
    $browserSockets = new IO::Socket::INET(
        LocalHost => '127.0.0.1',
        LocalPort => "$proxyPort",
        Proto     => 'tcp',
        Timeout   => 1,
        Listen    => 20,
        Reuse     => 1
    ) or die "ERROR in Proxy Listen Socket Creation : $!\n";
}

sub usage
{
    print "Chilipeppr Proxy: Command line flag -offline or -online required; all other flags optional.\n";
    print "  Flags are:\n";
    print "  -online \n";
    print "  -offline \n";
    print "  -pathprefix    Directory path used to save files when online, or serve them when offline. Read/Write access required.   Anything that works on your OS is acceptable.\n";
    print "  -v             Verbosity. Supplying one or more -v flags prints additional diagnostic information.  \n";
    print "  -noauto        Supresses auto-config of Browser Proxy and clear of Browser Cache. Use only if these are causing problems. \n";
    print "  -noanim        Supresses backspaces used for animation of console. \n";
}
