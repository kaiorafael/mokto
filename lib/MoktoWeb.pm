package MoktoWeb;
#
# Mokto
# Copyright (C) 2020 Kaio Barbosa (kaiux)
#
# This file is part of Mokto.

use Mojo::Base -base, -signatures;
use Mojo::URL;
use Carp qw( croak );

require MoktoWeb::Fingerprint::HTTPHeaders;
use Data::Dumper;

has 'module_name';
has 'url';

my %supported_modules = (
   'http_header_fingerprint'=> 'MoktoWeb::Fingerprint::HTTPHeaders'
);

sub get_module_name {
   my $self = shift;
   return $self->module_name;
}

# if the URI is valid, it returns a Mojo::URL
# very basic test, mojo should not resolv when having
# an invalid url
sub uri_validation($vld) {
   my $a = Mojo::URL->new($vld);

   # trying to check if is a valid domain name
   if ( defined $a->path->parts->[0] ) {
      my @fqdn = split(/\./, $a->path->parts->[0]);

      # lets check if there is invalid char \ *
      if ( scalar @fqdn == 1 ) {
         if ( $fqdn[0] =~ /[\\\*@]/ ) {
            croak "Ouch! Looks like you have provided an invalid domain: $fqdn[0]";
         }
      }
   }

   return $a;
}

sub get_module_class($self, $module_name, $url){

   ### Raise the error if module not there
   croak "Module $module_name is not support" if not exists $supported_modules{$module_name};

   ### Raise error if url is invalid
   my $a = uri_validation($url);

   # set the attributes
   $self->module_name($module_name);
   $self->url($url);

   # load supported class
   return $supported_modules{$module_name}->new();
}

### Test
#my $f = MoktoWeb->new();
#my $oclass = $f->get_module_class('http_header_fingerprint', 'https://blog.kaiux.com');
#my $oclass = $f->get_module_class('http_header_fingerprint', 'blog.kaiux.com');
#my $oclass = $f->get_module_class('http_header_fingerprint', 'a');
#my $oclass = $f->get_module_class('http_header_fingerprint', 'http://localhost');
#my $oclass = $f->get_module_class('http_header_fingerprint', 'localhost');
#my $oclass = $f->get_module_class('http_header_fingerprint', 'y@ii');
#my $oclass = $f->get_module_class('http_header_fingerprint', 'my\omain');
#my $oclass = $f->get_module_class('http_header_fingerprint', 'm*yiomain');
#my $oclass = $f->get_module_class('http_header_fingerprint', 'http://a');
#say Dumper $f->module_name;
#say Dumper $oclass;
#$oclass->fp_send_request("HEAD", "blog.kaiux.com");

1;
