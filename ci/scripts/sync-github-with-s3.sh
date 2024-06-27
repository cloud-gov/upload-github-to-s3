#!/bin/sh
tar -xzf gh-release/gh_2.52.0_linux_amd64.tar.gz
GH=gh_2.52.0_linux_amd64/bin/gh
${ACCESS_TOKEN} > token.txt
$GH auth login --with-token < token.txt
rm token.txt
MYJSONSTRING=$($GH repo list cloud-gov --json name,updatedAt --limit 500 --no-archived)
TWO_DAYS_AGO=$(date -j -v -2d +"%Y-%m-%dT%H:%M:%S%:z")
for row in $(echo "${MYJSONSTRING}" | jq -r '.[] | @base64'); do
    _jq() {
      echo ${row} | base64 --decode | jq -r ${1}
    }
    UPLOAD_DATE=$(_jq '.updatedAt')
    # if [[ "${TWO_DAYS_AGO}" < "${UPLOAD_DATE}" ]];
    # then
    #   TEST=$(_jq '.name')
    #   git clone https://github.com/cloud-gov/$TEST
    #   zip -r ${TEST}.zip $TEST
    #   sudo rm -r $TEST
    #   aws s3 cp --sse AES256 ${TEST}.zip  s3://github-backups/${TEST}.zip
    # fi


done