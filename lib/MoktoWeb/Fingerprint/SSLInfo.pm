package MoktoWeb::Fingerprint::SSLInfo;

use Mojo::Base -base, -signatures;
use IO::Socket::SSL;
use Data::Dumper;
use MIME::Base64 ();
use Crypt::X509;

# set as array (this is UGLY)
#has supported_ciphers => sub {[]};
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
   #say $host;
   my $client = undef;
   $client = IO::Socket::SSL->new(
      PeerHost => $host,
      PeerPort => "https",
      #SSL_version => '!SSLv23:!SSLv2:!SSLv3:!TLSv1_1:TLSv1_2:!TLSv1_3',
      SSL_version => $p_version,
      SSL_cipher_list => $s_cipher

   ) or do {
      #warn "boiz failed connect or ssl handshake: $!,$SSL_ERROR";
      #print color('reset');
      #print color('bold red');
      say "Not support $s_cipher";
      ;
   };

   ### Means that Protocol and Cipher works
   if ( $client ) {
      #print color('reset');
      #print color('bold green');
      #print "Current cipher: " .$client->get_cipher() . "\n";
      push @{ $self->supported_ciphers->{$p_version} }, $client->get_cipher();
      #say $client->get_sslversion();
      close $client;
   }
}

sub fp_ssl($self, $host) {
   my $list = 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';
   my @clist = split(/:/, $list);
   use Term::ANSIColor;
   my @protocols_version = qw(SSLv23 SSLv2 SSLv3 TLSv1_1 TLSv1_2 TLSv1_3);
   foreach my $p (@protocols_version) {
      foreach my $mc ( @clist ) { 
         #print color('bold blue');
         #say "Testing: $mc";
         $self->get_cipher_from_dest($host, $p, $mc);
      }
   }

   ### get the result from the scan
   for my $key ( keys %{ $self->supported_ciphers } ) {
      my $sz = scalar @{ $self->supported_ciphers->{$key} };
      if ( $sz ge 1 ) {
         say "Supported ciphers $key: $sz";
         for my $c ( @{ $self->supported_ciphers->{$key} } ) {
            print color('bold green');
            say "\t $c";
         }
         print color('reset');
      }
   }
}

1;

### testing
my $f = MoktoWeb::Fingerprint::SSLInfo->new();
#$f->fp_x509('blog.kaiux.com');
$f->fp_ssl('blog.kaiux.com');
#

