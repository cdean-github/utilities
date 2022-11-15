#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

my $opt_collaboration = 'sPHENIX';
GetOptions('collaboration:s' => \$opt_collaboration);

my $containername = "rhic_sl7_ext.sif";
my $dockername = "rhic_sl7_ext_docker.tar.gz";
my $mcegname = "MCEG.tar.bz2";

my %rootversion = ();
$rootversion{"new"} = "Root6";
$rootversion{"root5"} = "Root5";

my %tarball = ();
$tarball{"opt.tar.bz2"} = "supportsoftware tarball";
$tarball{"offline_main.tar.bz2"} = "coresoftware tarball";
$tarball{"utils.tar.bz2"} = "utilities tarball";

my %sysname = ();
$sysname{"gcc-12.1.0"} = "SL7 build with gcc 12.1.0";
$sysname{"gcc-8.3"} = "SL7 build with gcc 8.3.1";
$sysname{"x8664_sl7"} = "SL7 build with gcc 4.8.3";

my $opt_help = 0;

if ($#ARGV < 0 || $opt_help>0)
{
    print "usage: create_index_html.pl <target dir>\n";
    print "options:\n";
    print "--help         : print this help\n";
    exit 1;
}

my $targetdir = $ARGV[0];

if (! -d $targetdir)
{
    print "could not find target dir: $targetdir\n";
    exit 1;
}

my $indexfile = sprintf("%s/index.html",$targetdir);
open(F, ">$indexfile");

print F "<HTML>\n";
print F "<HEAD>\n";
print F "<TITLE>$opt_collaboration Singularity Container Download</TITLE>\n";
print F "</HEAD>\n";
print F "<BODY>\n";
print F "<h1>Welcome to the $opt_collaboration singularity download page</H1>\n";
print F "";

my $fullcontainer = sprintf("%s/%s",$targetdir,$containername);

if (-f $fullcontainer)
{
    print F "<h3>\n";
    print F "<a href=\"./$containername\">rcf Singularity Container image</a>\n";
    my $md5file = sprintf("%s.md5",$containername);
    my $fullmd5file = sprintf("%s/%s",$targetdir,$md5file);
    if (-f $fullmd5file)
    {
	print F " with corresponding <a href=\"./$md5file\"> md5 sum</a>\n";
    }
    print F "<p></h3>\n";
}

my $dockercontainer = sprintf("%s/%s",$targetdir,$dockername);

if (-f $dockercontainer)
{
    print F "<h3>\n";
    print F "<a href=\"./$dockername\">rcf Docker Container image</a>\n";
    my $md5file = sprintf("%s.md5",$dockername);
    my $fullmd5file = sprintf("%s/%s",$targetdir,$md5file);
    if (-f $fullmd5file)
    {
	print F " with corresponding <a href=\"./$md5file\"> md5 sum</a>\n";
    }
    print F "<p></h3>\n";
}

my $mcegtar = sprintf("%s/%s",$targetdir,$mcegname);

if (-f $mcegtar)
{
    print F "<h3>\n";
    print F "<a href=\"./$mcegname\">EIC Monte Carlos</a>\n";
    my $md5file = sprintf("%s.md5",$mcegname);
    my $fullmd5file = sprintf("%s/%s",$targetdir,$md5file);
    if (-f $fullmd5file)
    {
	print F " with corresponding <a href=\"./$md5file\"> md5 sum</a>\n";
    }
    print F "<p></h3>\n";
}

opendir (my $dh, $targetdir);
my @dirs = grep {-d "$targetdir/$_" && ! /^\.{1,2}$/} readdir($dh);
foreach my $subdir (@dirs)
{
    print F "<hr>\n";
    print F "</br>\n";
    if (exists $sysname{$subdir})
    {
	print F "<h2>$sysname{$subdir}</h2>\n";
	my $subtargetdir = sprintf("%s/%s",$targetdir,$subdir);
        opendir (my $blddh, $subtargetdir);
	my @blddirs = grep {-d "$subtargetdir/$_" && ! /^\.{1,2}$/} readdir($blddh);
	foreach my $bldsubdir (@blddirs)
	{
	    if (exists $rootversion{$bldsubdir})
	    {
		print F "<h3>$rootversion{$bldsubdir} build</h3>\n";
	    }
	    print F "<h4>\n";
	    foreach my $tb (keys %tarball)
	    {
		my $relfile = sprintf("%s/%s/%s",$subdir,$bldsubdir,$tb);
		my $fullfile = sprintf("%s/%s",$targetdir,$relfile);
		if (-f $fullfile)
		{
		    print F "<a href=\"./$relfile\">$tarball{$tb}</a>\n";
		    my $md5file = sprintf("%s.md5",$relfile);
		    my $fullmd5file = sprintf("%s.md5",$fullfile);
		    if (-f $fullmd5file)
		    {
			print F " with corresponding <a href=\"./$md5file\"> md5 sum</a>\n";
		    }
		    print F"</br>\n";
		}
	    }
	    print F"</h4>\n";
	    print F"</br>\n";

	}

	closedir($blddh);
    }
}
close($dh);
print F "<hr>\n";

print F"</p>\n";
print F "<h2>Virtualbox Image</h2>\n";
print F "<p><a href=\"./Fun4AllSingularityDistribution.ova\">Virtualbox Ubuntu18.04LTS image</a> with $opt_collaboration CVMFS and Singularity installed, which provides a stable linux env for Windows Hosts.</br>\n";
print F "if prompted: username fun4all, password fun4all<p>\n";

print F "</BODY>\n";
print F "</HTML>\n";
close(F);
