API=https://api.bintray.com
FILE=nginx.tar.gz
PACKAGE_DESCRIPTOR=bintray-package.json

#BINTRAY_USER=$BINTRAY_USER
#BINTRAY_API_KEY=$BINTRAY_API_KEY
#

function main() {
	CURL="curl -u${BINTRAY_USER}:${BINTRAY_API_KEY} -H Content-Type:application/json -H Accept:application/json"
	if (check_package_exists); then
		echo "The package ${PCK_NAME} does not exit. It will be created"
		create_package
	fi
	deploy
}

function check_package_exists() {
  echo "Checking if package ${PCK_NAME} exists..."
  package_exists=`[ $(${CURL} --write-out %{http_code} --silent --output /dev/null -X GET  ${API}/packages/${BINTRAY_USER}/${BINTRAY_REPO}/${PCK_NAME})  -eq 200 ]`
  echo "Package ${PCK_NAME} exists? y:1/N:0 ${package_exists}"   
  return ${package_exists}
}

function create_package() {
  echo "Creating package ${PCK_NAME}..."
  if [ -f "${PACKAGE_DESCRIPTOR}" ]; then
    data="@${PACKAGE_DESCRIPTOR}"
  else
    data="{
    \"name\": \"${PCK_NAME}\",
    \"desc\": \"${PCK_DESCRIPTION}\",
    \"desc_url\": \"${PCK_URL}\",
    \"labels\": [${PCK_LABELS}]
    }"
  fi
  
  ${CURL} -X POST -d "${data}" ${API}/packages/${BINTRAY_USER}/${BINTRAY_REPO}
}

function deploy() {
  if (upload_content); then
    echo "Publishing ${FILE}..."
    ${CURL} -X POST ${API}/content/${BINTRAY_USER}/${BINTRAY_REPO}/${PCK_NAME}/${PCK_VERSION}/publish -d "{ \"discard\": \"false\" }"
  else
    echo "[SEVERE] First you should upload your rpm ${RPM}"
  fi    
}

function upload_content() {
  echo "Uploading ${FILE}..."
  uploaded=` [ $(${CURL} --write-out %{http_code} --silent --output /dev/null -T /${FILE} -H X-Bintray-Package:${PCK_NAME} -H X-Bintray-Version:${PCK_VERSION} ${API}/content/${BINTRAY_USER}/${BINTRAY_REPO}/${FILE}) -eq 201 ] `
  echo "File File uploaded? y:1/N:0 ${package_exists}"
  return ${uploaded}
}

main "$@"