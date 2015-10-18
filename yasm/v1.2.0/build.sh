#!/bin/sh

set -e

test -z "$NAME" && >&2 echo "Package NAME not set." && exit 1
test -z "$VERSION" && >&2 echo "Version for $NAME not set." && exit 1

OUT_DIR="$1"
BUILD_DIR=`mktemp -d`
VENDOR_DIR="/app/vendor"
PREFIX="${VENDOR_DIR}/${NAME}"
PACKAGE="${NAME}-${VERSION}"

cd $BUILD_DIR
echo http://www.tortall.net/projects/yasm/releases/${PACKAGE}.tar.gz
curl "http://www.tortall.net/projects/yasm/releases/${PACKAGE}.tar.gz" | tar -xz

cd ${NAME}-*
./configure --prefix="${PREFIX}"
make -j2
DESTDIR="${BUILD_DIR}" make install

cd "${BUILD_DIR}${PREFIX}"
rm -Rf share

cd "${BUILD_DIR}${VENDOR_DIR}"
tar -caf "${OUT_DIR}/${PACKAGE}.tar.gz" "$NAME"

cat > "${OUT_DIR}/$PACKAGE.sh" << EOF
#!/bin/sh

unpack "\$INSTALLER_DIR/$PACKAGE.tar.gz" `md5sum $OUT_DIR/$PACKAGE.tar.gz | cut -d" " -f1`
env_extend PATH "${PREFIX}/bin"
env_extend LD_LIBRARY_PATH "${PREFIX}/lib"
EOF
