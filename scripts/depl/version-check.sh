#!/bin/bash

VERSION_FILE="./version"
CACHE_VERSION_FILE="./cache-version"

deploy () {
	SERVICE_NAME=$1
	SERVICE_VERSION=$2

	echo "Deploying ${SERVICE_NAME} ${SERVICE_VERSION}"

	docker run "${SERVICE_NAME}:latest"
}

cache_version () {
	cp $VERSION_FILE $CACHE_VERSION_FILE
}

compare_version_files () {
	while read -r VERSION_LINE; do
		IFS=":" VERSION_ARR=($VERSION_LINE)
		DEPLOY_FLAG=true

		while read -r CACHE_LINE; do
			IFS=":" CACHE_ARR=($CACHE_LINE)

			if [[ "$VERSION_ARR[0]" == "$CACHE_ARR[0]" ]]
			then
				DEPLOY_FLAG=false

				if [[ "${VERSION_ARR[1]}" != "${CACHE_ARR[1]}" ]]
				then
					deploy ${VERSION_ARR[0]} ${VERSION_ARR[1]}
				else
					echo "Skipping ${VERSION_ARR[0]}"
				fi
			fi
		done <$CACHE_VERSION_FILE

		if [[ $DEPLOY_FLAG == true ]]
		then
			deploy ${VERSION_ARR[0]} ${VERSION_ARR[1]}
		fi

	done <$VERSION_FILE
}

compare_version_files
cache_version
