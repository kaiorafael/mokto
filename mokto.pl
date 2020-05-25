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

use Data::Dumper;
use Getopt::Long qw(GetOptions);
use FindBin;
use lib "$FindBin::Bin/lib";
use MoktoWeb;
use MoktoReport;
use MoktoUtils;
use Mojo::Base -base, -signatures;

##### Global options
my $_utils = MoktoUtils->new();

##################
#### Main code
##################

# Arguments Accepted
my %args = ();
GetOptions(\%args,
   "method=s",
   "scan=s",
   "host=s",
   "mhosts=s"
) or die $_utils->usage(); #"Usage: $0 --debug\n";

## Testing options

#default http method (HEAD) is default
my $default_method = undef;

### applies method provided by args or gets default
$default_method = uc($args{'method'}) if exists $args{'method'};
if ( !defined $default_method ) {
   $default_method = $_utils->get_default_method;
}

# make sure is a valid http method
$_utils->is_valid_http_method($default_method);

## check for hosts scan approaches
if ( exists $args{'host'} and exists $args{'mhosts'} ) {
   say "";
   say "You cannot use `host` and `mhosts` altogether";
   $_utils->usage();
}

# setup the scanner and report
my $moktoweb = MoktoWeb->new();
my $report = MoktoReport->get_instance;

###
#TODO define method to run all scan types
#
## this uses synchronous request
if ( exists $args{'host'} ) {
   my $oclass = $moktoweb->get_module_class('http_header_fingerprint', $args{'host'});
   $oclass->fp_send_request($default_method, $args{'host'});
}

if ( exists $args{'mhosts'} ) {
   my $array_ref = $_utils->load_file($args{'mhosts'});

   my $oclass = $moktoweb->get_module_class('http_header_fingerprint', 'example.com');
   $oclass->fp_async_requests(@$array_ref);
}

### printing report
$report->print_report();
