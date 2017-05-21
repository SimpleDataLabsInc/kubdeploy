#!/bin/bash

# Single master private
# template https://github.com/kris-nova/kops-demo/blob/master/single-master-private/deploy.sh

export KOPS_NAME="dev1.simpledatalabs.io"
export KOPS_STATE_STORE="s3://simpledatalabs-io-state-store"
export KOPS_NODE_SIZE="t2.medium"

kops delete cluster --name $KOPS_NAME --yes

# exit 1

kops create cluster \
  --name $KOPS_NAME \
  --state $KOPS_STATE_STORE \
  --node-count 1 \
  --zones ap-south-1a \
  --master-zones ap-south-1a \
  --cloud aws \
  --node-size  $KOPS_NODE_SIZE \
  --master-size $KOPS_NODE_SIZE \
  -v 10 \
  --kubernetes-version "1.5.4" \
  --bastion \
  --topology private \
  --networking weave \
  --ssh-public-key "../deploy1.pub" \
  --target=terraform

rm -f ~/.kube/config
kops export kubecfg --name $KOPS_NAME
