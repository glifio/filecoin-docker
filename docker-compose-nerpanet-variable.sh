#!/usr/bin/env bash

SNAPSHOTURL=https://dev.node.glif.io/nerpa00/ipfs/8080/ipfs/$(curl -s https://gist.githubusercontent.com/openworklabbot/d32543d42ed318f6dfde516c3d8668a0/raw/snapshot.log)
sed -i "s|SNAPSHOTURL=*.*|SNAPSHOTURL=$SNAPSHOTURL|g" docker-compose-nerpanet.yaml
