#!/bin/bash

# usage 
# create-build-script.sh REPOSITORY_URL REPOSITORY_NAME

echo "#!/bin/bash" > /tmp/build.sh

service=$1
repo_url=$2
repo_name=$3

if [ ! -d "./${service}" ]; then
    echo "[${service}] Service directory not found"
    return 0;
fi

hash=`git -C ./${service} log --pretty=%H | head -n 1`

echo "[${service}] Current tag => ${repo_name}:${hash}"
result=`aws ecr list-images --repository-name $repo_name | grep $hash | wc -l`

if [ $result -eq 0 ]; then
    echo "docker build --tag $repo_url:${hash} ./${service}"
    
    echo "echo \"docker build --tag $repo_url:${hash} ./${service}\"" >> /tmp/build.sh
    echo "docker build --tag $repo_url:${hash} ./${service}" >> /tmp/build.sh
else
    echo "[${service}] Latest version image exists, build process was skipped."
fi
