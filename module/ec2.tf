resource "aws_instance" "bastion" {
  ami                         = "ami-02d081c743d676996"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.Bastion_SG.id]
  subnet_id                   = aws_subnet.kjwook-pub-a.id
  associate_public_ip_address = true
  key_name                    = "kjwook"
  tags = {
    Name = "bastion"
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_instance" "kjwook-test-a" {
  ami                         = "ami-02d081c743d676996"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.kjwook_pub_SG.id]
  subnet_id                   = aws_subnet.kjwook-pub-a.id
  associate_public_ip_address = true
  user_data                   = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install httpd -y
              echo "<h1>Hello world from highly available group of ec2-a instances</h1>" > /var/www/html/index.html
              sudo systemctl start httpd
              sudo systemctl enable httpd
              EOF
  key_name                    = "kjwook"
  tags = {
    Name = "web-server-a"
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_instance" "kjwook-test-c" {
  ami                         = "ami-02d081c743d676996"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.kjwook_pub_SG.id]
  subnet_id                   = aws_subnet.kjwook-pub-c.id
  associate_public_ip_address = true
  user_data                   = filebase64("./server.sh")
  key_name                    = "kjwook"
  tags = {
    Name = "web-server-c"
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_instance" "jenkins-test" {
  ami                         = "ami-02d081c743d676996"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.kjwook_pub_SG.id]
  subnet_id                   = aws_subnet.kjwook-pub-c.id
  associate_public_ip_address = true
  #user_data = filebase64("./server.sh")
  key_name = "kjwook"
  tags = {
    Name = "jenkins-test"
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_instance" "ubuntu-test" {
  ami                         = "ami-0f3a440bbcff3d043"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.kjwook_pub_SG.id]
  subnet_id                   = aws_subnet.kjwook-pub-c.id
  associate_public_ip_address = true
  #user_data = filebase64("./server.sh")
  key_name = "kjwook"
  tags = {
    Name = "ubuntu-test"
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_instance" "docker-test" {
  ami                         = "ami-0f3a440bbcff3d043"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.kjwook_pub_SG.id]
  subnet_id                   = aws_subnet.kjwook-pub-c.id
  associate_public_ip_address = true
  #user_data = filebase64("./server.sh")
  key_name = "kjwook"
  tags = {
    Name = "docker-test"
  }
  lifecycle {
    ignore_changes = all
  }
}

# 로드밸런서 생성하기
resource "aws_alb" "kjwook-alb" {
  name                             = "kjwook-alb"
  internal                         = false # 외부 트래픽 접근 가능
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.kjwook_pub_SG.id]
  subnets                          = [aws_subnet.kjwook-pub-a.id, aws_subnet.kjwook-pub-c.id]
  enable_cross_zone_load_balancing = true
}

# 대상그룹 생성하기
resource "aws_alb_target_group" "kjwook_tg" {
  name        = "kjwook-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  health_check {
    interval            = 30
    path                = "/"
    port                = 80
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_alb_target_group_attachment" "kjwook-test-a" {
  target_group_arn = aws_alb_target_group.kjwook_tg.arn
  target_id        = aws_instance.kjwook-test-a.id
  port             = 80
}

resource "aws_alb_target_group_attachment" "kjwook-test-c" {
  target_group_arn = aws_alb_target_group.kjwook_tg.arn
  target_id        = aws_instance.kjwook-test-c.id
  port             = 80
}

# 로드밸런서 Listener 생성하기
resource "aws_alb_listener" "kjwook-alb-listener" {
  load_balancer_arn = aws_alb.kjwook-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward" # forward or redirect or fixed-response
    target_group_arn = aws_alb_target_group.kjwook_tg.arn
  }
}





