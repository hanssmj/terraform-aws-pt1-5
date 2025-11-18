# Región de AWS donde se desplegarán los recursos
variable "region" {
  description = "Región de AWS donde se despliegan los recursos"
  type        = string
  default     = "us-east-1"
}

# Nombre del proyecto, se usa en tags y nombres de recursos
variable "project_name" {
  description = "Nombre del proyecto para etiquetar recursos"
  type        = string
  default     = "asix2opt-pt1-5"
}

# Número de instancias EC2 por subred
variable "instance_count" {
  description = "Número de instancias EC2 por cada subnet (pública y privada)"
  type        = number
  default     = 1
}

# Número de subredes públicas y privadas
variable "subnet_count" {
  description = "Número de subredes públicas y privadas a crear"
  type        = number
  default     = 2
}

# Tipo de instancia EC2
variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

# AMI a usar para las instancias EC2
variable "instance_ami" {
  description = "ID de la AMI de AWS para las instancias EC2"
  type        = string
  default     = "ami-0cae6d6fe6048ca2c"
}

# Si es true, se creará un bucket S3
variable "create_s3_bucket" {
  description = "Indica si se debe crear un bucket S3"
  type        = bool
  default     = false
}

# Rango de red de la VPC
variable "vpc_cidr" {
  description = "Rango de red de la VPC en notación CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

# Rango
variable "my_ip" {
  description = "Rango CIDR desde el que se permite acceso SSH"
  type        = string
  default     = "0.0.0.0/0"
}
