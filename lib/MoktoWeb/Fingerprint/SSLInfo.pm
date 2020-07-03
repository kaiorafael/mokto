# Mokto
# Copyright (C) 2020 Kaio Barbosa (kaiux)
#
# This file is part of Mokto.

# This is the class that is initiate and called to send the SSL requests
#
package MoktoWeb::Fingerprint::SSLInfo;

use Mojo::Base -base, -signatures;
use IO::Socket::SSL;
use Data::Dumper;
use MIME::Base64 ();
use Crypt::X509;
use MoktoReport;
use MoktoWeb::Fingerprint::SSLUtils;

### result from ciphers
has supported_ciphers =>  sub {
   {
      SSLv23 => [],
      SSLv2 => [],
      SSLv3 => [],
      TLSv1 => [],
      TLSv1_1 => [],
      TLSv1_2 => [],
      TLSv1_3 => []
   }
};

has ssl_utils => sub { MoktoWeb::Fingerprint::SSLUtils->new() };

# global var
my $report = MoktoReport->get_instance;

sub fp_x509($self, $host) {
   say "x509 information";
   my $client = undef;
   $client = IO::Socket::SSL->new(
      PeerHost => $host,
      PeerPort => "https",
      SSL_verify_callback => sub {
         my ($ok,$store,$certstring,$err,$cert,$depth) = @_;
         my $pem = Net::SSLeay::PEM_get_string_X509($cert);
         $pem =~ s/-----BEGIN CERTIFICATE-----//g;
         $pem =~ s/-----END CERTIFICATE-----//g;
         #say $pem;
         my $decoded = MIME::Base64::decode($pem);
         #say Dumper $decoded;
         my $x509 = Crypt::X509->new( cert => $decoded);
         if ($x509->error) {
            warn "Error on parsing Certificate:".$x509->error;
         }
         #say Dumper $x509;
         print "Certificate was issued by:".join(',',@{$x509->Issuer})."\n";
         print "Valid until: ".gmtime($x509->not_after)." GMT\n";
         print "Issued at: ".gmtime($x509->not_before)." GMT\n";
         print "DN for this Certificate is:".join(',',@{$x509->Subject})."\n";

         return $ok;
      },
   ) or do {
      warn "boiz failed connect or ssl handshake: $!,$SSL_ERROR";
   };

   if ( $client ) {
      print "Current cipher: " .$client->get_cipher() . "\n";
      say $client->get_sslversion();
      close $client;
   }

}

# p_version = protocol version
# s_cipher = single cipher
sub get_cipher_from_dest($self, $host, $p_version, $s_cipher) {
   my $client = undef;
   $client = IO::Socket::SSL->new(
      PeerHost => $host,
      PeerPort => "https",
      SSL_version => $p_version,
      SSL_cipher_list => $s_cipher
   );

   ### Means that Protocol and Cipher works
   if ( $client ) {
      push @{ $self->supported_ciphers->{$p_version} }, $client->get_cipher();
      close $client;
   }
}

# Send the SSL Scan
sub fp_ssl($self, $host) {

   #TODO
   # async
   foreach my $p ( @{$self->ssl_utils->protocols_versions} ) {
      foreach my $c ( @{$self->ssl_utils->cipher_list->{$p}} ) {
         $self->get_cipher_from_dest($host, $p, $c);
      }
   }

   # Report
   my $lar = $report->get_report; #this is a reference for the report

   ### if there is something in the report
   # reuse it to append new SSL info
   if ( exists $lar->{$host} ) {
      my @all_keys = keys %{$lar->{$host}};
      my %new_repo;
      foreach my $ky (@all_keys) {
         $new_repo{$ky} = $lar->{$host}->{$ky};
      }
      $new_repo{'SSL'} = $self->supported_ciphers;
      $lar->{$host} =  { %new_repo };
   } else {
      $lar->{'SSL'} =  $self->supported_ciphers;
   }
}

# TODO need to implement in abstract class a genenic method
sub fp_send_request($self, $method, $host) {
   $self->fp_ssl($host);
}

1;

=item
### testing
my $f = MoktoWeb::Fingerprint::SSLInfo->new();
#$f->fp_x509('blog.kaiux.com');
$f->fp_ssl('blog.kaiux.com');
=cut
