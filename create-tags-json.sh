#!/bin/bash

# usage 
# create-build-script.sh REPOSITORY_URL REPOSITORY_NAME

services=(
    "test-app"
    "test-proxy"
)

declare -A tags=()

for service in "${services[@]}" ; do
    if [ ! -d "./${service}" ]; then
        continue
    fi

    hash=`git -C ./${service} log --pretty=%H | head -n 1`
    tags[$service]=$hash
done

# 各コンテナの最新のtagをjson化して出力
for key in "${!tags[@]}"; do
    printf '%s\0%s\0' "$key" "${tags[$key]}"
done |
jq -Rs '
  split("\u0000")
  | . as $a
  | reduce range(0; length/2) as $i 
      ({}; . + {($a[2*$i]): ($a[2*$i + 1]|fromjson? // .)})' > /tmp/build.json
