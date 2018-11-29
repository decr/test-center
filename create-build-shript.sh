#!/bin/bash

# usage 
# create-build-script.sh REPOSITORY_URL REPOSITORY_NAME

service=$1
repo_url=$2
repo_name=$3

if [ ! -d "./${service}" ]; then
    return 0;
fi

hash=`git -C ./${service} log --pretty=%H | head -n 1`
result=`aws ecr list-images --repository-name $repo_name | grep $hash | wc -l`

if [ $result -eq 0 ]; then
    echo "docker build --tag $repo_url:${hash} ./${service}"
fi
