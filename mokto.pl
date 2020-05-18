#!/usr/bin/env perl
#
# Mokto
# Copyright (C) 2020 Kaio Barbosa (kaiux)
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

use Mojo::Base -base, -signatures;
use Data::Dumper;
use Getopt::Long qw(GetOptions);
use FindBin;
use lib "$FindBin::Bin/lib";
use MoktoWeb;
use MoktoReport;

##### Global options
my %http_methods = ( 'HEAD' => undef, 'GET' => undef , 'DELETE' => undef);
my $default_method = 'HEAD';

sub usage() {
   say "--method\tHTTP methods";
   say "--scan\t Default is all";
   say "--host\tdomain";
   exit 2;
}

sub is_valid_http_method($method) {
   die ("Invalid HTTP method : $method") if ( not exists($http_methods{$method}) );
}

##################
#### Main code
##################

my %args = ();
GetOptions(\%args,
   "method=s",
   "scan=s",
   "host=s"
) or die usage(); #"Usage: $0 --debug\n";

## Testing options
$default_method = uc($args{'method'}) if exists $args{'method'};
die "Missing --host" unless $args{'host'};
die ("Not supported HTTP method: $default_method")
   if (not exists($http_methods{$default_method}));

# ready to send the requests based on modules
### sending request based on http method
my $f = MoktoWeb->new();
my $report = MoktoReport->get_instance;
$report->{url} = $args{'host'};

my $oclass = $f->get_module_class('http_header_fingerprint', $args{'host'});
$oclass->fp_send_request($default_method, $args{'host'});

### printing report
$report->print_report();
