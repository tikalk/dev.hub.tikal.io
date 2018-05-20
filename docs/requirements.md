# workstation Setup

## Setting up on your workstation

* Install requirements
  * aws-cli
  * kubectl
  * kops
  * TODO: add terraform (if we end up using it for this)
* Configure AWS cli
* Configure kops
* Configure kubectl (set cluster contexts)

### Install requirements
For mac it's quite simple with home brew:
* AWS cli:
  `brew install awscli`
* AWS kubectl:
  `brew install kubernetes-cli`
* AWS kops:
  `brew install kops`

### Setup bash completion
* awscli -> `complete -C '/usr/local/bin/aws_completer' aws`
* kubectl ->  `source <(kubectl completion bash)`
* kops -> `source <(kops completion bash)`

### Configure aws cli
See [./aws-cli.md](./aws-cli.md)

At the end setting up the `AWS_PROFILE` environment variable will help make sure you are using the correct credentials like so:

`export AWS_PROFILE=tikal-io`

### Configure kops

The only important parameter is `KOPS_STATE_STORE`:

```bash
export KOPS_STATE_STORE=s3://ac.fuse.tikal.io
export KOPS_CLUSTER_NAME=dev.hub.tikal.io
```

### Configure kubectl

This is something you should be doing after `aws cli` and `kops` are configured and the cluster you are connecting to is **up and running** and kops is able to successfully show you info like `kops validate cluster`

Setting up kubectl is downloading the requires `kubeconfig` (kubernetes configuration file from the `KOPS_STATE_STORE`).

Getting the configuration for kubectl to work run the following:

```bash
kops  export kubecfg --name=${KOPS_CLUSTER_NAME} --state=${KOPS_STATE_STORE}
```

A successful execution should yield -> **kops has set your kubectl context to ci-k8s.mobimate.com**.

Now you should be ready to start working with Kubernetes
