module "vpc" {
  source = "./module/vpc"

  # Pass variables to VPC module
  vpc_id                    = "10.0.0.0/16"
  public_subnet_id_value    = "10.0.1.0/24"
  availability_zone_1       = "ap-south-1a"
  map_public_ip_on_launch   = "true" # Enable auto-assign public IP
  private_subnet_id_value_1 = "10.0.2.0/24"
  availability_zone_2       = "ap-south-1b"
  private_subnet_id_value_2 = "10.0.3.0/24"
  availability_zone_3       = "ap-south-1c"

}


module "ec2" {
  source = "./module/ec2_instance"

  # Pass variables to EC2 module
  ami_value                    = "ami-00bb6a80f01f03502" # data.aws_ami.ubuntu_24_arm.id                            
  instance_type_value          = "t3a.xlarge"
  key_name                     = "varma.pem"
  instance_count               = "1"
  public_subnet_id_value       = module.vpc.public_subnet_id
  associate_public_ip_address  = "true" # Enable a public IP
  availability_zone_1          = "ap-south-1a"
  vpc_id                       = module.vpc.vpc_id
  volume_size                  = "30"
  volume_type                  = "gp3"
  security_group_name          = "EKS_Ec2_Security_Group"
  worknode_security_group_pass = module.eks.worker_node_security_group_id
  # instance_tenancy       = "dedicated"
}


module "eks" {
  source = "./module/eks"

  # Pass variables to EKS module
  vpc_id                    = module.vpc.vpc_id
  security_group_name       = "EKS_Cluster_Security_Group"
  ec2_security_group_pass   = module.ec2.security_group_id
  vpc_cidr_block            = module.vpc.vpc_cidr_block
  role_name                 = "EKS_Cluster_Role_1"
  private_subnet_id_value_1 = module.vpc.private_subnet_id_value_1
  private_subnet_id_value_2 = module.vpc.private_subnet_id_value_2
  cluster_name              = "eks-1"
  worker_node_role          = "EKS_Workernode_Role_1"
  ebs_policy                = "EBS_Policy_1"

  # Pass variables to Worknode module
  ami_value                   = "ami-00bb6a80f01f03502" # data.aws_ami.ubuntu_24_arm.id                            
  instance_type_value         = "t3a.medium"
  key_name                    = "varma.pem"
  instance_count              = "1"
  associate_public_ip_address = "false" # Enable a public IP
  availability_zone_2         = "ap-south-1b"
  volume_size                 = "30"
  volume_type                 = "gp3"
  alb_security_name           = "EKS_ALB_Security_Group_1"
  worker_node_sg_name         = "Worker_Node_Security_Group_1"
  # instance_tenancy       = "dedicated"
}


# module "efs" {
#   source = "./module/efs"

#   vpc_id                  = module.vpc.vpc_id
#   public_subnet_id_value  = module.vpc.public_subnet_id
#   private_subnet_id_value = module.vpc.private_subnet_id
#   security_group_id       = module.eks.security_group_id
# } 


resource "null_resource" "Public_Server" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = module.ec2.elastic_ip[0] # Use the Elastic IP from the module
  }

  provisioner "file" {
    source      = "./module/ec2_instance/eks.sh"
    destination = "/home/ubuntu/eks.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "export $(grep -v '^#' /home/ubuntu/.env | xargs)",
      "mkdir -p /home/ubuntu/.aws",
      "echo '[default]' > /home/ubuntu/.aws/config",
      "echo 'region = ${var.region}' >> /home/ubuntu/.aws/config",
      "echo '[default]' > /home/ubuntu/.aws/credentials",
      "echo 'aws_access_key_id = ${var.access_key}' >> /home/ubuntu/.aws/credentials",
      "echo 'aws_secret_access_key = ${var.secret_key}' >> /home/ubuntu/.aws/credentials",

      # Optional: Clean up the .env file if not needed
      "rm /home/ubuntu/.env",

      "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
      "chmod +x kubectl",
      "aws eks --region ${var.region} describe-cluster --name ${module.eks.cluster_name} --query cluster.status",
      "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}",
      "sudo mv kubectl /usr/local/bin/",
      "sudo chmod +x /home/ubuntu/eks.sh",
      "sh /home/ubuntu/eks.sh"
    ]
  }

  depends_on = [module.ec2]
}


resource "null_resource" "Private_Server" {
  connection {
    type         = "ssh"
    user         = "ubuntu"
    private_key  = file(var.private_key_path)
    bastion_host = module.ec2.elastic_ip[0]
    host         = module.eks.private_ip[0] # Use the private IP from the module
  }

  provisioner "file" {
    source      = "./module/eks/attachment.sh"
    destination = "/home/ubuntu/attachment.sh"
  }

  provisioner "remote-exec" {
    inline = [


      "export $(grep -v '^#' /home/ubuntu/.env | xargs)",
      "mkdir -p /home/ubuntu/.aws",
      "echo '[default]' > /home/ubuntu/.aws/config",
      "echo 'region = ${var.region}' >> /home/ubuntu/.aws/config",
      "echo '[default]' > /home/ubuntu/.aws/credentials",
      "echo 'aws_access_key_id = ${var.access_key}' >> /home/ubuntu/.aws/credentials",
      "echo 'aws_secret_access_key = ${var.secret_key}' >> /home/ubuntu/.aws/credentials",

      # Optional: Clean up the .env file if not needed
      "rm /home/ubuntu/.env",

      # "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
      # "chmod +x kubectl",
      # "sudo mv kubectl /usr/local/bin/",
      # "aws eks --region ${var.region} describe-cluster --name ${module.eks.cluster_name} --query cluster.status",
      # "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}",

      "sudo chmod +x /home/ubuntu/attachment.sh",
      "sh /home/ubuntu/attachment.sh"
    ]
  }

  depends_on = [module.ec2, module.eks]
}