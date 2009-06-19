#!perl -w

use strict;
use Data::Dumper;
# use Spreadsheet::WriteExcel;
use Win32 qw(CSIDL_PERSONAL CSIDL_DESKTOP);
use Win32::GUI();
# use Win32::FileOp qw(BrowseForFolder);
use File::Basename;
use Net::FTP;

my %fencers;
my %clubs;
my %nations;
my $DEBUGGING=1;
my $path;

my $sex;
my $weapon;

my $no_results = "<div align=\"center\">\n<p /><p />\nThere are no currently no results for this stage</div>";
my $results_head = "./results/fencing/individual/head.htm";
my $results_foot = "./results/fencing/individual/foot.htm";

my @weapons = ("we", "me", "wf", "mf", "ws", "ms");

my @levels = ("pool", "16", "8", "4", "2");
my %level_names = (
				pool => "Pool", 
				16 => "Tableau of 16", 
				8 => "Tableau of 8", 
				4 => "Semi Final", 
				2 => "Final"
			);


my %order = ( 
				16 => [undef, 1, 16, 9, 8, 5, 12, 13, 4, 3, 14, 11, 6, 7, 10, 15, 2],
				8 => [undef, 1, 8, 5, 4, 3, 6, 7, 2],
				4 => [undef, 1, 4, 3, 2],
				2 => [undef, 1, 2]
			);


my %names = ( 	we => "Womens Epee",
				me => "Mens Epee",	
				wf => "Womens Foil",	
				mf => "Mens Foil",	
				ws => "Womens Sabre",	
				ms => "Mens Sabre"	);

my $W = new Win32::GUI::DialogBox (
    -title    => "Publish UKSG Fencing Results",
    -left     => 100,
    -top      => 20,
    -width    => 500,
    -height   => 768,
    -name     => "Window",
);


my $LabelFont = new Win32::GUI::Font (
   	-name => "Courier New",
   	-size => 12,
   	-weight => 700,
   	-height => -14
);

my $LabelFont_small = new Win32::GUI::Font (
   	-name => "Courier New",
   	-size => 8,
   	-weight => 700,
   	-height => -10
);


my $TabStart = $W->AddCombobox (
	-name => "TabStart",
	-dropdown => 1,
	-top => 95,
	-left => 275,
	-height =>90,
	-width => 50
);


$TabStart->InsertItem("Pool");
$TabStart->InsertItem("L16");
$TabStart->InsertItem("L8");
$TabStart->InsertItem("Semi");
$TabStart->InsertItem("Final");

my $TabStop = $W->AddCombobox (
	-name => "TabStop",
	-dropdown => 1,
	-top => 95,
	-left => 335,
	-height =>90,
	-width => 50
);


$TabStop->InsertItem("Pool");
$TabStop->InsertItem("L16");
$TabStop->InsertItem("L8");
$TabStop->InsertItem("Semi");
$TabStop->InsertItem("Final");


my $AutoButton = $W->AddButton(
	-name => "AutoButton",
	-text  => "Auto",
	-left => 65,
	-top => 90,
	-group => 1,
	-tabstop => 1,
	-height => 30,
	-width => 60
);


my $StopButton = $W->AddButton(
	-name=> "StopButton",
	-text=>"Stop",
	-left => 65,
	-top => 90,
	-group => 1,
	-tabstop => 1,
	-height => 30,
	-width => 60

);

$StopButton->Hide();

my $PubButton = $W->AddButton(
	-name => "PubButton",
	-text  => "Publish",
	-left => 135,
	-top => 90,
	-group => 1,
	-tabstop => 1,
	-height => 30,
	-width => 60
);


my $CleaarButton = $W->AddButton(
	-name => "ClearButton",
	-text  => "Clear",
	-left => 205,
	-top => 90,
	-group => 1,
	-tabstop => 1,
	-height => 30,
	-width => 60
);


my $W_L1 = $W->AddLabel ( 
	-name=>"W_L1",
	-text=>"Competition",
	-font => $LabelFont,
	-top=>30,
	-left=>70
);


my $W_L2 = $W->AddLabel ( 
	-name=>"W_L2",
	-text=>"From",
	-font => $LabelFont_small,
	-top=>80,
	-left=>285
);


my $W_L3 = $W->AddLabel ( 
	-name=>"W_L3",
	-text=>"To",
	-font => $LabelFont_small,
	-top=>80,
	-left=>345
);


my $CompetitionButton_1 = $W->AddButton(
	-name => "CompetitionButton_1",
	-text  => "...",
	-left => 400,
	-top => 50,
	-group => 1,
	-tabstop => 1,
	-height => 25,
	-width => 30
);


my $Competition_1 = $W->AddTextfield(
	-name => "Competition 1",
	-left => 65,
	-top => 50,
	-group => 1,
	-tabstop => 1,
	-height => 25,
	-width => 300,
	-prompt => "Hello world"
);


my $Results = $W->AddTextfield(
	-name => "Results",
	-left => 60,
	-top => 150,
	-group => 1,
	-tabstop => 1,
	-height => 500,
	-width => 380,
	-readonly=> 1,
	-multiline => 1,
	-vscroll => 1,
	-autovscroll => 1
);


my $T1 = $W->AddTimer('T1', 0);


$Competition_1->SetFocus();

$W->Show;

Win32::GUI::Dialog();

# End of main


##########################################################################
#
# 					GUI Subs
#
##########################################################################


sub add_output
{
	my $add = shift;

	my ($ss, $mm, $hh, $dd, $MM, $yy, $dw, $dy, $ds) = localtime();

	$MM++;
	$yy += 1900;

	my $now = sprintf "%02d/%02d/%04d %02d:%02d:%02d", $dd, $MM, $yy, $hh, $mm, $ss;

	my $text = $Results->Text();
	$Results->Change(-text=> "$now : $add\r\n$text"); ;
}


sub ClearButton_Click
{
	$Results->Change(-text => "");
}


sub PubButton_Click
{
	$PubButton->Disable();

	# get_index_page();


	add_output("weapon = $weapon");
	add_output("sex = $sex");

	write_file("pool",parse_pool(1));
	write_file("16",html_tableau(16));
	write_file("8",html_tableau(8));
	write_file("4",html_tableau(4));
	write_file("2",html_tableau(2));

	$PubButton->Enable();
}


sub AutoButton_Click
{
	add_output("Auto publish started");

	$T1->Interval(5000);
	$PubButton->Disable();
	$AutoButton->Hide();
	$StopButton->Show();
}


sub StopButton_Click
{
	$T1->Interval(0);
	add_output("Auto publish stopped");
	$StopButton->Hide();
	$AutoButton->Show();
	$PubButton->Enable();
}


sub CompetitionButton_1_Click 
{
	my $self = shift;

	add_output("self = " . ref $self);

	my $text = choose_competition();

	if ($text)
	{
		$path = dirname($text);
		# print "text = $text, path = $path\n";
		$Competition_1->Change(-text=>$text);
		add_output("$text selected");
	}
}


sub T1_Timer 
{
	add_output "Timer went off!";
}


sub publish_page
{
	my $page = shift;

	my $host = "inetc60.inetc.net";
	my $user = "zcr";
	my $pw = "DMTEENFHAB";
	my $dir = "/zcr/www/ukschoolgames/results/fencing/individual";

	add_output("publishing $page");

	my $ftp = Net::FTP->new($host, Debug => 0)
      or add_output("Cannot connect to ftp host: $@") && return;

    $ftp->login($user,$pw)
      or add_output("Cannot login ", $ftp->message) && return;

    $ftp->cwd($dir)
      or add_output("Cannot change working directory ", $ftp->message) && return;

    $ftp->put("results/fencing/individual/$page")
      or add_output ("put failed ", $ftp->message) && return;

    $ftp->quit;

	# add_output("Finished getting index.html");
}


sub get_index_page
{
	my $host = "inetc60.inetc.net";
	my $user = "zcr";
	my $pw = "DMTEENFHAB";
	my $dir = "/zcr/www/zardev/ukschoolgames/results/fencing";

	add_output("Getting index.html");

	my $ftp = Net::FTP->new($host, Debug => 0)
      or add_output("Cannot connect to ftp host: $@") && return;

    $ftp->login($user,$pw)
      or add_output("Cannot login ", $ftp->message) && return;

    $ftp->cwd($dir)
      or add_output("Cannot change working directory ", $ftp->message) && return;

    $ftp->get("index.htm")
      or add_output ("get failed ", $ftp->message) && return;

    $ftp->quit;

	add_output("Finished getting index.html");
}

sub Window_Terminate 
{
    return -1;
}


sub choose_competition
{
	my $ret = Win32::GUI::GetOpenFileName(
    	-title  => "Select Engarde Competition",
		# -file   => "\0" . " " x 256,
    	-filter => [ "Competition files (*.egw)" => "*.egw" ]
	);

	if ($ret)
	{
		return $ret;
	}
	else
	{
		0;
	}
}





