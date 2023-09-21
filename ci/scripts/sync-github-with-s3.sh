MYJSONSTRING=$(gh repo list cloud-gov --json name,updatedAt --limit 500 --no-archived)
TWO_DAYS_AGO=$(date -j -v -2d +"%Y-%m-%dT%H:%M:%S%:z")
for row in $(echo "${MYJSONSTRING}" | jq -r '.[] | @base64'); do
    _jq() {
      echo ${row} | base64 --decode | jq -r ${1}
    }
    UPLOAD_DATE=$(_jq '.updatedAt')
    if [[ "${TWO_DAYS_AGO}" < "${UPLOAD_DATE}" ]];
    then
      TEST=$(_jq '.name')
      git clone https://github.com/cloud-gov/$TEST
      zip -r ${TEST}.zip $TEST
      sudo rm -r $TEST
      aws s3 cp --sse AES256 ${TEST}.zip  s3://github-backups/${TEST}.zip
      #rm ${TEST}.zip
    fi


done