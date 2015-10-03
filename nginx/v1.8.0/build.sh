#!/bin/sh

set -e

OUT_DIR="$1"
BUILD_DIR=`mktemp -d`
VENDOR="/app/vendor"
PREFIX="$VENDOR/nginx"
VENDOR_DIR="`basename $PREFIX`"
NAME="nginx-1.8.0"

cd $BUILD_DIR

curl http://nginx.org/download/nginx-1.8.0.tar.gz | tar -xz
curl https://codeload.github.com/wandenberg/nginx-push-stream-module/tar.gz/0.5.1 | tar -xz
curl https://codeload.github.com/openresty/set-misc-nginx-module/tar.gz/v0.29 | tar -xz
curl https://codeload.github.com/openresty/redis2-nginx-module/tar.gz/v0.12 | tar -xz
curl https://codeload.github.com/openresty/lua-nginx-module/tar.gz/v0.9.16 | tar -xz
curl https://codeload.github.com/openresty/xss-nginx-module/tar.gz/v0.05 | tar -xz
curl https://codeload.github.com/FRiCKLE/ngx_cache_purge/tar.gz/2.3 | tar -xz
curl https://codeload.github.com/simpl/ngx_devel_kit/tar.gz/v0.2.19 | tar -xz
curl ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.37.tar.gz | tar -xz

mkdir -p ${BUILD_DIR}/$VENDOR
cd ${BUILD_DIR}/$VENDOR
tar -xf ${OUT_DIR}/deps/geoip.tar.gz
tar -xf ${OUT_DIR}/deps/luajit.tar.gz

cd ${BUILD_DIR}/nginx-*

export LUAJIT_LIB="${BUILD_DIR}${VENDOR}/luajit/lib"
export LUAJIT_INC="${BUILD_DIR}${VENDOR}/luajit/include/luajit-2.0"

./configure \
    --with-pcre=${BUILD_DIR}/pcre-* \
    --prefix=$PREFIX \
    --with-select_module \
    --with-http_gzip_static_module \
    --with-http_geoip_module \
    --with-http_secure_link_module \
    --without-poll_module \
    --without-http_ssi_module \
    --without-http_userid_module \
    --without-http_access_module \
    --without-http_autoindex_module \
    --without-http_map_module \
    --without-http_split_clients_module \
    --without-http_proxy_module \
    --without-http_uwsgi_module \
    --without-http_scgi_module \
    --without-http_memcached_module \
    --without-http_limit_conn_module \
    --without-http_limit_req_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --without-mail_smtp_module \
    --add-module=${BUILD_DIR}/ngx_devel_kit-* \
    --add-module=${BUILD_DIR}/ngx_cache_purge-* \
    --add-module=${BUILD_DIR}/xss-nginx-module-* \
    --add-module=${BUILD_DIR}/lua-nginx-module-* \
    --add-module=${BUILD_DIR}/redis2-nginx-module-* \
    --add-module=${BUILD_DIR}/nginx-push-stream-module-* \
    --add-module=${BUILD_DIR}/set-misc-nginx-module-* \
    --with-cc-opt="-I${BUILD_DIR}${VENDOR}/geoip/include" \
    --with-ld-opt="-L${BUILD_DIR}${VENDOR}/geoip/lib"

make
make install DESTDIR="$BUILD_DIR"

cd ${BUILD_DIR}${PREFIX}

# Disabled daemonization
NGINX_CONF="${BUILD_DIR}${PREFIX}/conf/nginx.conf"
mv "${NGINX_CONF}" "${NGINX_CONF}.orig"
echo "daemon off;" > "${NGINX_CONF}"
cat "${NGINX_CONF}.orig" >> "${NGINX_CONF}"
rm "${NGINX_CONF}.orig"

# Set application root to /app/src
sed -i "s/root\s\+[^;]\+/root \/app\/src/g" "${NGINX_CONF}"

cd ${BUILD_DIR}${VENDOR}
tar -caf ${OUT_DIR}/$NAME.tar.gz $VENDOR_DIR

cat > ${OUT_DIR}/$NAME.sh << EOF
#!/bin/sh

dependency_require luajit-2.0.4

unpack "\$INSTALLER_DIR/$NAME.tar.gz" `md5sum $OUT_DIR/$NAME.tar.gz | cut -d" " -f1`
echo 'sed -i "s/listen\s\+80;/listen \$PORT;/g" "/app/vendor/nginx/conf/nginx.conf"' >> "\${BUILD_DIR}/boot.sh"
echo "/app/vendor/nginx/sbin/nginx &" >> "\${BUILD_DIR}/boot.sh"
EOF
