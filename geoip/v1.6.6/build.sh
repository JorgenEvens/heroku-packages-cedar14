#!/bin/sh

set -e

OUT_DIR="$1"
BUILD_DIR=`mktemp -d`
VENDOR="/app/vendor"
PREFIX="${VENDOR}/geoip"
VENDOR_DIR="`basename $PREFIX`"
NAME="geoip-1.6.6"

cd $BUILD_DIR
curl https://codeload.github.com/maxmind/geoip-api-c/tar.gz/v1.6.6 | tar -xz

cd geoip-*
./bootstrap
./configure --prefix="$PREFIX"
make
make install DESTDIR=${BUILD_DIR}

cd ${BUILD_DIR}${PREFIX}
rm -Rf share

cd ..
tar -caf ${OUT_DIR}/$NAME.tar.gz $VENDOR_DIR

cat > ${OUT_DIR}/$NAME.sh << EOF
#!/bin/sh

unpack "\$INSTALLER_DIR/$NAME.tar.gz" `md5sum $OUT_DIR/$NAME.tar.gz | cut -d" " -f1`
echo 'export LD_LIBRARY_PATH="\$LD_LIBRARY_PATH:/app/vendor/geoip/lib"' >> \${BUILD_DIR}/.profile
echo 'export PATH="\$PATH:/app/vendor/geoip/bin"' >> \${BUILD_DIR}/.profile
EOF
