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
