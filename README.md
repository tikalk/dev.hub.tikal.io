# Baking a production ready Kubernetes cluster with "kops & friends"

> This repo was designed for us internally/yet public (it's open source and no credentials exposed ...) to be able to spin-up simple k8s clusters for experiments I also [Blogged about it here](http://www.tikalk.com/posts/2018/05/21/baking-a-production-ready-kubernetes-cluster-with-kops-friends/)

## Intro

So without introduction to the tools used in this blog post (maybe another time ...) I thought I would share with you something i've prepared in one of my projects,
Lets start by stating what I am aiming for ...

I want every micro-service we launch in our cluster to be `monitored`, `logged`, `scalable`, `routable`, `accessible`, `authorized` and more ...

We already have a `manual` process of instantiating our cluster using `kops` with a set of constraints out of the scope of this post, but what I want to achieve is that when we rollout a cluster for testing / ci / new environment all these "Basic" needs are covered.

You will see below a list of `completed` which was the cause to blog about it, and the `Still in the works` and the `Post installation` is still manual :( which we will be working on ...

All these should be found under [tikalk/dev.hub.tikal.io](https://github.com/tikalk/dev.hub.tikal.io) github repo, I assume you can follow along [there](https://github.com/tikalk/dev.hub.tikal.io) for any additions if I don't blog about them. **So lets get to it !!!**

## Our desired cluster state:

Complete (specified in this post):
* [x] Simple 1 master 3 nodes cluster (extend after)
* [x] Horizontal Auto Scaling enabled which requires heapster
* [x] Elasticsearch Fluentd Kibana for logging
* [x] Kubernetes dashboard

Still in the works:
* [ ] Prometheus Operator
* [ ] Istio
* [ ] A demo app

Post installation:
* [ ] Add spinnaker helm chart
* [ ] Customer Applications as addons ?! / Spnnaker pipelines

## Step by Step:
1. [Intro](#intro)
1. [Our Desired cluster state](#our-desired-cluster-state)
1. [Requirements](#requirements)
1. [Setup the environment](#setup-the-environment)
1. [Create a cluster with kops](#create-a-cluster-with-kops)
1. [Review Cluster](#review-cluster)

	6.1 [Cluster spec](#cluster-spec)

	6.2 [Instance Group spec](#instancegroup-spec)

1. [Add kops addons](#add-kops-addons)
1. [Replace cluster config spec](#replace-cluster-config-spec)
1. [Update the cluster](#update-the-cluster)
1. [Wrapping up](#wrapping-up)
  10.1 [View cluster logs in kibana](#view-cluster-logs-in-kibana)

## Requirements:
* aws cli + aws credentials / profile [link to repo](https://github.com/tikalk/dev.hub.tikal.io/blob/master/docs/aws-cli.md) or the official [AWS installation howto](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
* route53 public hosted zone [using a sub domain](https://github.com/kubernetes/kops/blob/master/docs/creating_subdomain.md)
  for this example I am using a subdomain of `tikal.io` -> `hub.tikal.io`
* kubectl [link to repo](https://github.com/tikalk/dev.hub.tikal.io/blob/master/docs/requirements.md)
* kops [link to repo](https://github.com/tikalk/dev.hub.tikal.io/blob/master/docs/requirements.md)
* Optional: terraform

## Setup the environment

This will set `AWS_PROFILE`, `AWS_ACCESS_KEY`, `AWS_SECRET_KEY`, `KOPS_STATE_STORE` and `KOPS_CLUSTER_NAME`

`source setenv.sh`

The `setenv.sh` file:

```bash
#!/bin/bash
# The AWS profile you want to activate - for "sahring is caring reasons"
# lets keep this value similar to all cluster administrators
export AWS_PROFILE=tikal-io
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
```

## Create a cluster with kops

```bash
kops create cluster \
    --node-count 3 \
    --zones eu-west-1a \
    --master-zones eu-west-1a \
    --node-size t2.medium \
    --master-size t2.medium \
    --ssh-public-key kops_rsa.pub \
    --dns-zone=hub.tikal.io \
    --name ${KOPS_CLUSTER_NAME}
```

## Review Cluster

```bash
kops get cluster && kops get --name $KOPS_CLUSTER_NAME instancegroups
```
Which should yield:

```bash
NAME                CLOUD     ZONES
dev.hub.tikal.io    aws       eu-west-1a

NAME                  ROLE        MACHINETYPE MIN     MAX ZONES
master-eu-west-1a     Master      t2.medium   1	    1  eu-west-1a
nodes                 Node        t2.medium   3	    3  eu-west-1a
```

## Get Cluster Config
We want the spec to keep in source control + edit it before we actually provision the cluster.

```
mkdir ./specs
kops get cluster --name ${KOPS_CLUSTER_NAME} -o yaml > ./specs/${KOPS_CLUSTER_NAME}-cluster.yaml
kops get --name ${KOPS_CLUSTER_NAME} instancegroups -o yaml > ./specs/${KOPS_CLUSTER_NAME}-ig.yaml
```

### Cluster spec
Our cluster spec should look like this:

```
apiVersion: kops/v1alpha2
kind: Cluster
metadata:
  creationTimestamp: 2018-05-20T14:58:19Z
  name: dev.hub.tikal.io
spec:
  api:
    dns: {}
  authorization:
    rbac: {}
  channel: stable
  cloudProvider: aws
  configBase: s3://ac.fuse.tikal.io/dev.hub.tikal.io
  dnsZone: hub.tikal.io
  etcdClusters:
  - etcdMembers:
    - instanceGroup: master-eu-west-1a
      name: a
    name: main
  - etcdMembers:
    - instanceGroup: master-eu-west-1a
      name: a
    name: events
  iam:
    allowContainerRegistry: true
    legacy: false
  kubernetesApiAccess:
  - 0.0.0.0/0
  kubernetesVersion: 1.9.3
  masterPublicName: api.dev.hub.tikal.io
  networkCIDR: 172.20.0.0/16
  networking:
    kubenet: {}
  nonMasqueradeCIDR: 100.64.0.0/10
  sshAccess:
  - 0.0.0.0/0
  subnets:
  - cidr: 172.20.32.0/19
    name: eu-west-1a
    type: Public
    zone: eu-west-1a
  topology:
    dns:
      type: Public
    masters: public
    nodes: public
```

### Instancegroup spec
Our Instance Groups should look like this:

```
apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  creationTimestamp: 2018-05-20T14:58:20Z
  labels:
    kops.k8s.io/cluster: dev.hub.tikal.io
  name: master-eu-west-1a
spec:
  image: kope.io/k8s-1.8-debian-jessie-amd64-hvm-ebs-2018-02-08
  machineType: t2.medium
  maxSize: 1
  minSize: 1
  nodeLabels:
    kops.k8s.io/instancegroup: master-eu-west-1a
  role: Master
  subnets:
  - eu-west-1a

---

apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  creationTimestamp: 2018-05-20T14:58:20Z
  labels:
    kops.k8s.io/cluster: dev.hub.tikal.io
  name: nodes
spec:
  image: kope.io/k8s-1.8-debian-jessie-amd64-hvm-ebs-2018-02-08
  machineType: t2.medium
  maxSize: 3
  minSize: 3
  nodeLabels:
    kops.k8s.io/instancegroup: nodes
  role: Node
  subnets:
  - eu-west-1a

```

## Add kops addons
Let's add some out of the box to our `${KOPS_CLUSTER_NAME}-cluster.yaml` cluster spec.

Add the following to your spec file:
```
spec:
  addons:
  - manifest: kubernetes-dashboard
  - manifest: monitoring-standalone
  - manifest: cluster-autoscaler
  - manifest: logging-elasticsearch
```
See -> [kops/issues/3554](https://github.com/kubernetes/kops/issues/3554)

This will result in a cluster with logging and autoscaling enabled ...
I am planning on adding some of my own addons but didn't get around to it yet _(hope to do in a separate post)_.


## Replace cluster config spec
Using `kops replace` like so:

```
kops replace -f ${KOPS_CLUSTER_NAME}-cluster.yaml
kops replace -f ${KOPS_CLUSTER_NAME}-ig.yaml`
```

## Update the cluster
Using `kops update cluster` like so:

```
kops update cluster # for preview
kops update cluster --yes
```

If you're like me and you added the addons after the cluster is created you also need to run `kops rolling-update cluster --yes`, considering addons are basically Kubernetes deployments / configMaps / Pod's ... so the kubernetes API should be able to pull them from your `s3Bucket/addons` folder.

## Wrapping up

At this point you should have a cluster up and running with the following `kubectl cluster-info` result:

```
kubectl cluster-info
Kubernetes master is running at https://api.dev.hub.tikal.io
Elasticsearch is running at https://api.dev.hub.tikal.io/api/v1/namespaces/kube-system/services/elasticsearch-logging/proxy
Heapster is running at https://api.dev.hub.tikal.io/api/v1/namespaces/kube-system/services/heapster/proxy
Kibana is running at https://api.dev.hub.tikal.io/api/v1/namespaces/kube-system/services/kibana-logging/proxy
KubeDNS is running at https://api.dev.hub.tikal.io/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

In order to log into the UI, use the secret from your local `.kube/config` file.



### View cluster logs in kibana
![Kibana log](https://github.com/tikalk/dev.hub.tikal.io/blob/master/docs/static/kibana-log.png?raw=true)


As always hope you found this blog post useful, feel free to drop me a line ...

Yours,
HP
