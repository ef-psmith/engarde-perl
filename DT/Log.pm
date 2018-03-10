package DT::Log;
use 5.0180;
use warnings;
use base qw(Exporter);
use vars qw(@EXPORT);

@EXPORT  = qw{TRACE DEBUG INFO WARN ERROR FATAL set_logger};

use Log::Log4perl qw(get_logger);
Log::Log4perl->wrapper_register(__PACKAGE__);

my $log;


# say __PACKAGE__;

BEGIN 
{
	my @files = ( './logging.conf', '/home/engarde/live/logging.conf');
	foreach (@files)
	{
		if (-r $_)
		{ 
			Log::Log4perl->init_and_watch($_, 10); 
	
			$log = get_logger();
			$log->debug("logging configuration for " .  __PACKAGE__ . " loaded from $_");
			# undef this to stop all future calls using DT::Log as the package
			undef $log;
			return;
		}
	}
	
	# fallback config

	my $conf = q(
				log4perl.rootlogger = DEBUG, Screen

				# Screen output
				log4perl.appender.Screen         = Log::Log4perl::Appender::ScreenColoredLevels
				log4perl.appender.Screen.stderr  = 0
				log4perl.appender.Screen.layout=PatternLayout
				log4perl.appender.Screen.layout.ConversionPattern = [%-5p] %d %M(%L) - %m{indent,chomp}%n
  		);

	Log::Log4perl->init(\$conf);	
	$log = get_logger();
	$log->debug("logging configuration for " .  __PACKAGE__ . " loaded from fallback");
	undef $log;
}


sub set_logger
{
	my $app = shift || "";
	$log = get_logger($app) unless $log;	
}

sub TRACE
{
	set_logger();
	$log->trace(@_);
}

sub DEBUG
{
	set_logger();
	$log->debug(@_);
}

sub INFO
{
	set_logger();
	$log->info(@_);
}

sub WARN
{
	set_logger();
	$log->warn(@_);
}

sub ERROR
{
	set_logger();
	$log->error(@_);
}

sub FATAL
{
	set_logger();
	$log->fatal(@_);
}

1;
