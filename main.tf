resource "aws_security_group" "main" {
  name        = "${var.env}-${var.component}-security_group"
  description = "${var.env}-${var.component}-security_group"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-${var.component}-surity_group" }
  )
}

resource "aws_launch_template" "main" {
  name_prefix = "${var.env}-${var.component}-template"
  image_id = data.aws_ami.centos8.id
  instance_type = var.instance_type
}

resource "aws_autoscaling_group" "asg" {
  name                      = "${var.env}-${var.component}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = var.desired_capacity
  force_delete              = true
  vpc_zone_identifier       = var.subnet_ids

  dynamic "tag" {
    for_each = var.all_tags
    content {
      key = each.key
      value = each.value
      propagate_at_launch = true
    }
  }
}
