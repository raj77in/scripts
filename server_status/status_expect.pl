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
#       AUTHOR: YOUR NAME (),
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 05/02/2013 09:27:50 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
#use Expect;
use Net::SSH::Perl;
use Data::Dumper;

my $debug =1 ;
my $timeout=10;
$Expect::Log_Stdout = 0;

open (FILE, "<list.txt");
print "Reading the list of servers from list.txt" if $debug;
my @ServerList = <FILE>;
close(FILE);
my @cmds = ( "uptime", "ls -alrt",
    'ps -eaf | grep -vE "^USER|grep|ps" | wc -l',
    'df -kh | grep -vE "^Filesystem|shm"| awk \'BEGIN{print "<ul>"}{w=sprintf("%d",$6);print " <li>" $5" - "$7  "&nbsp;" $6  "(" $2 ")" $4"/"$3 "</li>"}END{ print "</ul> "}\''
);

foreach (@ServerList){
    chomp;
    (my $user, my $host) = split / /;
    my $cmd = "";
    my $uhost = ( "$user\@$host");
    print "Getting details for server $_\n";
    print "Using the params for ssh - $uhost\n" if $debug;
    $cmd    = "ssh $uhost";
    my $prompt = "[Pp]assword";
    my $exp = new Expect();
    $exp->log_file("SSHLOGFILE.txt");
    $exp->raw_pty(1);
    $exp->spawn($cmd);
    $exp->expect($timeout,
        [ qr/\(yes\/no\)\?\s*$/ => sub { $exp->send("yes\n");
                exp_continue; } ],
        [ $prompt => sub { $_[0]->send("pwd\n"); } ],
        [ qr'>' => sub {
                print "Reading the previous data \n" if $debug;
                $exp->exp_before(); $exp->send("uname\n"); } ],
    );
    $exp->expect($timeout,
        [ qr'SunOS' => sub {
                print "This is solaris host\n" if $debug;
                $cmds[0]="uptime";
                $cmds[1]="/usr/sbin/swap -s";
                $cmds[2]='df -hk -F ufs | grep -vE "^Filesystem|shm"';
            } ],
    );

    use HTML::Template;
    my $template = HTML::Template->new(filename => 'head.tmpl');
    $template->param(date=> `date`);
    print "Content-Type: text/html\n\n", $template->output;

    #my $read = $exp->exp_before();
    #chomp $read;
    #print "Data receeived \n" if $debug;
    #print Dumper($read) if $debug;

    #my $out=$exp->send( "ls -la\r");
    #print Dumper $out if $debug;

    my $read = $exp->before();
    $exp->expect($timeout, [ qr/.*>/ => sub { $exp->send("date\n"); } ]);
    foreach (@cmds) {
        print "Sending command $_\n" if $debug;
        my $read = $exp->before();
        #$exp->expect($timeout, [ qr/.*>/ => sub { $exp->send("$_\n"); } ]);
        $exp->expect($timeout, [ qr'\n.[^\n]*>' => sub { $exp->send("$_\n"); } ]);
        $read = $exp->before();
        print "$_ --> Output is -- $read\n" if $debug;
    }
    $exp->expect($timeout, [ qr'\n.[^\n]*>' => sub { $exp->send("logout\n"); } ]);
    $exp->hard_close();
    $template = HTML::Template->new(filename => 'tail.tmpl');
    print $template->output;
}
