#!/bin/bash
# scripts/set_tf_vars.sh

MY_IP=$(curl -s checkip.amazonaws.com)
export TF_VAR_allowed_ssh_cidrs='["'$MY_IP'/32"]'
export TF_VAR_allowed_p4_cidrs='["'$MY_IP'/32"]'

echo "Set SSH/P4 access to: $MY_IP/32"
