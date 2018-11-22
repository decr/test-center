#!/bin/bash

apis=(
    "test-app"
    "test-proxy"
)

for apiname in "${apis[@]}" ; do
    if [ ! -d "./${apiname}" ]; then
        echo "api = ${apiname} not found"
        continue
    fi

    echo "api = ${apiname}"

    hash=`git -C ./${apiname} log --pretty=%H | head -n 1`

    echo "hash=${hash}"

    hash='4044e512-cf23-41af-8f88-0e08c636f5e6'
    result=`aws ecr list-images --repository-name kwata-repos-1akkahip8el1t | grep $hash | wc -l`

    if [ $result -eq 1 ]; then
        echo "docker build --tag $1:${hash} ./${apiname}" 
    fi
done
