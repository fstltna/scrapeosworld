#!/usr/bin/perl

# Creates a static HTML file from the http://opensimworld.com service
#
# Change These Settings:
$SERVER_NAME="OpensimCity";	# The name of your server
$OUTDIR="/var/www/html/regionstats";	# The file path to your web root
$WEBDIR="/regionstats/";		# The absolute web directory of the above

# Where to pull JSON data from. Put the region IDs at the end seperated by a comma
$SERVER_ADDR="http://opensimworld.com/regionstats?is_ajax=1&ids=77797,77757,77759,77936,77788,77926,76006,77745,77789,77758,77782"; 

# Probobly don't change below here
$REVVER="1.0.0";

# Load our dependancies
use File::Copy qw(copy);
use HTTP::Tiny;
use Data::Dumper qw(Dumper);
use LWP::Simple;
use JSON qw( decode_json );
use String::Scanf;

# Code below here
if (-e $OUTDIR and -d $OUTDIR)
{
	#print("$OUTDIR exists\n");
}
else
{
	#print("Creating $OUTDIR\n");
	mkdir $OUTDIR;
}

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year = substr($year, 1);
$LAST_SEEN = localtime();

# Write out HTML
my $message = <<"END_MESSAGE";
<html>
<head>
<title>Opensim Region Stats For Server $SERVER_NAME</title>
<style>
body {
	background-color: #DDDDDD
}
</style>
<meta name="description" 
      content="Displays the status of the desired regions">
<meta name="author" content="Marisa Giancarla">
<meta charset="UTF-8">
<meta name="keywords" content="opensim, regions, status, utility, script, server">
<meta property="og:title" content="Opensim Region Stats">
<meta property="og:description" content="Displays the status of the desired regions">
<meta http-equiv="refresh" content="600">
<link rel="copyright" href="https://OpensimCity.org/copyright.html">
</head>
<body>
<center>Last Scanned:<br>$LAST_SEEN</center>
<table border=1>
<tr><td><center><h1>$SERVER_NAME<br>Region Stats</h1></center></td></tr>
END_MESSAGE

# Pull in server data
my $response = HTTP::Tiny->new->get($SERVER_ADDR);
if ($response->{success})
{
    my $html = $response->{content};
    @LINES = split /\n/, $html;
    chomp(@LINES);
    #($a, $b) = sscanf("'{\"players\":%s", @LINES);
    $decoded_json = decode_json($html);
}
else
{
    print "Failed: $response->{status} $response->{reasons}";
}

open(my $fh, '>', "index.html") or die "Could not open file 'index.html' $!";
print $fh $message;
foreach (@{ $decoded_json })
{
    # Blank All These Out
    $title = "";
    $total_avis = 0;
    $link = "";
    $image_url = "";
    $status = "";
    $hg_address = "";
    $rating = "";
    $last_update_rel = "";
    $link_hop = "";
    $link_v3 = "";

    if ($_->{title} ne "")
    {
	$title = $_->{title};
    }
    else
    {
	$title = "Unknown Region";
    }
    #print "Title: $title\n";
    if ($_->{total_avis} != 0)
    {
	$total_avis = $_->{total_avis};
    }
    else
    {
	$total_avis = 0;
    }
    #print "Total Avis: $total_avis\n";
    if ($_->{link} ne "")
    {
	$link = $_->{link};
    }
    else
    {
	$link = "Unknown Link";
    }
    #print "Link: $link\n";
    if ($_->{image_url} ne "")
    {
	$image_url = $_->{image_url};
    }
    else
    {
	# Use this hosted image
	$image_url = "https://OpensimCity.org/regionstats/ScreenNeeded.png";
    }
    #print "Image URL: $image_url\n";
    if ($_->{status} ne "")
    {
	$status = $_->{status};
    }
    else
    {
	$status = "Unknown";
    }
    #print "Status: $status\n";
    if ($_->{hg_address} ne "")
    {
	$hg_address = $_->{hg_address};
    }
    else
    {
	$hg_address = "Unknown";
    }
    #print "HG Address: $hg_address\n";
    if ($_->{rating} ne "")
    {
	$rating = $_->{rating};
	if ($rating eq "Adult")
	{
	    $rating = "<font style=\"color:#FF0000;\">Adult</font>";
	}
	if ($rating eq "General")
	{
	    $rating = "<font style=\"color:#00DD00;\">General</font>";
	}
	if ($rating eq "Moderate")
	{
	    $rating = "<font style=\"color:#FFFF00;\">General</font>";
	}
    }
    else
    {
	$rating = "Unknown";
    }
    #print "Rating: $rating\n";
    if ($_->{last_update_rel} ne "")
    {
	$last_update_rel = $_->{last_update_rel};
    }
    else
    {
	$last_update_rel = "Unknown";
    }
    #print "Last Update Rel: $last_update_rel\n";
    if ($_->{link_hop} ne "")
    {
	$link_hop = $_->{link_hop};
    }
    else
    {
	$link_hop = "Unknown";
    }
    #print "Link Hop: $link_hop\n";
    if ($_->{link_v3} ne "")
    {
	$link_v3 = $_->{link_v3};
    }
    else
    {
	$link_v3 = "Unknown";
    }
    #print "Link V3: $link_v3\n";

    # Now spit out the table data for this entry
    print $fh "<tr><td width=200><a href=\"$link\">$title</a><br><table><tr><td><img src=\"$image_url\" width=175></td><td>Status: $status<hr>Users: $total_avis<hr>Rating: $rating</td></tr></table>Last Update: $last_update_rel<br><a href=\"$hg_address\">$hg_address</a><br><a href=\"$link_hop\">Hop Link</a> - <a href=\"$link_v3\">V3 Link</a></td></tr>";
}

print $fh "</table>
<hr>
Version $REVVER<br>Get This Utility At <a href=\"https://opensimcity.org/index.php/downloads/category/34-server-utils\">Opensim City</a>
</body>
</html>";
close $fh;
copy "index.html", $OUTDIR;
exit(0);
