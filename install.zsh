#!/bin/zsh
setopt EXTENDED_GLOB
SCRIPT_FILE=$0
SCRIPT_PATH=$(dirname $SCRIPT_FILE)
source ${SCRIPT_PATH}/base.zsh

TARGET="${HOME}/.hammerspoon"

cd ${SCRIPT_PATH}
link_dir ${PWD}/hammerspoon/init.lua ${TARGET}
