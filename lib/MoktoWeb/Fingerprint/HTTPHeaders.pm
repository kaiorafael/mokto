package MoktoWeb::Fingerprint::HTTPHeaders;
#
# Mokto
# Copyright (C) 2020 Kaio Barbosa (kaiux)
#
# This file is part of Mokto.

use Mojo::Base -base, -signatures;
use Data::Dumper;
use JSON::PP;
use MoktoReport;
use Carp;

use MoktoWeb::HTTPTraffic::Requests;

has fp_results => undef;
has url => undef;
my $report = MoktoReport->get_instance;

# headers is a hash reference
# investigate headers
sub forensic_header($self, $headers) {

   ### From Owasp definition
   # true means they server have the protection
   my %owasp_missing_headers = (
         'Strict-Transport-Security' => 'True',
         'X-XSS-Protection' => 'True',
         'Public-Key-Pins' => 'True',
         'X-Content-Type-Options' => 'True',
         'Content-Security-Policy' => 'True',
         'X-Permitted-Cross-Domain-Policies' => 'True',
         'Referrer-Policy' => 'True',
         'Expect-CT' => 'True',
   );

   # hashmap - getting all headers name, making UpperCase
   # many sites handles the Security Headers with different cases
   # using uppercase as default
   my %header_names = map { uc($_) => 1 } sort @{$$headers->names};

   # testing if hosts use any protection as HTTP header
   foreach my $hd ( keys %owasp_missing_headers) {
      if ( !exists $header_names{uc($hd)} ) {
         $owasp_missing_headers{$hd} = 'False';
      }
   }

   # creating hash from hash_ref
   my %hash_ref =  %{$$headers};
   my @m_keys = keys %{$hash_ref{'headers'}};

=item
   #### JSON Report nice working
   my %report = (
      'domain' => $self->url,
      'headers' => $hash_ref{'headers'},
      'OWASP' => \%owasp_missing_headers
   );
   my $json_report = encode_json \%report;
   say $json_report;
=cut
   my %report = (
      'domain' => $self->url,
      'headers' => $hash_ref{'headers'},
      'OWASP' => \%owasp_missing_headers
   );
   $report->set_report_field($self->url, \%report);

   # Singleton report approach
   #$report->set_report_field('domain', $self->url);
   #$report->set_report_field('headers', $hash_ref{'headers'});
   #$report->set_report_field('OWASP', \%owasp_missing_headers);

}

sub fp_send_request($self, $method, $url) {

   $self->url($url);

   my $f = MoktoWeb::HTTPTraffic::Requests->new();
   my $response = $f->single_request($method, $url);

   #### Test before generate the reports
   if ( not defined $response->code  and defined $response->error ) {
      return;
      #say Dumper $response;
      #say "Ouch!! something is wrong here for url: $url - R";
      #say $response->error->{'message'};
      #return;
   }

   #TODO test if code is 200 or something else
   $self->forensic_header(
      \$response->headers,
   );
}

sub fp_async_requests($self, @urls) {
   my $f = MoktoWeb::HTTPTraffic::Requests->new();
   my @response = $f->send_async_requets(@urls);
   #say Dumper @response;
   #say $response[0]->req->url->host;
   #say Dumper $response[0]->res->headers;

   for my $i (0..$#response) {
      if ( defined $response[$i]->req ) {
         $self->url(
            $response[$i]->req->url->host
         );
         $self->forensic_header(
            \$response[$i]->res->headers
         );
      }
   }

}
1;

# Test
#my $f = MoktoWeb::HTTPTraffic::Requests->new();
#say $response = $f->single_request('HEAD', 'blog.kaiux.com');
#say Dumper $response;
#
=item
my $f = MoktoWeb::Fingerprint::HTTPHeaders->new();
my @ur;
my $fh = IO::File->new("/tmp/bar", "r");
 if (defined $fh) {
    for my $u (<$fh>) {
       chomp($u);
       push @ur, $u;
    }
     undef $fh;       # automatically closes the file
 }
$f->fp_async_requests(@ur);
=cut
