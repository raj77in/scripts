#!/usr/bin/perl
#===============================================================================
#
#         FILE: status.pl
#
#        USAGE: ./status.pl
#
#  DESCRIPTION: Check the status of servers.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Amit Agarwal(amit.agarwal@roamware.com)
# ORGANIZATION: Individual
#      VERSION: 1.0
#      CREATED: 05/02/2013 09:27:50 AM
#Last modified: Fri May 03, 2013  12:45PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

#use Expect;
use Net::SSH::Perl;
use Data::Dumper;
use Net::Ping::External qw(ping);
use FindBin;

my $debug     = 0;
my $timeout   = 10;
my $GREEN     = '<font color="#00ff00">';
my $RED       = '<font color="#ff0000">';
my $NOC       = '</font>';
my $LOAD_WARN = 5.0;
my $PROC_WARN = 200;
my $DISK_WARN = 75;
my $RAM_WARN  = 40;
my $dir       = $FindBin::Bin;
my $listfile  = "$dir/list.txt";
#print "List file is $listfile \n";

# Taken from http://stackoverflow.com/questions/4809728/perl-can-i-get-paths-related-to-where-a-script-resides-and-where-it-was-execut
# but FindBin seems to be better at doing this and hence not used.
sub find_currentDir {
    print "PWD: $ENV{PWD}\n";
    print "\$0: $0\n";

    my $bin = $0;
    my $bin_path;

    $bin =~ s#^\./##;                           # removing leading ./ (if any)

    # executed from working directory
    if ( $bin !~ m#^/|\.\./# ) {
        $bin_path = "$ENV{PWD}/$bin";
    }

    # executed with full path name
    elsif ( $bin =~ m#^/# ) {
        $bin_path = $0;
    }

    # executed from relative path
    else {
        my @bin_path  = split m#/#, $bin;
        my @full_path = split m#/#, $ENV{PWD};

        for (@bin_path) {
            next if $_ eq ".";
            ( $_ eq ".." ) ? pop @full_path : push @full_path, $_;
        }
        $bin_path = join( "/", @full_path );
    }

    print "Script Path: $bin_path\n";
    return $bin_path;
}                                               ## --- end sub find_currentDir

open( FILE, "<$listfile" );
print "Reading the list of servers from list.txt\n" if $debug;
my @AServerList = <FILE>;
my @ServerList = grep { $_ !~ /^#/ } @AServerList;
close(FILE);
print Dumper @ServerList if $debug;
my @cmds = (
    'ruptime=$(uptime);
    if $(echo $ruptime | egrep -v  "day" >/dev/null); then
    echo $ruptime | sed s/,//g| awk \'{ print $3 "(hh:mm)"}\'
    else
    echo $ruptime | awk \'{ print $3 " days " $5 "(HH:MM)"}\'
    fi',
    q( free -mto | grep Mem: | awk '{ print $2"," $3"," $4}'
),

    #'df -kh | egrep -v "^Filesystem|shm|tmpfs"| awk \'BEGIN{print "<ul>"}{w=sprintf("%d",$6);print " <li>" $5" - "$7  "&nbsp;" $6  "(" $2 ")" $4"/"$3 "</li>"}END{ print "</ul> "}\'',
    'df -kh | egrep -v "^Filesystem|shm|tmpfs"',
    'ps -eaf | egrep -v "^USER|grep|ps" | wc -l',
);

use HTML::Template;
my $now = localtime;
my $template = HTML::Template->new( filename => "$dir/head.tmpl" );
$template->param( date => `date` );
print 'From: Amit-status<amit.agarwal@roamware.com>
To: amit.agarwal@roamware.com
Subject: Stuatus of the servers ';
print "$now \n";

print "Content-Type: text/html\n\n", $template->output;
foreach (@ServerList) {
    print STDERR "Going for $_" if $debug;
    $template = HTML::Template->new( filename => "$dir/html.tmpl" );
    chomp;
    ( my $user, my $password, my $host ) = split / /;
    my $cmd = "";

    #ping
    my $alive = ping( host => "$host" );
    if ( !$alive ) {
        print "Return value from ping is $?\n" if $debug;
        print "Ping failed\n"                  if $debug;
        $template->param( hostip => $host );
        $template->param( pingst => "$RED Failed $NOC" );
        print $template->output;
        next;
    }
    else {
        $template->param( pingst => "$GREEN Ok $NOC" );
    }

    print "Getting details for server $_\n"    if $debug;
    print "Using the params for ssh - $host\n" if $debug;
    $cmd = "ssh $host";
    my $ssh = Net::SSH::Perl->new( $host, debug => 0 ) or next;
    $ssh->login( $user, $password );

    #my $read = $exp->exp_before();
    #chomp $read;
    #print "Data receeived \n" if $debug;
    #print Dumper($read) if $debug;

    #my $out=$exp->send( "ls -la\r");
    #print Dumper $out if $debug;
    #
    my ( $read, $out, $err ) = $ssh->cmd("uname");
    if ( $read =~ /SunOS/ ) {

        #$cmds[0]="uptime";
        $cmds[1] = q(/usr/sbin/swap -s|sed 's/k / /g'|awk '{ print \($9+$11\)"," $2 "," $11 }');
        $cmds[2] = 'df -hk -F ufs | egrep -v "^Filesystem|shm"';
        print "This is solaris host\n" if $debug;
    }
    else {
        print "OS is $read\n" if $debug;
    }

    ( $read, $out, $err ) = $ssh->cmd("hostname");
    chomp $read;
    $read = substr( $read, 0, 7 );

    $template->param( hostname => $read );
    $template->param( hostip   => $host );

    ( $read, $out, $err ) = $ssh->cmd("date\n");
    chomp $read;
    $template->param( date => $read );

    #uptime
    ( $read, $out, $err ) = $ssh->cmd("$cmds[0]|sed \'s/,//\'\n");
    chomp $read;
    print "Executing $cmds[0]\n" if $debug;
    print "Output is -- $read\n" if $debug;
    $template->param( uptime => $read );

    # Load averavge
    $cmd = q(uptime |sed 's/.*average://'|sed 's/,/ /g'|sed 's/^ //g');
    ( $read, $out, $err ) = $ssh->cmd("$cmd\n");
    chomp $read;
    print "Loadavg - Output is --$read--\n" if $debug;
    my @loads = split( / +/, $read );
    print Dumper @loads if $debug;
    if ( $loads[0] >= $LOAD_WARN ) {
        $template->param( loadavg => "$RED $loads[0]/$loads[1]/$loads[2] (High) $NOC\n" );
    }
    else {
        $template->param( loadavg => "$GREEN $loads[0]/$loads[1]/$loads[2] (Ok) $NOC\n" );
    }

    #Running Processes
    print "Executing $cmds[3]\n" if $debug;
    ( $read, $out, $err ) = $ssh->cmd("$cmds[3]\n");
    chomp $read;
    if ( $read <= $PROC_WARN ) {
        $template->param( runningProcs => "$GREEN $read (Ok) $NOC" );
    }
    else {
        $template->param( runningProcs => "$RED $read (High) $NOC" );

    }

    # Disk usage
    print "Executing $cmds[2]\n" if $debug;
    ( $read, $out, $err ) = $ssh->cmd("$cmds[2]\n");
    if ( defined $read and $read !~ /^$/ ) {
        chomp $read;
        my @disks = split( /\n/, $read );
        my $disk = "";
        foreach (@disks) {
            my @parts = split / +/;
            print Dumper @parts if $debug;
            print "OUTPUT :: $_\n" if $debug;
            $parts[4] =~ s/%//;
            if ( $parts[4] <= $DISK_WARN ) {
                $disk = "$disk\n<li>$GREEN $parts[5] - Total($parts[1]) - $parts[4]%$NOC</li>";
            }
            else {
                $disk = "$disk\n<li>$RED $parts[5] - Total($parts[1]) - $parts[4]%$NOC</li>";
            }
        }
        $template->param( diskst => "$disk" );
    }

    # Total users
    $cmd = q(who |awk '{print $1}'|sort |uniq -c|sort -nr |tr '\n' ',' );
    ( $read, $out, $err ) = $ssh->cmd("$cmd\n");
    if ( defined $read and $read !~ /^$/ ) {
        chomp $read;
        print "Output for total users - $read- \n" if $debug;
        $template->param( usertot => "$read" );
    }

    #Last log
    $cmd = q(last|head -5);
    ( $read, $out, $err ) = $ssh->cmd("$cmd\n");
    print "Output for last  - $read- \n" if $debug;
    my $lastst = "";
    foreach ( split /\n/, $read ) {
        $lastst = "<li>$_</li>\n$lastst";
    }
    $template->param( lastst => "$lastst" );

    #RAM Usage
    print "Executing $cmds[1]\n" if $debug;
    ( $read, $out, $err ) = $ssh->cmd("$cmds[1]\n");
    if ( defined $read and $read !~ /^$/ ) {
        my @parts = split( /,/, $read );
        my $post  = "Kb";
        my $pert  = $parts[1] / $parts[0] * 100;
        for ( my $i = 0; $i <= 2; $i++ ) {
            if ( $parts[$i] > 1024 ) { $parts[$i] /= 1024; $post = "Kb"; }
            if ( $parts[$i] > 1024 ) { $parts[$i] /= 1024; $post = "Gb"; }
            $parts[$i] = sprintf( "%.3f %s", $parts[$i], $post );
        }
        print "Total = $parts[0], used =$parts[1], percentage = $pert%\n" if $debug;
        $pert = sprintf( "%.2f", $pert );
        print "Total = $parts[0], used =$parts[1], percentage = $pert%\n" if $debug;
        print Dumper @parts                                               if $debug;
        print "Output for last  - $read- \n"                              if $debug;
        if ( $pert > $RAM_WARN ) {
            $read = sprintf("$RED Total - $parts[0] - Used - $pert%% $NOC\n");
        }
        else {
            $read = sprintf("$GREEN Total - $parts[0] - Used - $pert%% $NOC\n");
        }
        $template->param( ramst => "$read" );
    }
    print $template->output;
    undef $ssh;

}

$template = HTML::Template->new( filename => "$dir/tail.tmpl" );
print $template->output;
