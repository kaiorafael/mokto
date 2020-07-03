package MoktoReport;
#
# Mokto
# Copyright (C) 2020 Kaio Barbosa (kaiux)
#
# This file is part of Mokto.

use Mojo::Base -signatures;
use Data::Dumper;
use JSON::PP;

my $instance = undef;

sub get_instance {
    $instance = bless {}, shift unless $instance;
    $instance->{report} = {};
    return $instance;
}

sub print_report($self) {
   my $json_report = encode_json $self->{report};
   say $json_report;
}

sub set_report_field($s, $field, $data_ref) {
   my $self = $s;
   $self->{report}->{$field} = $data_ref;
}

sub get_report($self) {
   return $self->{report};
}

1;
