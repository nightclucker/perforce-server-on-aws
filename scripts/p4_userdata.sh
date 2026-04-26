#!/bin/bash
set -eux -o pipefail

trap 'catch $? $LINENO' ERR
catch() {
  echo ""
  echo "ERROR CAUGHT!"
  echo ""
  echo "Error code $1 occurred on line $2"
  echo ""
  exit $1
}

# Remove invalid hostname chars
export HOSTNAME="$(echo "p4-prod-commit" | tr _ -)"
export RESTORED_FROM_SNAPSHOT=false
export SWARM_IP=""
export DEPOT_CONTENT_SNAPSHOT=""
export AWS_REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
export P4D_AUTH_ID=${p4d_auth_id}
export CASE_SENSITIVITY=sensitive

export DEPOT_DEVICE="/dev/sdf"
export LOG_DEVICE="/dev/sdg"
export METADATA_DEVICE="/dev/sdh"

run-parts /opt/perforce-userdata-template/custom-pre/
run-parts /opt/perforce-userdata-template/default/
run-parts /opt/perforce-userdata-template/custom-post/

sudo -i -u perforce p4 configure set auth.id=$P4D_AUTH_ID
rm -f /p4/1/.p4tickets
sudo -i -u perforce p4login -v 1

# Publish success to SNS
echo "P4 Server Bootstrap Completed Successfully!"