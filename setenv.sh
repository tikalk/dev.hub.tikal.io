#!/bin/bash
# The AWS profile you want to activate - for "sahring is caring reasons"
# lets keep this value similar to all cluster administrators
export AWS_PROFILE=kops-aws-tikal
export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
# As commented above this is the s3 bucket which can store multipule cluster configurations.
# in case we want seperation of buckets this value might change based on stg prd etc etc
export KOPS_STATE_STORE=s3://ac.fuse.tikal.io
# Cluster name - each cluster has a unique name which also coreponds
# to the subdirectory in the s3 bucket
export KOPS_CLUSTER_NAME=dev.hub.tikal.io
# atom / anythong you like ...
export EDITOR='vim'
