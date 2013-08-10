#!/bin/sh

NGINXRTMP_VERSION="1.4.2"
NGINXRTMP_HOST="http://jorgen.evens.eu/heroku/nginx"
NGINXRTMP_MD5="4ccd4f75ae1421d5e80049e308c5b5e8"

nginxrmtp_compile() {
	VERSION=$NGINXRTMP_VERSION
	BINARIES="${CACHE_DIR}/nginx-rmtp-${VERSION}.tar.gz"

	nginxrmtp_download "$BINARIES"
	nginxrmtp_install "$BINARIES"
	nginxrmtp_generate_boot
}

nginxrmtp_download() {
	TARGET=$1
	HOST=$NGINXRTMP_HOST
	URL="${HOST}/$(basename $TARGET)"

	print_action "Downloading Nginx with rtmp ${NGINXRTMP_VERSION} from ${URL} to ${TARGET}"
	cached_download "$URL" "$TARGET" "${NGINXRTMP_MD5}"
}

nginxrmtp_install() {
	print_action "Installing Nginx with rtmp ${NGINXRTMP_VERSION} to ${BUILD_DIR}/vendor"

	mkdir -p "${BUILD_DIR}/vendor"

	CUR_DIR=`pwd`

	# Extract Nginx
	cd "${BUILD_DIR}/vendor"
	rm -R nginx 2> /dev/null
	tar -xf "${BINARIES}"

	# Disabled daemonization
	NGINXRTMP_CONF="${BUILD_DIR}/vendor/nginx/conf/nginx.conf"
	mv "${NGINXRTMP_CONF}" "${NGINXRTMP_CONF}.orig"
	echo "daemon off;" > "${NGINXRTMP_CONF}"
	cat "${NGINXRTMP_CONF}.orig" >> "${NGINXRTMP_CONF}"
	rm "${NGINXRTMP_CONF}.orig"

	sed -i "s/root\s\+[^;]\+/root \/app\/src/g" "${NGINXRTMP_CONF}"

	# Return to original directory
	cd "$CUR_DIR"
}

nginxrmtp_generate_boot() {
	print_action "Generating boot portion for nginx-rmtp"
	echo 'sed -i "s/listen\s\+80;/listen $PORT;/g" "/app/vendor/nginx/conf/nginx.conf"' >> "${BUILD_DIR}/boot.sh"
	echo "/app/vendor/nginx/sbin/nginx &" >> "${BUILD_DIR}/boot.sh"
}

nginxrmtp_compile