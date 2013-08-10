#!/bin/sh

NODEJS_VERSION="0.10.15"
NODEJS_HOST="https://s3-eu-west-1.amazonaws.com/bubobox.deploy/heroku/nodejs"
NODEJS_MD5="17006b33e17569c82b4d007ced28b829"

nodejs_compile() {
	VERSION=$NODEJS_VERSION
	BINARIES="${CACHE_DIR}/nodejs-${VERSION}.tar.gz"

	nodejs_download "$BINARIES"
	nodejs_install "$BINARIES"
	nodejs_generate_profile
}

nodejs_download() {
	TARGET=$1
	HOST=$NODEJS_HOST
	URL="${HOST}/$(basename $TARGET)"

	print_action "Downloading Nginx ${NODEJS_VERSION} from ${URL} to ${TARGET}"
	cached_download "$URL" "$TARGET" "${NODEJS_MD5}"
}

nodejs_install() {
	print_action "Installing Nginx ${NODEJS_VERSION} to ${BUILD_DIR}/vendor"

	mkdir -p "${BUILD_DIR}/vendor"

	CUR_DIR=`pwd`

	# Extract Nginx
	cd "${BUILD_DIR}/vendor"
	rm -R nodejs 2> /dev/null
	tar -xf "${BINARIES}"

	# Return to original directory
	cd "$CUR_DIR"
}

nodejs_generate_profile() {
	print_action "Generating .profile"
	echo "export PATH=\"\$PATH:/app/vendor/nodejs/bin\"" >> "${BUILD_DIR}/.profile"
	
}

nodejs_compile