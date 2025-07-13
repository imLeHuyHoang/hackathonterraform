# Compute Module Outputs

# Lambda Function Outputs
output "data_processor_function_name" {
  description = "Name of the data processor Lambda function"
  value       = aws_lambda_function.data_processor.function_name
}

output "data_processor_function_arn" {
  description = "ARN of the data processor Lambda function"
  value       = aws_lambda_function.data_processor.arn
}

# Lambda function ARNs
output "lambda_function_arns" {
  description = "List of all Lambda function ARNs"
  value = [
    aws_lambda_function.data_processor.arn
  ]
}

output "lambda_function_names" {
  description = "List of all Lambda function names"
  value = [
    aws_lambda_function.data_processor.function_name
  ]
}

# Lambda Permissions for S3
output "lambda_permission_for_s3_data_processor" {
  description = "Lambda permission resource for S3 to invoke data processor"
  value       = aws_lambda_permission.s3_invoke_data_processor.id
}

# CloudWatch Log Groups
output "log_group_names" {
  description = "CloudWatch log group names"
  value = {
    data_processor = aws_cloudwatch_log_group.data_processor_logs.name
  }
}

# Ec2 output
output "win2016_instance_id" {
  description = "Instance ID of Windows Server 2016"
  value       = aws_instance.win2016.id
}

output "win2019_instance_id" {
  description = "Instance ID of Windows Server 2019"
  value       = aws_instance.win2019.id
}

output "win2022_instance_id" {
  description = "Instance ID of Windows Server 2022"
  value       = aws_instance.win2022.id
}

output "win2016_private_ip" {
  description = "Private IP of Windows Server 2016"
  value       = aws_instance.win2016.private_ip
}

output "win2019_private_ip" {
  description = "Private IP of Windows Server 2019"
  value       = aws_instance.win2019.private_ip
}

output "win2022_private_ip" {
  description = "Private IP of Windows Server 2022"
  value       = aws_instance.win2022.private_ip
}

# Key Pair Outputs
output "key_pair_name" {
  description = "Name of the generated EC2 key pair"
  value       = aws_key_pair.ec2_key.key_name
}

output "key_pair_fingerprint" {
  description = "Fingerprint of the generated key pair"
  value       = aws_key_pair.ec2_key.fingerprint
}

output "private_key_filename" {
  description = "Path to the generated private key file"
  value       = local_file.private_key.filename
}

output "public_key_filename" {
  description = "Path to the generated public key file"
  value       = local_file.public_key.filename
}

# Windows Password Decryption Info
output "windows_password_data" {
  description = "Windows password data for all instances (encrypted)"
  value = {
    win2016 = aws_instance.win2016.password_data
    win2019 = aws_instance.win2019.password_data
    win2022 = aws_instance.win2022.password_data
  }
  sensitive = true
}
