#!/bin/bash -e
NETWORK=lotus
### delete images on worker if exist
[ ! -z "$(docker images -q)" ] &&  docker rmi -f $(docker images -q) || echo no images

if [ -z $latestLotusTag ]
 then
  echo "\$latestLotusTag is NOT defined"
  exit 1
fi

if [ -z $imageTag ]
  then
    echo "\$imageTag is not defined. Setting \$imageTag ..."
    export imageTag=$latestLotusTag
fi

### updated tag name to the :latest for calibration, nerpa networks
if [[ $imageTag =~ ^v.*$ ]]
	then echo "accepted tag"
    else imageTag=$(echo $imageTag | sed 's/\/.*//')
fi

### update tag name if is not mainnet
if [ $NETWORK != lotus ]
  then imageTag="$imageTag"-"$NETWORK"
fi

echo "latestLotusTag = $latestLotusTag  imageTag = $imageTag"
docker image build --no-cache  --network host --build-arg NETWORK=$NETWORK --build-arg BRANCH=$latestLotusTag -t glif/lotus:$imageTag .

