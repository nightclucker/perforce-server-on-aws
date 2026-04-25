#!/bin/bash
# scripts/set_tf_vars.sh

MY_IP=$(curl -s checkip.amazonaws.com)
export TF_VAR_allowed_ssh_cidrs='["'$MY_IP'/32"]'


echo "Set SSH access to: $MY_IP/32"
