package MoktoWeb::HTTPTraffic::Requests;
#
# Mokto
# Copyright (C) 2020 Kaio Barbosa (kaiux)
#
# This file is part of Mokto.

use Mojo::Base -base, -signatures;
use Mojo::UserAgent;
use Carp qw( croak );
use Data::Dumper;

##### Global options
my $user_agent_string = 'Mokto 0.01 - Perl Mojolicous';
my $version = '0.01';
my %http_methods = ( 'HEAD' => undef, 'GET' => undef , 'DELETE' => undef);
my $default_method = 'HEAD';

sub get_foo {
   my $self = shift;
   say $self->url;
}

sub single_request($self, $method, $url) {
   my $ua = Mojo::UserAgent->new;
   $ua->transactor->name($user_agent_string);
   $ua = $ua->max_redirects(2);

   my $tx = $ua->build_tx(
      $method => $url
   );

   $tx = $ua->start($tx);
   return $tx->res;
}

sub fp_send_request($self, $method, $url) {
   my $ua = Mojo::UserAgent->new;
   $ua->transactor->name($user_agent_string);
   $ua = $ua->max_redirects(1);

   my $tx = $ua->build_tx(
      $method => $url 
   );

   # send the request using Promise
   $ua->start_p($tx)->then(sub {
         my ($tx) = @_;
         #say Dumper $tx; 
         say $tx->result->code;
         if ( $tx->result->code == 301 ) {
            say $tx->result->headers->location
         }
         say "Request ", Dumper $tx->req->headers;
         say Dumper $tx->result->headers;

      })->catch(sub {
         my $err = shift;
         warn "HEAD request error :$err";
      })->wait;
}

1;

# Test
#my $f = MoktoWeb::HTTPTraffic::Requests->new();
#$f->single_request('HEAD', 'blog.kaiux.com');
#$f->fp_send_request('HEAD', 'blog.kaiux.com');
