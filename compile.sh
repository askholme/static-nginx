#!/bin/bash
NGINX_TARBALL="nginx-${NGINX_VERSION}.tar.gz"
PCRE_TARBALL="pcre-${PCRE_VERSION}.tar.gz"
OPENSSL_TARBALL="openssl-${OPENSSL_VERSION}.tar.gz"
ZLIB_TARBALL="zlib-${ZLIB_VERSION}.tar.gz"

rm -rf nginx*
rm -rf pcre-*
rm -rf openssl-*
rm -rf zlib-*
rm -rf mod_security
if [[ -d "nginx" ]]; then
  rm -rf nginx
fi
 
CWD=$(pwd)
DATE=`date +"%Y-%m-%d %H:%M:%S"`
touch .timestamp
if [[ ! -d "${NGINX_TARBALL%.tar.gz}" ]]; then
  wget "http://nginx.org/download/${NGINX_TARBALL}"
  tar --no-same-owner --mtime=.timestamp -xvzf "${NGINX_TARBALL}" && rm -f "${NGINX_TARBALL}"
  find "${NGINX_TARBALL%.tar.gz}" -print0 |xargs -0 touch --date="$DATE"
fi
 
if [[ ! -d "${PCRE_TARBALL%.tar.gz}" ]]; then
  wget "http://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${PCRE_TARBALL}"
  tar --no-same-owner --mtime=.timestamp -xvzf "${PCRE_TARBALL}" && rm -f "${PCRE_TARBALL}"
  find "${PCRE_TARBALL%.tar.gz}" -print0 |xargs -0 touch --date="$DATE"
fi
 
if [[ ! -d "${OPENSSL_TARBALL%.tar.gz}" ]]; then
  wget "http://www.openssl.org/source/${OPENSSL_TARBALL}"
  tar --no-same-owner --mtime=.timestamp -xvzf "${OPENSSL_TARBALL}" && rm -f "${OPENSSL_TARBALL}"
  find "${OPENSSL_TARBALL%.tar.gz}" -print0 |xargs -0 touch --date="$DATE"
fi
 
if [[ ! -d "${ZLIB_TARBALL%.tar.gz}" ]]; then
  wget "http://zlib.net/${ZLIB_TARBALL}"
  tar --no-same-owner --mtime=.timestamp -xvzf "${ZLIB_TARBALL}" && rm -rf "${ZLIB_TARBALL}"
  find "${ZLIB_TARBALL%.tar.gz}" -print0 |xargs -0 touch --date="$DATE"
fi

git clone https://github.com/SpiderLabs/ModSecurity.git $CWD/mod_security
cd $CWD/mod_security
./autogen.sh
./configure --enable-standalone-module
make

mkdir -p $CWD/target/bin/ 
cd $CWD/nginx-${NGINX_VERSION}
./configure \
  --with-cpu-opt=generic \
  --prefix=$CWD/target/bin \
  --with-pcre=../pcre-${PCRE_VERSION} \
  --sbin-path=. \
  --pid-path=./nginx.pid \
  --conf-path=./nginx.conf \
  --error-log-path=./error.log \
  --http-log-path=./access.log \
  --with-openssl-opt=no-krb5 \
  --with-ld-opt="-static" \
  --with-openssl=../openssl-${OPENSSL_VERSION} \
  --with-http_ssl_module \
  --with-http_spdy_module \
  --with-http_stub_status_module \
  --with-http_gzip_static_module \
  --with-http_dav_module \
  --with-http_realip_module \
  --with-file-aio \
  --with-zlib=../zlib-${ZLIB_VERSION} \
  --with-pcre \
  --with-ipv6 \
  --with-cc-opt="-O2 -static -static-libgcc" \
  --without-http_ssi_module \
  --without-http_userid_module \
  --without-http_autoindex_module \
  --without-http_geo_module \
  --without-http_map_module \
  --without-http_split_clients_module \
  --without-http_scgi_module \
  --without-http_memcached_module \
  --without-http_empty_gif_module \
  --without-http_browser_module \
  --without-http_upstream_ip_hash_module \
  --without-mail_pop3_module \
  --without-mail_imap_module \
  --without-mail_smtp_module
  --add-module=$CWD/mod_security/nginx/modsecurity
sed -i "/CFLAGS/s/ \-O //g" objs/Makefile
#patch the buffer size - not needed for 1.5.9+
#sed -i -e "s/\#define NGX_SSL_PASSWORD_BUFFER_SIZE  4096/\#define NGX_SSL_PASSWORD_BUFFER_SIZE  16384/g" src/event/ngx_event_openssl.c
make && make install


cp LICENSE $CWD/target/bin
cp $CWD/nginx-${NGINX_VERSION}/LICENSE $CWD/target/bin/license-nginx
cp $CWD/mod_security/LICENSE $CWD/target/bin/license-modsecurity
cp $CWD/zlib-${ZLIB_VERSION}/README $CWD/target/bin/license-zlib
cp $CWD/openssl-${OPENSSL_VERSION}/LICENSE $CWD/target/bin/license-openssl
cp $CWD/pcre-${PCRE_VERSION}/LICENSE $CWD/target/bin/license-pcre
cat << EOF > $CWD/target/bin/README
Statically linkedn nginx binary for production use.
This is compiled with modsecurity inside it. 
See http://github.com/askholme/static-nginx for more
EOF
cd $CWD/target/bin/
tar czf $CWD/nginx.tar.gz .