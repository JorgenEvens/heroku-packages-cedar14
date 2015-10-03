#!/bin/sh

set -e

test -z "$NAME" && >&2 echo "Package NAME not set." && exit 1
test -z "$VERSION" && >&2 echo "Version for $NAME not set." && exit 1

OUT_DIR="$1"
BUILD_DIR=`mktemp -d`
VENDOR="/app/vendor"
PREFIX="${VENDOR}/geoip"
VENDOR_DIR="`basename $PREFIX`"
PACKAGE="${NAME}-${VERSION}"

cd $BUILD_DIR
curl "https://codeload.github.com/maxmind/geoip-api-c/tar.gz/v${VERSION}" | tar -xz

cd ${NAME}-*
./bootstrap
./configure --prefix="$PREFIX"
make
make install DESTDIR=${BUILD_DIR}

cd ${BUILD_DIR}${PREFIX}
rm -Rf share

cd ..
tar -caf ${OUT_DIR}/$PACKAGE.tar.gz $VENDOR_DIR

cat > ${OUT_DIR}/$PACKAGE.sh << EOF
#!/bin/sh

unpack "\$INSTALLER_DIR/$PACKAGE.tar.gz" `md5sum $OUT_DIR/$PACKAGE.tar.gz | cut -d" " -f1`
echo 'export LD_LIBRARY_PATH="\$LD_LIBRARY_PATH:/app/vendor/geoip/lib"' >> \${BUILD_DIR}/.profile
echo 'export PATH="\$PATH:/app/vendor/geoip/bin"' >> \${BUILD_DIR}/.profile
EOF
