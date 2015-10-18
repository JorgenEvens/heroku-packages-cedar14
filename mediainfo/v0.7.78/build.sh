#!/bin/sh

set -e

# Generates php-fpm and php-cli packages and php extension packages
# for use with the heroku modular buildpack
# https://github.com/JorgenEvens/heroku-modular-buildpack

### Configuration ###
test -z "$NAME" && >&2 echo "Package NAME not set." && exit 1
test -z "$VERSION" && >&2 echo "Version for $NAME not set." && exit 1

PACKAGE="${NAME}-${VERSION}"

OUTPUT_DIR="$1"
BUILD_DIR=`mktemp -d`
VENDOR="/app/vendor"
PREFIX="$VENDOR/$NAME"
VENDOR_DIR="`basename $PREFIX`"
ARCHIVE_NAME="${PACKAGE}.tar.gz"
ARCHIVE_LOCATION="${OUTPUT_DIR}/${PACKAGE}.tar.gz"

cd $BUILD_DIR

curl "http://mediaarea.net/download/binary/mediainfo/${VERSION}/MediaInfo_CLI_${VERSION}_GNU_FromSource.tar.gz" | tar -xz
cd MediaInfo*

./CLI_Compile.sh --with-libcurl --prefix="${PREFIX}"
cd "MediaInfo/Project/GNU/CLI" && DESTDIR="${BUILD_DIR}" make -j2 install

cd "${BUILD_DIR}${VENDOR}"

tar -caf "${ARCHIVE_LOCATION}" "${NAME}"

################################################
# Create installer script
################################################
MD5="$(md5sum ${ARCHIVE_LOCATION} | cut -d" " -f1)"

cat > "${OUTPUT_DIR}/${PACKAGE}.sh" << EOF
#!/bin/sh

unpack "\${INSTALLER_DIR}/${ARCHIVE_NAME}" "$MD5"

print_action "Generating configuration portion for $NAME $VERSION"
env_extend PATH "${PREFIX}/bin"

dependency_mark "${NAME}"
dependency_mark "${PACKAGE}"
EOF
