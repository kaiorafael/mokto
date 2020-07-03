# Mokto
# Copyright (C) 2020 Kaio Barbosa (kaiux)
#
# This file is part of Mokto.

# Basic definition of how SSL/TLS protocols and ciphers are related
#
package MoktoWeb::Fingerprint::SSLUtils;
use Mojo::Base -base, -signatures;


has protocols_versions => sub {[
      qw(SSLv23 SSLv2 SSLv3 TLSv1 TLSv1_1 TLSv1_2 TLSv1_3)
   ]};

#protocols -> cipher lists
#openssl ciphers -tls1_0 -s | tr ":" "\n"
has cipher_list =>  sub {
   {
      SSLv23 => [],
      SSLv2 => [],
      SSLv3 => [],
      TLSv1 => [
         qw(
         ECDHE-ECDSA-AES256-SHA
         ECDHE-RSA-AES256-SHA
         DHE-RSA-AES256-SHA
         ECDHE-ECDSA-AES128-SHA
         ECDHE-RSA-AES128-SHA
         DHE-RSA-AES128-SHA
         AES256-SHA
         AES128-SHA
         )
      ],
      TLSv1_1 => [
         qw(
         ECDHE-ECDSA-AES256-SHA
         ECDHE-RSA-AES256-SHA
         DHE-RSA-AES256-SHA
         ECDHE-ECDSA-AES128-SHA
         ECDHE-RSA-AES128-SHA
         DHE-RSA-AES128-SHA
         AES256-SHA
         AES128-SHA
         )
      ],
      TLSv1_2 => [
         qw(
         ECDHE-ECDSA-AES256-GCM-SHA384
         ECDHE-RSA-AES256-GCM-SHA384
         DHE-RSA-AES256-GCM-SHA384
         ECDHE-ECDSA-CHACHA20-POLY1305
         ECDHE-RSA-CHACHA20-POLY1305
         DHE-RSA-CHACHA20-POLY1305
         ECDHE-ECDSA-AES128-GCM-SHA256
         ECDHE-RSA-AES128-GCM-SHA256
         DHE-RSA-AES128-GCM-SHA256
         ECDHE-ECDSA-AES256-SHA384
         ECDHE-RSA-AES256-SHA384
         DHE-RSA-AES256-SHA256
         ECDHE-ECDSA-AES128-SHA256
         ECDHE-RSA-AES128-SHA256
         DHE-RSA-AES128-SHA256
         ECDHE-ECDSA-AES256-SHA
         ECDHE-RSA-AES256-SHA
         DHE-RSA-AES256-SHA
         ECDHE-ECDSA-AES128-SHA
         ECDHE-RSA-AES128-SHA
         DHE-RSA-AES128-SHA
         AES256-GCM-SHA384
         AES128-GCM-SHA256
         AES256-SHA256
         AES128-SHA256
         AES256-SHA
         AES128-SHA
         )
      ],
      TLSv1_3 => [
         qw(
         TLS_AES_256_GCM_SHA384
         TLS_CHACHA20_POLY1305_SHA256
         TLS_AES_128_GCM_SHA256
         )
      ]
   }
};

1;

### testing
=item
my $f = MoktoWeb::Fingerprint::SSLUtils->new();
use Data::Dumper;
say Dumper $f->cipher_list->{'TLSv1_3'};
say Dumper $f->protocols_versions;
=cut
