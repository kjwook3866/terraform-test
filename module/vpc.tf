resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

#라우팅 테이블
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
  tags = {
    Name = "main-rt"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "route_table_association_1" {
  subnet_id      = aws_subnet.kjwook-pub-a.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_route_table_association" "route_table_association_2" {
  subnet_id      = aws_subnet.kjwook-pub-c.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_route_table_association" "route_table_association_3" {
  subnet_id      = aws_subnet.kjwook-pri-a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "route_table_association_4" {
  subnet_id      = aws_subnet.kjwook-pri-c.id
  route_table_id = aws_route_table.private_route_table.id
}


#서브넷 설정
resource "aws_subnet" "kjwook-pub-a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "kjwook-pub-a"
  }
}

resource "aws_subnet" "kjwook-pub-c" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "kjwook-pub-c"
  }
}

resource "aws_subnet" "kjwook-pri-a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "kjwook-pri-a"
  }
}

resource "aws_subnet" "kjwook-pri-c" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "kjwook-pri-c"
  }
}

#Bastion 보안 그룹
resource "aws_security_group" "Bastion_SG" {
  vpc_id      = aws_vpc.main.id
  name        = "kjwook-basiton-SG"
  description = "kjwook-basiton-SG"
  tags = {
    Name = "kjwook-basiton-SG"
  }

}

resource "aws_security_group_rule" "Bastion_SG_RulesSSHingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.Bastion_SG.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "Bastion_SG_RulesALLegress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "ALL"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.Bastion_SG.id
  lifecycle {
    create_before_destroy = true
  }
}

# #로드밸런서 보안 그룹
# resource "aws_security_group" "kjwook_alb_SG" {
#     vpc_id = aws_vpc.main.id
#     name = "kjwook_alb_SG"
#     description = "kjwook_alb_SG"
#     tags = {
#         Name = "kjwook_alb_SG"
#     }
# }

# resource "aws_security_group_rule" "kjwook_alb_SG_RulesHTTPingress" {
#     type = "ingress"
#     from_port = 80
#     to_port=80
#     protocol = "TCP"
#     cidr_blocks = ["0.0.0.0/0"]
#     security_group_id = aws_security_group.kjwook_alb_SG.id
#     lifecycle{
#         create_before_destroy = true
#     }
# }

# resource "aws_security_group_rule" "kjwook_alb_SG_RulesALLegress" {
#     type = "egress"
#     from_port = 0
#     to_port= 0
#     protocol = "ALL"
#     cidr_blocks=["0.0.0.0/0"]
#     security_group_id = aws_security_group.kjwook_alb_SG.id
#     lifecycle{
#         create_before_destroy = true
#     }
# }


#WEB 보안 그룹
resource "aws_security_group" "kjwook_pub_SG" {
  vpc_id      = aws_vpc.main.id
  name        = "kjwook-pub-SG"
  description = "kjwook-pub-SG"
  tags = {
    Name = "kjwook-pub-SG"
  }
}

resource "aws_security_group_rule" "kjwook_pub_SG_RulesHTTPingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kjwook_pub_SG.id
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "kjwook_pub_SG_Rulesjenkinsingress" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kjwook_pub_SG.id
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "kjwook_pub_SG_RulesRDSingress" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kjwook_pub_SG.id
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "kjwook_pub_SG_RulesSSHingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kjwook_pub_SG.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "kjwook_pub_SG_RulesALLegress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "ALL"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kjwook_pub_SG.id
  lifecycle {
    create_before_destroy = true
  }
}

#프라이빗 보안 그룹
resource "aws_security_group" "kjwook_pri_SG" {
  vpc_id      = aws_vpc.main.id
  name        = "kjwook-pri-SG"
  description = "kjwook-pri-SG"
  tags = {
    Name = "kjwook-pri-SG"
  }
}
#프라이빗 보안 그룹 규칙
resource "aws_security_group_rule" "kjwook_pri_SG_RulesRDSingress" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "TCP"
  security_group_id        = aws_security_group.kjwook_pri_SG.id
  source_security_group_id = aws_security_group.kjwook_pri_SG.id
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "kjwook_pri_SG_RulesRDSegress" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "TCP"
  security_group_id        = aws_security_group.kjwook_pri_SG.id
  source_security_group_id = aws_security_group.kjwook_pri_SG.id
  lifecycle {
    create_before_destroy = true
  }
}




