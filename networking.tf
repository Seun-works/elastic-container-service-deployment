resource "aws_vpc" "elastic_container_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "elastic_container_vpc"
  }

}

resource "aws_subnet" "elastic_container_subnets" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.elastic_container_vpc.id
  cidr_block              = var.subnets[each.key].cidr_block
  availability_zone       = var.subnets[each.key].availability_zone
  map_public_ip_on_launch = var.subnets[each.key].visibility == "public"

  tags = {
    Name = "elastic_container_subnet_${each.value.visibility}"
  }
}

resource "aws_internet_gateway" "elastic_container_igw" {
  vpc_id = aws_vpc.elastic_container_vpc.id

  tags = {
    Name = "elastic_container_igw"
  }

}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.elastic_container_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.elastic_container_igw.id
  }

}

resource "aws_route_table_association" "elastic_container_route_table_association" {
  for_each = { for key, value in aws_subnet.elastic_container_subnets : key => value if value.tags["Name"] == "elastic_container_subnet_public" }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "elastic_container_security_group" {
  vpc_id = aws_vpc.elastic_container_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elastic_container_security_group"
  }
}