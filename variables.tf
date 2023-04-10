# variables.tf

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "ap-south-1"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "myEcsTaskExecutionRole-prod"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "pub-count" {
  description = "Number of public subnet"
  default     = "2"
}

variable "env" {
  default = "customer-production"
}

variable "priv-count" {
  description = "Number of private subnet"
  default     = "3"
}

variable "environment" {
  default = "prod"
}
variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "540445519516.dkr.ecr.ap-south-1.amazonaws.com/brevistay-prod-ecr:v1"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3003
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 2
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "2048"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "4096"
}

variable "ecr_dev_name" {
  description = "repository for staging env"
  default     = "brevistay-prod-ecr"
}

/*variable "ecr_node_name" {
  description = "repository for node image"   // Created once using stage-env
  default     = "brevistay-node-ecr"
}*/

variable "expire_after" {
  description = "Number of days after which untagged images in a repository will expire"
  default     = 30
}

