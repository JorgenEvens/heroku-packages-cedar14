#!/bin/sh

set -e

test -z "$NAME" && >&2 echo "Name not set for PECL package" && exit 1
test -z "$VERSION" && >&2 echo "Version not set for PECL package $NAME" && exit 1
PACKAGE="${NAME}-${VERSION}"

test -z "$PHP_NAME" && PHP_NAME="php5-fpm"
test -z "$PHP_VERSION" && PHP_VERSION="5.5.18"

OUT_DIR="$1"
BUILD_DIR=`mktemp -d`
VENDOR_DIR="/app/vendor"
DEP_DIR="${OUT_DIR}/deps"
PREFIX="${VENDOR_DIR}/${PHP_NAME}"

cd "${BUILD_DIR}"

################################################
# Unpack PHP
################################################

tar -xf "${DEP_DIR}/${PHP_NAME}.tar.gz"
export PATH="$PATH:${BUILD_DIR}/${PHP_NAME}/bin:${BUILD_DIR}/${PHP_NAME}/sbin"

# Link build dir to /app for phpize
mkdir -p /app
ln -s "${BUILD_DIR}" "${VENDOR_DIR}"

################################################
# Build Redis Plugin
################################################
if [ "$VERSION" = "git" ]; then
    git clone "$GIT_URL" "${PACKAGE}"
else
    curl "https://pecl.php.net/get/${PACKAGE}.tgz" | tar -xz
fi

cd ${NAME}-*

# Configure phpredis
phpize
./configure --prefix="$PREFIX"

# Build it
make
INSTALL_ROOT="${BUILD_DIR}" make install

################################################
# Create archive
################################################

cd "${BUILD_DIR}${VENDOR_DIR}"
ARCHIVE_NAME="${PHP_NAME}-${PACKAGE}.tar.gz"
ARCHIVE_LOCATION="${OUT_DIR}/${ARCHIVE_NAME}"
tar -caf "${ARCHIVE_LOCATION}" "${PHP_NAME}"

################################################
# Create installer script
################################################
MD5="$(md5sum ${ARCHIVE_LOCATION} | cut -d" " -f1)"

cat > "${OUT_DIR}/$(PHP_NAME)-${PACKAGE}.sh" << EOF
#!/bin/sh

dependency_require "php-$PHP_VERSION"

unpack "\${INSTALLER_DIR}/${ARCHIVE_NAME}" "$MD5"
php5_ext_enable "${NAME}"
EOF