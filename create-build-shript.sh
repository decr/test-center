#!/bin/bash

# usage 
# create-build-script.sh REPOSITORY_URL REPOSITORY_NAME

services=(
    "test-app"
    "test-proxy"
)

echo "#!/bin/bash" > /tmp/build.sh
echo "#!/bin/bash" > /tmp/push.sh
echo "{" > /tmp/build.json

for service in "${services[@]}" ; do
    if [ ! -d "./${service}" ]; then
        echo "[${service}] Service directory not found"
        continue
    fi

    hash=`git -C ./${service} log --pretty=%H | head -n 1`

    echo "[${service}] Current tag => $2:${hash}"
    result=`aws ecr list-images --repository-name $2 | grep $hash | wc -l`

    if [ $result -eq 0 ]; then
        echo "docker build --tag $1:${hash} ./${service}"
        
        echo "echo \"docker build --tag $1:${hash} ./${service}\"" >> /tmp/build.sh
        echo "docker build --tag $1:${hash} ./${service}" >> /tmp/build.sh

        echo "echo \"docker push $1:${hash}\"" >> /tmp/push.sh
        echo "docker push $1:${hash}" >> /tmp/push.sh
    else
        echo "[${service}] Latest version of the image exists, build process was skipped."
    fi

    # 仮(複数serviceをdeployに対応が必要)二個以上のときのカンマの処理
    # listにいれて最後に出すほうがいいかも
    echo "  \"tag\":\"${hash}\"" >> /tmp/build.json
done
echo "}" >> /tmp/build.json
