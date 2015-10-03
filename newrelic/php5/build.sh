#!/bin/sh

set -e

test -z "$NAME" && >&2 echo "Package NAME not set." && exit 1
test -z "$VERSION" && >&2 echo "Version for $NAME not set." && exit 1

PHP_NAME="php5-fpm"
test -z "$PHP_VERSION" && PHP_VERSION="5.5.18"
test -z "$PHP_API_VERSION" && PHP_API_VERSION="20121212"

PACKAGE="${NAME}-${VERSION}"

OUT_DIR="$1"
BUILD_DIR=`mktemp -d`
VENDOR_DIR="/app/vendor"
DEP_DIR="${OUT_DIR}/deps"
PREFIX="${VENDOR_DIR}/${PHP_NAME}"
PHP_INSTALL_DIR="${BUILD_DIR}${PREFIX}/"
CONFIG_FILE="${PREFIX}/etc/conf.d/newrelic.ini"

cd "${BUILD_DIR}"

curl "https://download.newrelic.com/php_agent/release/${PACKAGE}-linux.tar.gz" | tar -xz
cd ${NAME}-*

mkdir -p "${PHP_INSTALL_DIR}/lib/php/${PHP_API_VERSION}"
cp "agent/x64/newrelic-${PHP_API_VERSION}.so" "${PHP_INSTALL_DIR}/lib/php/${PHP_API_VERSION}/${NAME}.so"

mkdir -p "`dirname \"${BUILD_DIR}/${CONFIG_FILE}\"`"
mkdir -p "${BUILD_DIR}${VENDOR_DIR}/${NAME}/log"

cp "daemon/newrelic-daemon.x64" "${BUILD_DIR}/${VENDOR_DIR}/${NAME}/newrelic-daemon"

cat >> "${BUILD_DIR}/${CONFIG_FILE}" << EOF
[newrelic]
newrelic.license = "REPLACE_WITH_REAL_KEY"
newrelic.logfile = "${VENDOR_DIR}/${NAME}/log/php_agent.log"
newrelic.appname = "PHP Application"

newrelic.daemon.location = "${VENDOR_DIR}/${NAME}/newrelic-daemon"
newrelic.daemon.port = "${VENDOR_DIR}/${NAME}/.socket"
newrelic.daemon.logfile = "${VENDOR_DIR}/${NAME}/log/daemon.log"
EOF

################################################
# Create archive
################################################

cd "${BUILD_DIR}${VENDOR_DIR}"
ARCHIVE_NAME="${PACKAGE}.tar.gz"
ARCHIVE_LOCATION="${OUT_DIR}/${ARCHIVE_NAME}"
tar -caf "${ARCHIVE_LOCATION}" "${PHP_NAME}" "${NAME}"

################################################
# Create installer script
################################################
MD5="$(md5sum ${ARCHIVE_LOCATION} | cut -d" " -f1)"

cat > "${OUT_DIR}/${PACKAGE}.sh" << EOF
#!/bin/sh

dependency_require "php-$PHP_VERSION"

unpack "\${INSTALLER_DIR}/${ARCHIVE_NAME}" "$MD5"
php5_ext_enable "${NAME}"

echo "sed -i \"s/REPLACE_WITH_REAL_KEY/\\\$NEW_RELIC_LICENSE_KEY/\" ${CONFIG_FILE}" > "\${BUILD_DIR}/configure.sh"
EOF