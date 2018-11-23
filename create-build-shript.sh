#!/bin/bash

apis=(
    "test-app"
    "test-proxy"
)

echo "#!/bin/bash" > /tmp/build.sh

for apiname in "${apis[@]}" ; do
    if [ ! -d "./${apiname}" ]; then
        echo "api = ${apiname} not found"
        continue
    fi

    hash=`git -C ./${apiname} log --pretty=%H | head -n 1`

    echo "api = ${apiname}, hash = ${hash}"
    result=`aws ecr list-images --repository-name $1 | grep $hash | wc -l`

    if [ $result -eq 0 ]; then
        echo "docker build --tag $1:${hash} ./${apiname}" 
        echo "echo \"docker build --tag $1:${hash} ./${apiname}\"" >> /tmp/build.sh
        echo "docker build --tag $1:${hash} ./${apiname}" >> /tmp/build.sh

        echo "echo \"docker push $1:${hash} ./${apiname}\"" >> /tmp/push.sh
        echo "docker push $1:${hash} ./${apiname}" >> /tmp/push.sh
    fi
done
