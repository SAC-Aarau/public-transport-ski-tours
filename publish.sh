#!/bin/bash

if [[ -z "$1" ]]; then
    exit -1
fi

readonly folder="$1"

cd $(cd -- "$(dirname "${0}")" >/dev/null 2>&1 ; pwd -P) && \
cd "${folder}"  && \

git init  && \
git checkout -b page  && \
git add . && git commit -m "publish webpage and pdf"  && \
git remote add origin git@github.com:SAC-Aarau/public-transport-ski-tours.git  && \
git push origin page --force && \
rm -rf ./.git

exit $?
