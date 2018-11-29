#!/bin/bash

# usage 
# create-build-script.sh REPOSITORY_URL REPOSITORY_NAME

echo "#!/bin/bash" > /tmp/push.sh

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
    
    echo "echo \"docker push $1:${hash}\"" >> /tmp/push.sh
    echo "docker push $repo_url:${hash}" >> /tmp/push.sh
else
    echo "[${service}] Latest version image exists, build process was skipped."
fi
