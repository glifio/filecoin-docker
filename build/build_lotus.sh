#!/bin/bash
echo $1
if [[ $1 != '' ]]; then
  if [[ $1 == "rebuild" ]]; then
    docker image build --no-cache -t openworklabs/lotus:latest -f lotus.dockerfile .
  fi
else
  docker image build -t openworklabs/lotus:latest -f lotus.dockerfile .
fi