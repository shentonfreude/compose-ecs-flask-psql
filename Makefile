TAG_NAME := cshenton/flaskapp

AWS_ACCT         := $(shell aws sts get-caller-identity --query Account --output text)
AWS_REGION       := us-east-1
GIT_HASH         := $(shell git rev-parse --short HEAD || echo NOGIT)
TAG_SUFFIXED     := ${TAG_NAME}:latest
AWS_ECR_URI      := ${AWS_ACCT}.dkr.ecr.${AWS_REGION}.amazonaws.com
AWS_ECR_TAG      := ${AWS_ECR_URI}/${TAG_SUFFIXED}
AWS_ECR_TAG_HASH := ${AWS_ECR_URI}/${TAG_SUFFIXED}-${GIT_HASH}


build:
	docker --context default compose build

run:
	docker --context default compose up

# only need to do this once
ecr_repo:
	aws ecr create-repository --repository-name ${TAG_NAME}

# If we want a different tag than that spec'd in compose
ecr_tag:
	docker --context default tag ${AWS_ECR_TAG} ${AWS_ECR_TAG_HASH}

ecr_login:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${AWS_ECR_URI}

ecr_push: ecr_tag ecr_login
	docker --context default push ${AWS_ECR_TAG}
	docker --context default push ${AWS_ECR_TAG_HASH}

ecr_list:
	aws ecr describe-images --repository-name ${TAG_NAME}

# Don't use localhost features from .override.
up up_ecs:
	docker --context wp-dev compose -f docker-compose.yml up

deploy: ecr_tag ecr_push up_ecs

down:
	docker --context wp-dev compose down

convert: ecr_login
	docker --context wp-dev compose convert >cloudformation.yml

logs:
	docker --context wp-dev compose logs

ps:
	docker --context wp-dev compose ps
