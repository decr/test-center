#!/bin/bash

apis=(
    "test-app"
    "test-proxy"
)

echo "repo=$1"

for apiname in "${apis[@]}" ; do
    if [ ! -d "./${apiname}" ]; then
        echo "api = ${apiname} not found"
        continue
    fi

    echo "api = ${apiname}"

    hash=`git -C ./${apiname} log --pretty=%H | head -n 1`

    echo "hash=${hash}"
    result=`aws ecr list-images --repository-name $1 | grep $hash | wc -l`

    if [ $result -eq 0 ]; then
        echo "docker build --tag $1:${hash} ./${apiname}" 
    fi
done
