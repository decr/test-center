#!/bin/bash

# usage 
# create-build-script.sh REPOSITORY_URL REPOSITORY_NAME

services=(
    "test-app"
    "test-proxy"
)

declare -A tags=()

echo "#!/bin/bash" > /tmp/build.sh
echo "#!/bin/bash" > /tmp/push.sh

for service in "${services[@]}" ; do
    if [ ! -d "./${service}" ]; then
        echo "[${service}] Service directory not found"
        continue
    fi

    if [ ${service} = 'test-app' ]; then
        repo_url=$1
        repo_name=$2
    else
        repo_url=$3
        repo_name=$4
    fi

    hash=`git -C ./${service} log --pretty=%H | head -n 1`

    echo "[${service}] Current tag => $repo_name:${hash}"
    result=`aws ecr list-images --repository-name $repo_name | grep $hash | wc -l`

    if [ $result -eq 0 ]; then
        echo "docker build --tag $repo_url:${hash} ./${service}"
        
        echo "echo \"docker build --tag $repo_url:${hash} ./${service}\"" >> /tmp/build.sh
        echo "docker build --tag $repo_url:${hash} ./${service}" >> /tmp/build.sh

        echo "echo \"docker push $1:${hash}\"" >> /tmp/push.sh
        echo "docker push $repo_url:${hash}" >> /tmp/push.sh
    else
        echo "[${service}] Latest version image exists, build process was skipped."
    fi

    tags[$service]=$hash
done

for key in "${!tags[@]}"; do
    printf '%s\0%s\0' "$key" "${tags[$key]}"
done |
jq -Rs '
  split("\u0000")
  | . as $a
  | reduce range(0; length/2) as $i 
      ({}; . + {($a[2*$i]): ($a[2*$i + 1]|fromjson? // .)})' > /tmp/build.json
