#!/bin/sh -e

ROOT_DIR="$(pwd)"

# GIT FETCH, CHECKOUT AND PATCH
STEP="step.000"
if [ ! -e "${STEP}" ] ; then
	mkdir -p nuxeo-builder_build-volume/nuxeo
	git clone git://github.com/nuxeo/nuxeo.git nuxeo-builder_build-volume/nuxeo
#	VERSION="release-7.10-HF47"
	VERSION="release-7.10-HF35"
	cd "${ROOT_DIR}/nuxeo-builder_build-volume/nuxeo"
	git checkout "${VERSION}"
	git am "${ROOT_DIR}/patches/nuxeo/0001-Use-custom-nexus-repo-for-hotfix-releases.patch"

	cd "${ROOT_DIR}/nuxeo-builder_build-volume"
	ADDON="marketplace-dam"
	VERSION="release-6.1.4"
	git clone git://github.com/nuxeo/${ADDON}
	cd "${ADDON}"
	git checkout "${VERSION}" 
	git am "${ROOT_DIR}/patches/${ADDON}/*.patch"

	cd "${ROOT_DIR}/nuxeo-builder_build-volume"
	ADDON="marketplace-diff"
	VERSION="release-1.6.5"
	git clone git://github.com/nuxeo/${ADDON}
	cd "${ADDON}"
	git checkout "${VERSION}" 
	git am "${ROOT_DIR}/patches/${ADDON}/*.patch"

	cd "${ROOT_DIR}/nuxeo-builder_build-volume"
	ADDON="marketplace-diff-pictures"
	VERSION="release-1.0.2"
	git clone git://github.com/nuxeo/${ADDON}
	cd "${ADDON}"
	git checkout "${VERSION}" 

	cd "${ROOT_DIR}/nuxeo-builder_build-volume"
	ADDON="marketplace-template-rendering"
	VERSION="release-6.5.4"
	git clone git://github.com/nuxeo/${ADDON}
	cd "${ADDON}"
	git checkout "${VERSION}" 

	cd "${ROOT_DIR}/nuxeo-builder_build-volume"
	ADDON="marketplace-virtualnavigation"
	VERSION="release-1.1.4"
	git clone git://github.com/nuxeo/${ADDON}
	cd "${ADDON}"
	git checkout "${VERSION}" 
	git am "${ROOT_DIR}/patches/${ADDON}/*.patch"

	cd "${ROOT_DIR}/nuxeo-builder_build-volume"
	ADDON="marketplace-drive"
	VERSION="release-1.5.11"
	git clone git://github.com/nuxeo/${ADDON}
	cd "${ADDON}"
	git checkout "${VERSION}" 

	cd "${ROOT_DIR}/nuxeo-builder_build-volume"
	git clone git://github.com/aritu/eloraplm.git

	touch "${STEP}"
fi

STEP="step.001"
if [ ! -e "${STEP}" ] ; then
	docker-compose -f docker-compose.yaml build
	touch "${STEP}"
fi
STEP="step.002"
if [ ! -e "${STEP}" ] ; then
	docker-compose -f docker-compose.yaml run nuxeo-builder python clone.py
	touch "${STEP}"
fi
STEP="step.003"
if [ ! -e "${STEP}" ] ; then
	docker-compose -f docker-compose.yaml run nuxeo-builder /bin/sh -c '
	export MAVEN_OPTS="-Xmx4096m -Xms1024m" && 
	mvn clean install -Paddons,distrib,sdk -DskipTests -DskipITs &&
	mvn deploy -Paddons,distrib,sdk -DskipTests -DskipITs &&
	cd /media/build-volume/marketplace-dam &&
	mvn clean install -DskipTests &&
	cd /media/build-volume/marketplace-diff &&
	mvn clean install -DskipTests &&
	cd /media/build-volume/marketplace-diff-pictures &&
	mvn clean install -DskipTests &&
	cd /media/build-volume/marketplace-template-rendering &&
	mvn clean install -DskipTests &&
	cd /media/build-volume/marketplace-virtualnavigation &&
	mvn clean install -DskipTests &&
	cd /media/build-volume/marketplace-drive &&
	mvn clean install -DskipTests &&
	cd /media/build-volume/eloraplm &&
	mvn clean install -DskipTests
			'
	touch "${STEP}"
fi
