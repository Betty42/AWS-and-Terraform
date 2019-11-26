terraform {
  backend "s3" {
    bucket         = "betty-tf-session3-bucket"
    key            = "stage/terraform.tfstate"
    region         = "us-east-1"
  }
}



# modules #

module "webserver_logs" {
  source = "../../stage/updated_env"
  providers = {
    aws = "aws.east1"
  }

  webserver_logs_bucket = "betty-tf-session3-bucket"
  webserver_remote_state_key    = "stage/updated_env/terraform.tfstate"
}
