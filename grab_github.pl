#!/usr/bin/perl
chomp ($startedhere = `pwd`);
$basedir = "/admin/GIT";	## This is the dir where you want to store all your repos inside
$gituser = "GoKEV";		## Change this to the github user you want to download

## The github API will allow a maximum of 100 repos per page, hence this is also the limitation for this script.
$githuburl = 'https://api.github.com/users/' . $gituser . '/repos?per_page=100';

##################################################
##	A quick note on CHATTR - even root	##
##	will not be able to delete the files	##
##	you write until you do a `chattr -i`	##
##	on them.  This will be scary if you	##
##	are not familiar with chattr.  Search	##
##	the term "immutable" or do the cmd	##
##	`man chattr` for more info on this.	##
##						##
##	I wrote it this way so I won't make	##
##	changes to this version of the repos.	##
##	This will force me to edit them in	##
##	another spot and commit.		##
##################################################
##	Nothing to configure below here.	##
##################################################

@lines = split(/\n/,`curl -s $githuburl | grep ssh_url`);

foreach $line(@lines){
	($giturl = $line) =~ s/^.*ssh_url.*:.*\"(.*git)\".*$/$1/g;
	($gitdir = $line) =~ s/^.*github\.com:$gituser\/(.*)\.git.*$/$1/gi;
	$gitpath = $basedir . "/" . $gitdir;
	if ( -d $gitpath){
		$gotodir = $gitpath;
		$cmd = "chattr -R -i $gitpath ; git pull ; chattr -R +i $gitpath";
		$msg = "$gitpath exists.  Grabbing the latest code from \"$gitdir\".";
	}else{
		$gotodir = $basedir;
		$cmd = "git clone $giturl ; chattr -R +i $gitpath";
		$msg = "$gitpath is not a dir. Cloning in the repo \"$gitdir\" now.";
	}

$cmdstring=<<ALLDONECMD;
cd $gotodir && $cmd
ALLDONECMD

	chomp($cmdreply = `$cmdstring`);
	print "$msg\n";

#print<<ALLDONE;
#GITURL		$giturl
#GITDIR		$gitdir
#MSG		$msg
#CMDSTRING	$cmdstring
#CMDREPLY	$cmdreply
#------------------
#ALLDONE

}

system("cd $startedhere");
