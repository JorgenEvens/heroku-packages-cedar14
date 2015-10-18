#!/bin/sh

set -e

test -z "$NAME" && >&2 echo "Package NAME not set." && exit 1
test -z "$VERSION" && >&2 echo "Version for $NAME not set." && exit 1

OUT_DIR="$1"
BUILD_DIR=`mktemp -d`
VENDOR="/app/vendor"
PREFIX="${VENDOR}/${NAME}"
VENDOR_DIR="`basename $PREFIX`"
PACKAGE="${NAME}-${VERSION}"

cd $BUILD_DIR
curl "https://codeload.github.com/maxmind/geoip-api-c/tar.gz/v${VERSION}" | tar -xz

cd ${NAME}-*
./bootstrap
./configure --prefix="$PREFIX"
make -j2
make install DESTDIR=${BUILD_DIR}

cd ${BUILD_DIR}${PREFIX}
rm -Rf share

cd ..
tar -caf "${OUT_DIR}/$PACKAGE.tar.gz" "$VENDOR_DIR"

cat > "${OUT_DIR}/$PACKAGE.sh" << EOF
#!/bin/sh

unpack "\$INSTALLER_DIR/$PACKAGE.tar.gz" `md5sum $OUT_DIR/$PACKAGE.tar.gz | cut -d" " -f1`
env_extend PATH "${PREFIX}/bin"
env_extend LD_LIBRARY_PATH "${PREFIX}/lib"
EOF
