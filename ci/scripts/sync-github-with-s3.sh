#!/bin/sh
tar -xzf gh-release/gh_2.52.0_linux_amd64.tar.gz
GH=gh_2.52.0_linux_amd64/bin/gh
export GH_TOKEN=${ACCESS_TOKEN}
LIST_OF_REPOS=$($GH repo list cloud-gov --json name,updatedAt --limit 500 --no-archived --visibility private)
TWO_DAYS_AGO=$(date -d "2 days ago"  +"%Y-%m-%dT%H:%M:%S%:z")
for row in $(echo "${LIST_OF_REPOS}" | jq -r '.[] | @base64'); do
    _jq() {
      echo ${row} | base64 --decode | jq -r ${1}
    }
    LAST_UPDATE=$(_jq '.updatedAt')
    if [ "`date --date \"$TWO_DAYS_AGO\" +%s`"  -lt "`date --date \"$LAST_UPDATE\" +%s`" ];
    then
      REPOSITORY=$(_jq '.name')
      git clone https://github.com/cloud-gov/$REPOSITORY
      tar czf ${REPOSITORY}.tar.gz $REPOSITORY
      sudo rm -r $REPOSITORY
      aws s3 cp --sse AES256 ${REPOSITORY}.tar.gz  s3://github-backups/${REPOSITORY}.tar.gz
      sudo rm -r ${REPOSITORY}.tar.gz
    fi


done