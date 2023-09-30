resource "aws_lightsail_instance_public_ports" "x" {
  instance_name = aws_lightsail_instance.x.name

  port_info {
    protocol          = "tcp"
    from_port         = 22
    to_port           = 22
    cidr_list_aliases = []
    cidrs             = ["0.0.0.0/0"]
    ipv6_cidrs        = ["::/0"]
  }
  port_info {
    protocol          = "tcp"
    from_port         = 80
    to_port           = 80
    cidr_list_aliases = []
    cidrs             = ["0.0.0.0/0"]
    ipv6_cidrs        = ["::/0"]
  }
  port_info {
    protocol          = "tcp"
    from_port         = 443
    to_port           = 443
    cidr_list_aliases = []
    cidrs             = ["0.0.0.0/0"]
    ipv6_cidrs        = ["::/0"]
  }
}