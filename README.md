# mokto
a Web fingerprint tool written in Mojolicious

# How to use?

```
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
   perl mokto.pl --host yourhost.com 

   # Using SSL fingerprint
   perl mokto.pl -h yourhost.com -s http_ssl_fingerprint

   # Default bulk HEAD scan
   perl mokto.pl --mhosts /tmp/hosts_file

```
