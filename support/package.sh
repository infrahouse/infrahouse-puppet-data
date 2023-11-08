#!/usr/bin/env bash

set -eux

pkg_name="infrahouse-puppet-data"
upstream_version=$(head -1 debian/changelog | awk '{ print $2 }' | sed -e 's/[()]//g' | awk -F- '{ print $1 }')
TMPDIR=$(mktemp -d)

DEBEMAIL=${DEBEMAIL-packager@infrahouse.com}
DEBFULLNAME=${DEBFULLNAME-InfraHouse Packager}

cleanup () {
  rm -rf "${TMPDIR}"
}

trap cleanup ERR
trap cleanup EXIT

mkdir "${TMPDIR}/${pkg_name}_${upstream_version}"
cp -R environments LICENSE README.md "${TMPDIR}/${pkg_name}_${upstream_version}"

tar zcf "../${pkg_name}_${upstream_version}.orig.tar.gz" -C "${TMPDIR}" "${pkg_name}_${upstream_version}"
debuild --build=all -us -uc
