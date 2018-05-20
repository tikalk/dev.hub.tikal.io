
## Setting up on your workstation

* Install requirements
  * aws-cli
* Configure AWS cli

### Install aws-cli
For mac it's quite simple with homebrew:
  `brew install awscli`

For all you can simply use pip:

  `pip install awscli`

### Setup bash completion
* awscli -> `complete -C '/usr/local/bin/aws_completer' aws`
> please note: you probebly want to add this permanently as a file or include via your ~/.bashrc

### Configure aws cli
You can run the setup interactively like so:

> Please note: this is the `global` profile with your personal IAM account hence i would use either the default profile or calling it `tikal-io`

`aws configure --profile tikal-io`

The enter you `AWS_ACCESS_KEY`,  `AWS_SECRET_KEY`, `AWS_REGION`

At the end setting up the `AWS_PROFILE` environment variable will help make sure you are using the correct credentials like so:

`export AWS_PROFILE=tikal-io`

A successful execution of something like: `aws ec2 describe-region` means you are all set !
