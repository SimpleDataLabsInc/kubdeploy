provider "aws" {
  region = "ap-south-1"
}

resource "aws_autoscaling_attachment" "bastions-dev1-simpledatalabs-io" {
  elb                    = "${aws_elb.bastion-dev1-simpledatalabs-io.id}"
  autoscaling_group_name = "${aws_autoscaling_group.bastions-dev1-simpledatalabs-io.id}"
}

resource "aws_autoscaling_attachment" "master-ap-south-1a-masters-dev1-simpledatalabs-io" {
  elb                    = "${aws_elb.api-dev1-simpledatalabs-io.id}"
  autoscaling_group_name = "${aws_autoscaling_group.master-ap-south-1a-masters-dev1-simpledatalabs-io.id}"
}

resource "aws_autoscaling_group" "bastions-dev1-simpledatalabs-io" {
  name                 = "bastions.dev1.simpledatalabs.io"
  launch_configuration = "${aws_launch_configuration.bastions-dev1-simpledatalabs-io.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.utility-ap-south-1a-dev1-simpledatalabs-io.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "dev1.simpledatalabs.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "bastions.dev1.simpledatalabs.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/bastion"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "master-ap-south-1a-masters-dev1-simpledatalabs-io" {
  name                 = "master-ap-south-1a.masters.dev1.simpledatalabs.io"
  launch_configuration = "${aws_launch_configuration.master-ap-south-1a-masters-dev1-simpledatalabs-io.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.ap-south-1a-dev1-simpledatalabs-io.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "dev1.simpledatalabs.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-ap-south-1a.masters.dev1.simpledatalabs.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-dev1-simpledatalabs-io" {
  name                 = "nodes.dev1.simpledatalabs.io"
  launch_configuration = "${aws_launch_configuration.nodes-dev1-simpledatalabs-io.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.ap-south-1a-dev1-simpledatalabs-io.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "dev1.simpledatalabs.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.dev1.simpledatalabs.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_ebs_volume" "a-etcd-events-dev1-simpledatalabs-io" {
  availability_zone = "ap-south-1a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "dev1.simpledatalabs.io"
    Name                 = "a.etcd-events.dev1.simpledatalabs.io"
    "k8s.io/etcd/events" = "a/a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "a-etcd-main-dev1-simpledatalabs-io" {
  availability_zone = "ap-south-1a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "dev1.simpledatalabs.io"
    Name                 = "a.etcd-main.dev1.simpledatalabs.io"
    "k8s.io/etcd/main"   = "a/a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_eip" "ap-south-1a-dev1-simpledatalabs-io" {
  vpc = true
}

resource "aws_elb" "api-dev1-simpledatalabs-io" {
  name = "api-dev1"

  listener = {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.api-elb-dev1-simpledatalabs-io.id}"]
  subnets         = ["${aws_subnet.utility-ap-south-1a-dev1-simpledatalabs-io.id}"]

  health_check = {
    target              = "TCP:443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  tags = {
    KubernetesCluster = "dev1.simpledatalabs.io"
    Name              = "api.dev1.simpledatalabs.io"
  }
}

resource "aws_elb" "bastion-dev1-simpledatalabs-io" {
  name = "bastion-dev1"

  listener = {
    instance_port     = 22
    instance_protocol = "TCP"
    lb_port           = 22
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.bastion-elb-dev1-simpledatalabs-io.id}"]
  subnets         = ["${aws_subnet.utility-ap-south-1a-dev1-simpledatalabs-io.id}"]

  health_check = {
    target              = "TCP:22"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  idle_timeout = 300

  tags = {
    KubernetesCluster = "dev1.simpledatalabs.io"
    Name              = "bastion.dev1.simpledatalabs.io"
  }
}

resource "aws_iam_instance_profile" "bastions-dev1-simpledatalabs-io" {
  name  = "bastions.dev1.simpledatalabs.io"
  roles = ["${aws_iam_role.bastions-dev1-simpledatalabs-io.name}"]
}

resource "aws_iam_instance_profile" "masters-dev1-simpledatalabs-io" {
  name  = "masters.dev1.simpledatalabs.io"
  roles = ["${aws_iam_role.masters-dev1-simpledatalabs-io.name}"]
}

resource "aws_iam_instance_profile" "nodes-dev1-simpledatalabs-io" {
  name  = "nodes.dev1.simpledatalabs.io"
  roles = ["${aws_iam_role.nodes-dev1-simpledatalabs-io.name}"]
}

resource "aws_iam_role" "bastions-dev1-simpledatalabs-io" {
  name               = "bastions.dev1.simpledatalabs.io"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_bastions.dev1.simpledatalabs.io_policy")}"
}

resource "aws_iam_role" "masters-dev1-simpledatalabs-io" {
  name               = "masters.dev1.simpledatalabs.io"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.dev1.simpledatalabs.io_policy")}"
}

resource "aws_iam_role" "nodes-dev1-simpledatalabs-io" {
  name               = "nodes.dev1.simpledatalabs.io"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.dev1.simpledatalabs.io_policy")}"
}

resource "aws_iam_role_policy" "bastions-dev1-simpledatalabs-io" {
  name   = "bastions.dev1.simpledatalabs.io"
  role   = "${aws_iam_role.bastions-dev1-simpledatalabs-io.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_bastions.dev1.simpledatalabs.io_policy")}"
}

resource "aws_iam_role_policy" "masters-dev1-simpledatalabs-io" {
  name   = "masters.dev1.simpledatalabs.io"
  role   = "${aws_iam_role.masters-dev1-simpledatalabs-io.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.dev1.simpledatalabs.io_policy")}"
}

resource "aws_iam_role_policy" "nodes-dev1-simpledatalabs-io" {
  name   = "nodes.dev1.simpledatalabs.io"
  role   = "${aws_iam_role.nodes-dev1-simpledatalabs-io.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.dev1.simpledatalabs.io_policy")}"
}

resource "aws_internet_gateway" "dev1-simpledatalabs-io" {
  vpc_id = "${aws_vpc.dev1-simpledatalabs-io.id}"

  tags = {
    KubernetesCluster = "dev1.simpledatalabs.io"
    Name              = "dev1.simpledatalabs.io"
  }
}

resource "aws_key_pair" "kubernetes-dev1-simpledatalabs-io-21751dde83c7a94e8e6e1db5d85f3532" {
  key_name   = "kubernetes.dev1.simpledatalabs.io-21:75:1d:de:83:c7:a9:4e:8e:6e:1d:b5:d8:5f:35:32"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.dev1.simpledatalabs.io-21751dde83c7a94e8e6e1db5d85f3532_public_key")}"
}

resource "aws_launch_configuration" "bastions-dev1-simpledatalabs-io" {
  name_prefix                 = "bastions.dev1.simpledatalabs.io-"
  image_id                    = "ami-034a3c6c"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.kubernetes-dev1-simpledatalabs-io-21751dde83c7a94e8e6e1db5d85f3532.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.bastions-dev1-simpledatalabs-io.id}"
  security_groups             = ["${aws_security_group.bastion-dev1-simpledatalabs-io.id}"]
  associate_public_ip_address = true

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "master-ap-south-1a-masters-dev1-simpledatalabs-io" {
  name_prefix                 = "master-ap-south-1a.masters.dev1.simpledatalabs.io-"
  image_id                    = "ami-034a3c6c"
  instance_type               = "t2.medium"
  key_name                    = "${aws_key_pair.kubernetes-dev1-simpledatalabs-io-21751dde83c7a94e8e6e1db5d85f3532.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-dev1-simpledatalabs-io.id}"
  security_groups             = ["${aws_security_group.masters-dev1-simpledatalabs-io.id}"]
  associate_public_ip_address = false
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-ap-south-1a.masters.dev1.simpledatalabs.io_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "nodes-dev1-simpledatalabs-io" {
  name_prefix                 = "nodes.dev1.simpledatalabs.io-"
  image_id                    = "ami-034a3c6c"
  instance_type               = "t2.medium"
  key_name                    = "${aws_key_pair.kubernetes-dev1-simpledatalabs-io-21751dde83c7a94e8e6e1db5d85f3532.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-dev1-simpledatalabs-io.id}"
  security_groups             = ["${aws_security_group.nodes-dev1-simpledatalabs-io.id}"]
  associate_public_ip_address = false
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.dev1.simpledatalabs.io_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "ap-south-1a-dev1-simpledatalabs-io" {
  allocation_id = "${aws_eip.ap-south-1a-dev1-simpledatalabs-io.id}"
  subnet_id     = "${aws_subnet.utility-ap-south-1a-dev1-simpledatalabs-io.id}"
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.dev1-simpledatalabs-io.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.dev1-simpledatalabs-io.id}"
}

resource "aws_route" "private-ap-south-1a-0-0-0-0--0" {
  route_table_id         = "${aws_route_table.private-ap-south-1a-dev1-simpledatalabs-io.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.ap-south-1a-dev1-simpledatalabs-io.id}"
}

resource "aws_route53_record" "api-dev1-simpledatalabs-io" {
  name = "api.dev1.simpledatalabs.io"
  type = "A"

  alias = {
    name                   = "${aws_elb.api-dev1-simpledatalabs-io.dns_name}"
    zone_id                = "${aws_elb.api-dev1-simpledatalabs-io.zone_id}"
    evaluate_target_health = false
  }

  zone_id = "/hostedzone/Z30HWJWHQXIGXS"
}

resource "aws_route53_record" "bastion-dev1-simpledatalabs-io" {
  name = "bastion.dev1.simpledatalabs.io"
  type = "A"

  alias = {
    name                   = "${aws_elb.bastion-dev1-simpledatalabs-io.dns_name}"
    zone_id                = "${aws_elb.bastion-dev1-simpledatalabs-io.zone_id}"
    evaluate_target_health = false
  }

  zone_id = "/hostedzone/Z30HWJWHQXIGXS"
}

resource "aws_route_table" "dev1-simpledatalabs-io" {
  vpc_id = "${aws_vpc.dev1-simpledatalabs-io.id}"

  tags = {
    KubernetesCluster = "dev1.simpledatalabs.io"
    Name              = "dev1.simpledatalabs.io"
  }
}

resource "aws_route_table" "private-ap-south-1a-dev1-simpledatalabs-io" {
  vpc_id = "${aws_vpc.dev1-simpledatalabs-io.id}"

  tags = {
    KubernetesCluster = "dev1.simpledatalabs.io"
    Name              = "private-ap-south-1a.dev1.simpledatalabs.io"
  }
}

resource "aws_route_table_association" "private-ap-south-1a-dev1-simpledatalabs-io" {
  subnet_id      = "${aws_subnet.ap-south-1a-dev1-simpledatalabs-io.id}"
  route_table_id = "${aws_route_table.private-ap-south-1a-dev1-simpledatalabs-io.id}"
}

resource "aws_route_table_association" "utility-ap-south-1a-dev1-simpledatalabs-io" {
  subnet_id      = "${aws_subnet.utility-ap-south-1a-dev1-simpledatalabs-io.id}"
  route_table_id = "${aws_route_table.dev1-simpledatalabs-io.id}"
}

resource "aws_security_group" "api-elb-dev1-simpledatalabs-io" {
  name        = "api-elb.dev1.simpledatalabs.io"
  vpc_id      = "${aws_vpc.dev1-simpledatalabs-io.id}"
  description = "Security group for api ELB"

  tags = {
    KubernetesCluster = "dev1.simpledatalabs.io"
    Name              = "api-elb.dev1.simpledatalabs.io"
  }
}

resource "aws_security_group" "bastion-dev1-simpledatalabs-io" {
  name        = "bastion.dev1.simpledatalabs.io"
  vpc_id      = "${aws_vpc.dev1-simpledatalabs-io.id}"
  description = "Security group for bastion"

  tags = {
    KubernetesCluster = "dev1.simpledatalabs.io"
    Name              = "bastion.dev1.simpledatalabs.io"
  }
}

resource "aws_security_group" "bastion-elb-dev1-simpledatalabs-io" {
  name        = "bastion-elb.dev1.simpledatalabs.io"
  vpc_id      = "${aws_vpc.dev1-simpledatalabs-io.id}"
  description = "Security group for bastion ELB"

  tags = {
    KubernetesCluster = "dev1.simpledatalabs.io"
    Name              = "bastion-elb.dev1.simpledatalabs.io"
  }
}

resource "aws_security_group" "masters-dev1-simpledatalabs-io" {
  name        = "masters.dev1.simpledatalabs.io"
  vpc_id      = "${aws_vpc.dev1-simpledatalabs-io.id}"
  description = "Security group for masters"

  tags = {
    KubernetesCluster = "dev1.simpledatalabs.io"
    Name              = "masters.dev1.simpledatalabs.io"
  }
}

resource "aws_security_group" "nodes-dev1-simpledatalabs-io" {
  name        = "nodes.dev1.simpledatalabs.io"
  vpc_id      = "${aws_vpc.dev1-simpledatalabs-io.id}"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster = "dev1.simpledatalabs.io"
    Name              = "nodes.dev1.simpledatalabs.io"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev1-simpledatalabs-io.id}"
  source_security_group_id = "${aws_security_group.masters-dev1-simpledatalabs-io.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-dev1-simpledatalabs-io.id}"
  source_security_group_id = "${aws_security_group.masters-dev1-simpledatalabs-io.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-dev1-simpledatalabs-io.id}"
  source_security_group_id = "${aws_security_group.nodes-dev1-simpledatalabs-io.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "api-elb-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.api-elb-dev1-simpledatalabs-io.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.bastion-dev1-simpledatalabs-io.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion-elb-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.bastion-elb-dev1-simpledatalabs-io.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion-to-master-ssh" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev1-simpledatalabs-io.id}"
  source_security_group_id = "${aws_security_group.bastion-dev1-simpledatalabs-io.id}"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "bastion-to-node-ssh" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-dev1-simpledatalabs-io.id}"
  source_security_group_id = "${aws_security_group.bastion-dev1-simpledatalabs-io.id}"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "https-api-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.api-elb-dev1-simpledatalabs-io.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-elb-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev1-simpledatalabs-io.id}"
  source_security_group_id = "${aws_security_group.api-elb-dev1-simpledatalabs-io.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-dev1-simpledatalabs-io.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-dev1-simpledatalabs-io.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-tcp-4194" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev1-simpledatalabs-io.id}"
  source_security_group_id = "${aws_security_group.nodes-dev1-simpledatalabs-io.id}"
  from_port                = 4194
  to_port                  = 4194
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-443" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev1-simpledatalabs-io.id}"
  source_security_group_id = "${aws_security_group.nodes-dev1-simpledatalabs-io.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-6783" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev1-simpledatalabs-io.id}"
  source_security_group_id = "${aws_security_group.nodes-dev1-simpledatalabs-io.id}"
  from_port                = 6783
  to_port                  = 6783
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-6783" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev1-simpledatalabs-io.id}"
  source_security_group_id = "${aws_security_group.nodes-dev1-simpledatalabs-io.id}"
  from_port                = 6783
  to_port                  = 6783
  protocol                 = "udp"
}

resource "aws_security_group_rule" "node-to-master-udp-6784" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev1-simpledatalabs-io.id}"
  source_security_group_id = "${aws_security_group.nodes-dev1-simpledatalabs-io.id}"
  from_port                = 6784
  to_port                  = 6784
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-elb-to-bastion" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.bastion-dev1-simpledatalabs-io.id}"
  source_security_group_id = "${aws_security_group.bastion-elb-dev1-simpledatalabs-io.id}"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "ssh-external-to-bastion-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.bastion-elb-dev1-simpledatalabs-io.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_subnet" "ap-south-1a-dev1-simpledatalabs-io" {
  vpc_id            = "${aws_vpc.dev1-simpledatalabs-io.id}"
  cidr_block        = "172.20.32.0/19"
  availability_zone = "ap-south-1a"

  tags = {
    KubernetesCluster = "dev1.simpledatalabs.io"
    Name              = "ap-south-1a.dev1.simpledatalabs.io"
  }
}

resource "aws_subnet" "utility-ap-south-1a-dev1-simpledatalabs-io" {
  vpc_id            = "${aws_vpc.dev1-simpledatalabs-io.id}"
  cidr_block        = "172.20.0.0/22"
  availability_zone = "ap-south-1a"

  tags = {
    KubernetesCluster = "dev1.simpledatalabs.io"
    Name              = "utility-ap-south-1a.dev1.simpledatalabs.io"
  }
}

resource "aws_vpc" "dev1-simpledatalabs-io" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    KubernetesCluster = "dev1.simpledatalabs.io"
    Name              = "dev1.simpledatalabs.io"
  }
}

resource "aws_vpc_dhcp_options" "dev1-simpledatalabs-io" {
  domain_name         = "ap-south-1.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    KubernetesCluster = "dev1.simpledatalabs.io"
    Name              = "dev1.simpledatalabs.io"
  }
}

resource "aws_vpc_dhcp_options_association" "dev1-simpledatalabs-io" {
  vpc_id          = "${aws_vpc.dev1-simpledatalabs-io.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dev1-simpledatalabs-io.id}"
}
