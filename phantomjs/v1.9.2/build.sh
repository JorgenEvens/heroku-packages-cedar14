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
VERSION_MAJOR="$(echo ${VERSION} | grep -P -o '\d+\.\d+' | head -n1)"
curl "https://phantomjs.googlecode.com/files/phantomjs-${VERSION}-linux-x86_64.tar.bz2" | tar -xj

cd ${NAME}-*
mkdir -p "${BUILD_DIR}${PREFIX}"
mv "bin" "${BUILD_DIR}${PREFIX}/bin"

cd "${BUILD_DIR}${VENDOR_DIR}"
tar -caf "${OUT_DIR}/${PACKAGE}.tar.gz" "$NAME"

cat > "${OUT_DIR}/$PACKAGE.sh" << EOF
#!/bin/sh

unpack "\$INSTALLER_DIR/$PACKAGE.tar.gz" `md5sum $OUT_DIR/$PACKAGE.tar.gz | cut -d" " -f1`
env_extend PATH "${PREFIX}/bin"
EOF
