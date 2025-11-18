# Información de las instancias públicas
output "public_instances" {
  description = "IDs y direcciones IP (pública y privada) de las instancias EC2 públicas"
  value = [
    for inst in aws_instance.public : {
      id         = inst.id
      public_ip  = inst.public_ip
      private_ip = inst.private_ip
    }
  ]
}

# Información de las instancias privadas
output "private_instances" {
  description = "IDs y direcciones IP privadas de las instancias EC2 privadas"
  value = [
    for inst in aws_instance.private : {
      id         = inst.id
      private_ip = inst.private_ip
    }
  ]
}

# Nombre del bucket S3 (si existe)
output "s3_bucket_name" {
  description = "Nombre del bucket S3 creado, o null si no se ha creado"
  value       = try(aws_s3_bucket.project_bucket[0].bucket, null)
}
