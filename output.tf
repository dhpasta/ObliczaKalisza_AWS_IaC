output "secret_arn" {
  value = aws_secretsmanager_secret.rds_cred.arn
  sensitive   = true
}

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.oblicza.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.oblicza.port
  sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.oblicza.username
}

output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.oblicza.public_ip
}