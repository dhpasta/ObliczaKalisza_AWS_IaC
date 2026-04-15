output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.ec2.public_ip
}

output "rds_cred_secret_arn" {
  value     = aws_secretsmanager_secret.rds_cred.arn
  sensitive = true
}

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.db.address
}

output "rds_password" {
  description = "RDS instance password"
  value       = random_password.db_password.result
  sensitive   = true
}

output "mysql_command" {
  description = "mysql command to log in to RDS"
  value       = "mysql -h ${aws_db_instance.db.address} -u admin -p data"
  sensitive   = true
}

output "ssh_command" {
  description = "ssh command to log in to EC2"
  value       = "ssh ubuntu@${aws_instance.ec2.public_ip}"
  sensitive   = true
}
