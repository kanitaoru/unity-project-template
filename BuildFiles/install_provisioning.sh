#! /bin/sh -e
# ProvisioningProfileディレクトリに入っているmobileprovisionをxcode認識ディレクトリにコピーする

GIT_ROOT=`git rev-parse --show-toplevel`
echo "===== Install Provisioning Profiles =====" 1>&2

PROVISIONING_PROFILE_DIR="${GIT_ROOT}/BuildFiles/ProvisioningProfile"
XCODE_PROVISION_DIR="${HOME}/Library/MobileDevice/Provisioning Profiles"

cp -v ${PROVISIONING_PROFILE_DIR}/*.mobileprovision "$XCODE_PROVISION_DIR" 1>&2
