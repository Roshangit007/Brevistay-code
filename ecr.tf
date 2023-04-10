/*resource "aws_ecr_repository" "stage-ecr" {
  name                 = var.ecr_stage_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}*/

resource "aws_ecr_repository" "prod-ecr" {
  name = "${var.ecr_dev_name}"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_lifecycle_policy" "ecr-repo-policy" {
  count      = "${(var.expire_after == 0)? 0 : 1}"
  repository = "${aws_ecr_repository.prod-ecr.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire untagged images older than ${var.expire_after} days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": ${var.expire_after}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

/*resource "aws_ecr_repository" "node-ecr" {
  name                 = var.ecr_node_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}*/