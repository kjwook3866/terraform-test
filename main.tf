terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# resource "aws_key_pair" "kjwook" {
#   key_name   = "kjwook"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCLb1pD6WeydHBe4AT7ECKY46n3zq/Nd9YD4EZbtmgcJI9mPDikNaBuV0YJoLJY6HpeTotKWFbQQsokKXfv+8axJzMxIEtcVIlDG4M77in5EvVozPzw2k45XFN2tKQOqBUXtffuNIe0EnMh3osoGwVYMfKG6NMuVgS7doxUzKSNMCL0olXQRwwy0nQxAPQn06PlfxQA/atbzZpBI6V7IQuYQ7JsbAQpCz6HamUVmIk7zfZLANzXVCNacivDn4Z+RLhwTdZqAziqScICDdjrnaRrgVj7Tmoj3s0e8Al8otRFwLRKc0ivv0wTZQtNOE8DOOEKo25bSFBMfRTXBQDATrC5 kjwook"
# }






