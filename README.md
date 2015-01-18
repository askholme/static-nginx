Travis: [![Build Status](https://travis-ci.org/askholme/static-nginx.svg?branch=master)](https://travis-ci.org/askholme/static-nginx) 
Bintray: [![Download](https://api.bintray.com/packages/askholme/static-software/nginx/images/download.svg) ](https://bintray.com/askholme/static-software/nginx/_latestVersion)
# Compile a statically linked nginx inside docker

Scripts for compiling a production ready statically linked nginx using a docker container.
The resulting binaries are available on bintray and are perfect for inclusion to a small (eg. busybox based) docker container.

The binary includes the following modules:
* Modsecurity
* SSL
* SPDY
* Stub status
* gzip static
* DAV
* Realip

That means that a bunch of others are excluded
* SSI
* Userid
* Autoindex
* Geo
* Map
* Split clients
* Scgi
* Memcached
* Empty gif
* Browser
* Upstream ip hash
* POP3
* IMAP
* SMTP