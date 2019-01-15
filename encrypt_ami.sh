#!/usr/bin/env bash

this_account() {
  aws sts get-caller-identity \
    --query Account --output text
}

account_of() {
  local image_id=$1
  aws ec2 describe-images --image-id $image_id \
    --query 'Images[].OwnerId' --output text
}

copy_image() {
  local name=$1
  local image_id=$2
  aws ec2 copy-image --name $name --source-image-id $image_id \
    --source-region ap-southeast-2 --encrypted \
    --query ImageId --output text
}

wait_for_image() {
  local image_id=$1
  while true ; do
    state=$(aws ec2 describe-images --image-id $image_id \
      --query 'Images[].State' --output text)
    [ "$state" == "available" ] && break
    echo "state: $state"
    sleep 10
  done
}

source_image_id=$1
image_name=$2
os_type=$3
subnet_id=$4
tags=$5

if [ "$(this_account)" == "$(account_of $source_image_id)" ] ; then
  wait_for_image $(copy_image $source_image_id $image_name)
fi
