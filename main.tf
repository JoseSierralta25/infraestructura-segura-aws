variable "password" {
  description = "Contraseña para la base de datos"
  type        = string
  sensitive   = true
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

#########################
#  CONFIGURACIÓN GLOBAL #
#########################

variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "allowed_cidr" {
  description = "CIDR autorizado para acceder a la base de datos (solo para pruebas)."
  type        = string
  default     = "10.0.0.0/16"
}

#########################
#  SECRETO DE CONTRASEÑA #
#########################

# La contraseña se debe suministrar desde fuera del código (tfvars / variables de entorno) para evitar exponerla en el repositorio.
#########################
#  SEGURIDAD / DB RDS   #
#########################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Permite acceso al puerto 3306 desde la red autorizada"

  ingress {
    description = "Acceso MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
  description = "Subnet group para RDS"
}

resource "aws_db_instance" "base_de_datos" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username                 = "admin"
  password                 = var.password
  publicly_accessible      = false
  storage_encrypted        = true
  backup_retention_period  = 7
  deletion_protection      = true
  skip_final_snapshot      = false

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
}