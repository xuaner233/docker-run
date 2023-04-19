#!/bin/bash -e

##############################################################
# Run docker image with env setup
##############################################################

SCRIPT_DIR=$(dirname $(readlink -f $0))

###############################
# Args part
###############################
# Use 1st arg as image to run
DIMAGE="$1"
DBASEIMAGE=$(echo $DIMAGE | cut -d ':' -f 1)
DBASEIMAGE=${DBASEIMAGE##*/}

# shift the image, and get the rest of cmd and args
shift
DCMD="$*"

###############################
# Docker run cmd part
###############################
DRUNCMD="docker run "
DOPTIONS=" -it --rm "
# privilege and network
DOPTIONS+=" --privileged --network host "

# work dir, see mount ws below
DOPTIONS+=" -w=/ws "

# overwrite entrypoint with customed envsetup.sh
DOPTIONS+=" --entrypoint=/tmp/envsetup.sh "

# GPU
#DOPTIONS+=" --gpus all "

# Container name
CONTAINER_NAME=$(hostname)-$DBASEIMAGE
DOPTIONS+=" --name $CONTAINER_NAME --hostname $CONTAINER_NAME --add-host $CONTAINER_NAME:127.0.0.1 "

# user and group info
#DOPTIONS+=" --user $(id -u):$(id -g) "
DOPTIONS+=" -e DUSER=$(id -un) -e DUID=$(id -u) -e DGROUP=$(id -gn) -e DGID=$(id -g) "

# color term
DOPTIONS+=" -e TERM=xterm-color "

# mount options
DOPTIONS+=" -v $HOME:$HOME "
DOPTIONS+=" -v $SCRIPT_DIR/docker-run-envsetup.sh:/tmp/envsetup.sh "
DOPTIONS+=" -v $(pwd):/ws "

# get the docker run cmd
DOCKER_RUN_CMD="$DRUNCMD $DOPTIONS $DIMAGE $DCMD"
echo "
-----------------------------------------------------------
Running image [$DIMAGE] with cmd:

$DOCKER_RUN_CMD

-----------------------------------------------------------
"

###############################
# Run docker image
###############################
eval $DOCKER_RUN_CMD
