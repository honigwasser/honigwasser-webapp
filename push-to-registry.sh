#!/bin/bash

DOCKER_IMAGE="$1"

if [ -z "$DOCKER_IMAGE" ]
then
	echo "Docker image not provided, cannot push anything"
	exit 1
fi

if ! type aws >/dev/null 2>&1
then
	echo "AWS CLI is not available, please install via 'apt install awscli'"
	exit 1
fi

if [[ "$DOCKER_IMAGE" =~ ^[^/]+/([^:]+).* ]]
then
	REPOSITORY="${BASH_REMATCH[1]}"
else
	echo ${BASH_REMATCH[1]}
	echo "Docker image $DOCKER_IMAGE doesn't follow pattern HOST/IMAGE:TAG, not supported"
	exit 1
fi

if ! aws ecr describe-repositories --repository-names "$REPOSITORY" >/dev/null 2>&1
then
	echo "Creating repository $REPOSITORY at AWS ECR"
	aws ecr create-repository --repository-name "$REPOSITORY"
fi

docker push "$DOCKER_IMAGE"
