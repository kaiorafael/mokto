package MoktoUtils;
use Carp;
use Mojo::Base -base, -signatures;
use IO::File;

### global vars
my %http_methods = ( 'HEAD' => undef, 'GET' => undef , 'DELETE' => undef);
my $default_method = 'HEAD';
our %f = ( 'foo' => 'bar');

sub get_default_method {
   return $default_method;
}

sub is_valid_http_method($self, $method) {
   say "";
   if ( not exists($http_methods{$method}) ) {
      carp ("Invalid HTTP method : $method");
      usage();
   }
}

sub valid_scan_type($self, $type) {
   my %scan = (
      default => 'http_header_fingerprint',
      http_header_fingerprint => "http_header_fingerprint",
      http_ssl_fingerprint => "http_ssl_fingerprint"
   );

   die "Unsupported scan type: $type" if not exists $scan{$type};
   # if dont break, just return
   return $scan{$type};
}

sub usage {
   say "";
   my $myhelp= <<EOF;
   --method
      [HEAD, GET, DELETE]
   --host
      host or domain to be scanned
   --scan
      http_header_fingerprint: performs a head/get to get host headers
                               the scan checks for OWASP best security headers

      http_ssl_fingerprint:    list all protocols and cipher supported
                               this scan type is dependable of OpenSSL compilation

   --mhosts
      file: This option performs scan check in multiple hosts in a file.
                Each host/domain perl line.

   Examples:

   # Default HEAD scan (http_header_fingerprint)
   perl mokto.pl --host blog.kaiux.com

   # Default bulk HEAD scan
   perl mokto.pl --mhosts /tmp/hosts_file
EOF
   say $myhelp;
   exit;
}

# returns an array reference if file is okay
sub load_file($self, $filename) {
   my @ur;
   my $fh = IO::File->new($filename, "r");
   if (defined $fh) {
      for my $u (<$fh>) {
         chomp($u);
         push @ur, $u;
      }
      undef $fh;       # automatically closes the file
   } else {
      croak "Make to sure to provide a valid file name: $filename";
   }

   return \@ur

}

1;
