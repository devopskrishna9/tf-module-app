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

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "${var.env}-docdb-cluster"
  engine                  = "docdb"
  engine_version = var.engine_version
  master_username         = data.aws_ssm_parameter.DB_ADMIN_USER.value
  master_password         = data.aws_ssm_parameter.DB_ADMIN_PASS.value
  skip_final_snapshot     = true
  db_subnet_group_name = aws_docdb_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.docdb.id]
  storage_encrypted = true
  kms_key_id = data.aws_kms_key.key.arn

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-docdb-cluster" }
  )
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = var.number_of_instances
  identifier         = "${var.env}-docdb-cluster-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = var.instance_class

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-docdb-cluster-instance-${count.index}" }
  )
}

