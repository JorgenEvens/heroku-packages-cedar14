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

curl "http://netcologne.dl.sourceforge.net/project/mcrypt/Libmcrypt/${VERSION}/$PACKAGE.tar.gz" | tar -xz
cd ${NAME}-*
./configure --prefix="$PREFIX"
make -j2
make install DESTDIR="$BUILD_DIR"

cd "${BUILD_DIR}${PREFIX}"
rm -Rf man
cd ..
tar -caf "${OUT_DIR}/${PACKAGE}.tar.gz" "${NAME}"

cat > "${OUT_DIR}/$PACKAGE.sh" << EOF
#!/bin/sh

unpack "\$INSTALLER_DIR/$PACKAGE.tar.gz" `md5sum $OUT_DIR/$PACKAGE.tar.gz | cut -d" " -f1`
env_extend LD_LIBRARY_PATH "${PREFIX}/lib"
EOF