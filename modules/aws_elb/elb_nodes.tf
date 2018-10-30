resource "aws_instance" "elb_nodes" {
  count = "${var.create_elb && var.create_elb_nodes ? var.number_of_nodes : 0 }"

  instance_type = "t2.micro"
  ami           = "${var.aws_ami}"

  key_name = "${aws_key_pair.elb_nodes_key.key_name}"

  vpc_security_group_ids = [
    "${var.aws_security_groups}",
    "${aws_security_group.defaultLBnodes.*.id}",
  ]

  subnet_id = "${element(var.aws_public_subnets, count.index)}"

  user_data = <<HEREDOC
    #!/bin/bash
    yum update -y
    yum install -y mc nginx
    service nginx restart
HEREDOC

  tags {
    Name = "elb-node-${count.index+1}"
  }
}

resource "aws_key_pair" "elb_nodes_key" {
  count      = "${var.create_elb ? 1 : 0}"
  key_name   = "elb-admin-key"
  public_key = "ssh-rsa <key>/w== dima@dima.od.ua"
}
