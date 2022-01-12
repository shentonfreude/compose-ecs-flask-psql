# Allow overrides for tag, region, context name
TAG_NAME	 ?= cshenton/flaskapp
AWS_REGION       ?= us-east-1
ECS_CONTEXT	 ?= wp-dev

AWS_ACCT         := $(shell aws sts get-caller-identity --query Account --output text)
GIT_HASH         := $(shell git rev-parse --short HEAD || echo NOGIT)
TAG_SUFFIXED     := ${TAG_NAME}:latest
AWS_ECR_URI      := ${AWS_ACCT}.dkr.ecr.${AWS_REGION}.amazonaws.com
AWS_ECR_TAG      := ${AWS_ECR_URI}/${TAG_SUFFIXED}
AWS_ECR_TAG_HASH := ${AWS_ECR_URI}/${TAG_SUFFIXED}-${GIT_HASH}


# We must build locally, and we can run it locally too

build:
	AWS_ACCT=${AWS_ACCT} AWS_REGION=${AWS_REGION} docker --context default compose build

run:
	docker --context default compose up

# only need to do this once
ecr_repo:
	aws ecr create-repository --repository-name ${TAG_NAME}

# Must tag our local short name with one that ECR recognizes
ecr_tag:
	docker --context default tag ${TAG_NAME} ${AWS_ECR_TAG}
	docker --context default tag ${TAG_NAME} ${AWS_ECR_TAG_HASH}

ecr_login:
	aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ECR_URI}

ecr_push: ecr_tag ecr_login
	docker --context default push ${AWS_ECR_TAG}
	docker --context default push ${AWS_ECR_TAG_HASH}

ecr_list:
	aws ecr describe-images --repository-name ${TAG_NAME}

# Explicit config files avoid using local-only features from .override.
up:
	AWS_ACCT=${AWS_ACCT} AWS_REGION=${AWS_REGION} \
	docker --context ${ECS_CONTEXT} \
	compose -f docker-compose.yml -f docker-compose.ecs.yml up

deploy: ecr_tag ecr_push up

down:
	docker --context ${ECS_CONTEXT} compose down

convert: ecr_login
	docker --context ${ECS_CONTEXT} compose convert > cloudformation-`date +%Y%m%dT%H%M%S`.yml

logs:
	docker --context ${ECS_CONTEXT} compose logs

ps:
	docker --context ${ECS_CONTEXT} compose ps
