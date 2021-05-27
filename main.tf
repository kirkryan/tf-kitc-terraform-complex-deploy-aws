terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "kirkprivate"
  region  = "eu-west-1"
}

resource "aws_apprunner_auto_scaling_configuration_version" "apprunnerautoscaling" {
  auto_scaling_configuration_name = "kitc"

  max_concurrency = 50
  max_size        = 2
  min_size        = 1

  tags = {
    Name = "kitc-apprunner-autoscaling"
  }
}

resource "aws_apprunner_service" "kitc_multiplayer_demo" {
    auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.apprunnerautoscaling.arn
    service_name                   = "multiplayer-demo"
    tags                           = {}
    tags_all                       = {}

    health_check_configuration {
        healthy_threshold   = 1
        interval            = 10
        path                = "/"
        protocol            = "TCP"
        timeout             = 5
        unhealthy_threshold = 5
    }

    source_configuration {
        auto_deployments_enabled = false

        authentication_configuration {
            access_role_arn = ""
        }

        image_repository {
            image_identifier      = "public.ecr.aws/m0m0y9h5/kirkryan:latest"
            image_repository_type = "ECR"

            image_configuration {
                port                          = "3000"
                runtime_environment_variables = {}
                start_command                 = "npm start"
            }
        }
    }
}


