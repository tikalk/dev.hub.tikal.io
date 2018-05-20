output "cluster_name" {
  value = "dev.hub.tikal.io"
}

output "master_security_group_ids" {
  value = ["${aws_security_group.masters-dev-hub-tikal-io.id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.masters-dev-hub-tikal-io.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.masters-dev-hub-tikal-io.name}"
}

output "node_security_group_ids" {
  value = ["${aws_security_group.nodes-dev-hub-tikal-io.id}"]
}

output "node_subnet_ids" {
  value = ["${aws_subnet.eu-west-1a-dev-hub-tikal-io.id}"]
}

output "nodes_role_arn" {
  value = "${aws_iam_role.nodes-dev-hub-tikal-io.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.nodes-dev-hub-tikal-io.name}"
}

output "region" {
  value = "eu-west-1"
}

output "vpc_id" {
  value = "${aws_vpc.dev-hub-tikal-io.id}"
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_autoscaling_group" "master-eu-west-1a-masters-dev-hub-tikal-io" {
  name                 = "master-eu-west-1a.masters.dev.hub.tikal.io"
  launch_configuration = "${aws_launch_configuration.master-eu-west-1a-masters-dev-hub-tikal-io.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.eu-west-1a-dev-hub-tikal-io.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "dev.hub.tikal.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-eu-west-1a.masters.dev.hub.tikal.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-eu-west-1a"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_autoscaling_group" "nodes-dev-hub-tikal-io" {
  name                 = "nodes.dev.hub.tikal.io"
  launch_configuration = "${aws_launch_configuration.nodes-dev-hub-tikal-io.id}"
  max_size             = 3
  min_size             = 3
  vpc_zone_identifier  = ["${aws_subnet.eu-west-1a-dev-hub-tikal-io.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "dev.hub.tikal.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.dev.hub.tikal.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "nodes"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_ebs_volume" "a-etcd-events-dev-hub-tikal-io" {
  availability_zone = "eu-west-1a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                        = "dev.hub.tikal.io"
    Name                                     = "a.etcd-events.dev.hub.tikal.io"
    "k8s.io/etcd/events"                     = "a/a"
    "k8s.io/role/master"                     = "1"
    "kubernetes.io/cluster/dev.hub.tikal.io" = "owned"
  }
}

resource "aws_ebs_volume" "a-etcd-main-dev-hub-tikal-io" {
  availability_zone = "eu-west-1a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                        = "dev.hub.tikal.io"
    Name                                     = "a.etcd-main.dev.hub.tikal.io"
    "k8s.io/etcd/main"                       = "a/a"
    "k8s.io/role/master"                     = "1"
    "kubernetes.io/cluster/dev.hub.tikal.io" = "owned"
  }
}

resource "aws_iam_instance_profile" "masters-dev-hub-tikal-io" {
  name = "masters.dev.hub.tikal.io"
  role = "${aws_iam_role.masters-dev-hub-tikal-io.name}"
}

resource "aws_iam_instance_profile" "nodes-dev-hub-tikal-io" {
  name = "nodes.dev.hub.tikal.io"
  role = "${aws_iam_role.nodes-dev-hub-tikal-io.name}"
}

resource "aws_iam_role" "masters-dev-hub-tikal-io" {
  name               = "masters.dev.hub.tikal.io"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.dev.hub.tikal.io_policy")}"
}

resource "aws_iam_role" "nodes-dev-hub-tikal-io" {
  name               = "nodes.dev.hub.tikal.io"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.dev.hub.tikal.io_policy")}"
}

resource "aws_iam_role_policy" "masters-dev-hub-tikal-io" {
  name   = "masters.dev.hub.tikal.io"
  role   = "${aws_iam_role.masters-dev-hub-tikal-io.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.dev.hub.tikal.io_policy")}"
}

resource "aws_iam_role_policy" "nodes-dev-hub-tikal-io" {
  name   = "nodes.dev.hub.tikal.io"
  role   = "${aws_iam_role.nodes-dev-hub-tikal-io.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.dev.hub.tikal.io_policy")}"
}

resource "aws_internet_gateway" "dev-hub-tikal-io" {
  vpc_id = "${aws_vpc.dev-hub-tikal-io.id}"

  tags = {
    KubernetesCluster                        = "dev.hub.tikal.io"
    Name                                     = "dev.hub.tikal.io"
    "kubernetes.io/cluster/dev.hub.tikal.io" = "owned"
  }
}

resource "aws_key_pair" "kubernetes-dev-hub-tikal-io-f7f8e648cf2dc3a698a59dec98c4ff0b" {
  key_name   = "kubernetes.dev.hub.tikal.io-f7:f8:e6:48:cf:2d:c3:a6:98:a5:9d:ec:98:c4:ff:0b"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.dev.hub.tikal.io-f7f8e648cf2dc3a698a59dec98c4ff0b_public_key")}"
}

resource "aws_launch_configuration" "master-eu-west-1a-masters-dev-hub-tikal-io" {
  name_prefix                 = "master-eu-west-1a.masters.dev.hub.tikal.io-"
  image_id                    = "ami-33c9a24a"
  instance_type               = "t2.medium"
  key_name                    = "${aws_key_pair.kubernetes-dev-hub-tikal-io-f7f8e648cf2dc3a698a59dec98c4ff0b.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-dev-hub-tikal-io.id}"
  security_groups             = ["${aws_security_group.masters-dev-hub-tikal-io.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-eu-west-1a.masters.dev.hub.tikal.io_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 64
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_launch_configuration" "nodes-dev-hub-tikal-io" {
  name_prefix                 = "nodes.dev.hub.tikal.io-"
  image_id                    = "ami-33c9a24a"
  instance_type               = "t2.medium"
  key_name                    = "${aws_key_pair.kubernetes-dev-hub-tikal-io-f7f8e648cf2dc3a698a59dec98c4ff0b.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-dev-hub-tikal-io.id}"
  security_groups             = ["${aws_security_group.nodes-dev-hub-tikal-io.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.dev.hub.tikal.io_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.dev-hub-tikal-io.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.dev-hub-tikal-io.id}"
}

resource "aws_route_table" "dev-hub-tikal-io" {
  vpc_id = "${aws_vpc.dev-hub-tikal-io.id}"

  tags = {
    KubernetesCluster                        = "dev.hub.tikal.io"
    Name                                     = "dev.hub.tikal.io"
    "kubernetes.io/cluster/dev.hub.tikal.io" = "owned"
    "kubernetes.io/kops/role"                = "public"
  }
}

resource "aws_route_table_association" "eu-west-1a-dev-hub-tikal-io" {
  subnet_id      = "${aws_subnet.eu-west-1a-dev-hub-tikal-io.id}"
  route_table_id = "${aws_route_table.dev-hub-tikal-io.id}"
}

resource "aws_security_group" "masters-dev-hub-tikal-io" {
  name        = "masters.dev.hub.tikal.io"
  vpc_id      = "${aws_vpc.dev-hub-tikal-io.id}"
  description = "Security group for masters"

  tags = {
    KubernetesCluster                        = "dev.hub.tikal.io"
    Name                                     = "masters.dev.hub.tikal.io"
    "kubernetes.io/cluster/dev.hub.tikal.io" = "owned"
  }
}

resource "aws_security_group" "nodes-dev-hub-tikal-io" {
  name        = "nodes.dev.hub.tikal.io"
  vpc_id      = "${aws_vpc.dev-hub-tikal-io.id}"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster                        = "dev.hub.tikal.io"
    Name                                     = "nodes.dev.hub.tikal.io"
    "kubernetes.io/cluster/dev.hub.tikal.io" = "owned"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev-hub-tikal-io.id}"
  source_security_group_id = "${aws_security_group.masters-dev-hub-tikal-io.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-dev-hub-tikal-io.id}"
  source_security_group_id = "${aws_security_group.masters-dev-hub-tikal-io.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-dev-hub-tikal-io.id}"
  source_security_group_id = "${aws_security_group.nodes-dev-hub-tikal-io.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "https-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-dev-hub-tikal-io.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-dev-hub-tikal-io.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-dev-hub-tikal-io.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev-hub-tikal-io.id}"
  source_security_group_id = "${aws_security_group.nodes-dev-hub-tikal-io.id}"
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4000" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev-hub-tikal-io.id}"
  source_security_group_id = "${aws_security_group.nodes-dev-hub-tikal-io.id}"
  from_port                = 2382
  to_port                  = 4000
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev-hub-tikal-io.id}"
  source_security_group_id = "${aws_security_group.nodes-dev-hub-tikal-io.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev-hub-tikal-io.id}"
  source_security_group_id = "${aws_security_group.nodes-dev-hub-tikal-io.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-dev-hub-tikal-io.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.nodes-dev-hub-tikal-io.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_subnet" "eu-west-1a-dev-hub-tikal-io" {
  vpc_id            = "${aws_vpc.dev-hub-tikal-io.id}"
  cidr_block        = "172.20.32.0/19"
  availability_zone = "eu-west-1a"

  tags = {
    KubernetesCluster                        = "dev.hub.tikal.io"
    Name                                     = "eu-west-1a.dev.hub.tikal.io"
    SubnetType                               = "Public"
    "kubernetes.io/cluster/dev.hub.tikal.io" = "owned"
    "kubernetes.io/role/elb"                 = "1"
  }
}

resource "aws_vpc" "dev-hub-tikal-io" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    KubernetesCluster                        = "dev.hub.tikal.io"
    Name                                     = "dev.hub.tikal.io"
    "kubernetes.io/cluster/dev.hub.tikal.io" = "owned"
  }
}

resource "aws_vpc_dhcp_options" "dev-hub-tikal-io" {
  domain_name         = "eu-west-1.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    KubernetesCluster                        = "dev.hub.tikal.io"
    Name                                     = "dev.hub.tikal.io"
    "kubernetes.io/cluster/dev.hub.tikal.io" = "owned"
  }
}

resource "aws_vpc_dhcp_options_association" "dev-hub-tikal-io" {
  vpc_id          = "${aws_vpc.dev-hub-tikal-io.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dev-hub-tikal-io.id}"
}

terraform = {
  required_version = ">= 0.9.3"
}
