# Datos de las zonas de disponibilidad
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC principal
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

# Subredes públicas
resource "aws_subnet" "public" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name    = "${var.project_name}-public-${count.index}"
    Project = var.project_name
    Type    = "public"
  }
}

# Subredes privadas
resource "aws_subnet" "private" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + var.subnet_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name    = "${var.project_name}-private-${count.index}"
    Project = var.project_name
    Type    = "private"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

# Route table pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}

# Asociaciones de la route table pública
resource "aws_route_table_association" "public" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

  depends_on = [aws_internet_gateway.igw]
}

# Security Group para las instancias
resource "aws_security_group" "instances_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for web and SSH access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH only from my_ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Allow ICMP only from within the VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

# Locals para manejar las listas de subnets
locals {
  public_subnet_ids  = aws_subnet.public[*].id
  private_subnet_ids = aws_subnet.private[*].id
}

# Instancias EC2 en subredes públicas
resource "aws_instance" "public" {
  count         = var.subnet_count * var.instance_count
  ami           = var.instance_ami
  instance_type = var.instance_type

  subnet_id = local.public_subnet_ids[count.index % var.subnet_count]

  vpc_security_group_ids      = [aws_security_group.instances_sg.id]
  associate_public_ip_address = true

  tags = {
    Name    = "${var.project_name}-public-${count.index}"
    Project = var.project_name
    Role    = "public"
  }

  depends_on = [aws_route_table_association.public]
}

# Instancias EC2 en subredes privadas
resource "aws_instance" "private" {
  count         = var.subnet_count * var.instance_count
  ami           = var.instance_ami
  instance_type = var.instance_type

  subnet_id = local.private_subnet_ids[count.index % var.subnet_count]

  vpc_security_group_ids      = [aws_security_group.instances_sg.id]
  associate_public_ip_address = false

  tags = {
    Name    = "${var.project_name}-private-${count.index}"
    Project = var.project_name
    Role    = "private"
  }
}

# Bucket S3 condicional
resource "aws_s3_bucket" "project_bucket" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = "${var.project_name}-bucket"

  tags = {
    Name    = "${var.project_name}-bucket"
    Project = var.project_name
  }
}
