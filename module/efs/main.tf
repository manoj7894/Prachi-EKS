resource "aws_efs_file_system" "my_efs" {
  creation_token = "my-efs-${var.vpc_id}"

  tags = {
    Name = "MyEFS"
  }
}

resource "aws_efs_mount_target" "my_mount_target" {
  count             = length([var.public_subnet_id_value, var.private_subnet_id_value])  # Adjust if needed
  file_system_id    = aws_efs_file_system.my_efs.id
  subnet_id         = element([var.public_subnet_id_value, var.private_subnet_id_value], count.index)
  security_groups = [var.security_group_id]
}