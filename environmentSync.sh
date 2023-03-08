#!/bin/bash
# This script will sync the environment from one server to another
set -e

directyPath=$(pwd)
old_brach=$1 # dev-001,stage-001 (branch name of the old environment)
new_branch=$2 # stage-sync, prod-sync (branch name of the new environment(a locally created branch))
old_env=$3 # dev, stage (old environment name)
new_env=$4 # stage, prod (new environment name)

# This command can be used to execute the script : ./environemntSync.sh dev-001 stage-sync dev stage

# Checkout the old branch and get the version details

function query_service () {
    local env=$1
    local QUERY_SERVICE_IMAGE_SHA=$(grep 'IMAGE_SHA' $directyPath/cd-pipelines/query-service/"$env"-setup-variables.yaml)
    QUERY_SERVICE_IMAGE_SHA=$(echo $QUERY_SERVICE_IMAGE_SHA | cut -c12-)
    local QUERY_SERVICE_VERSION=$(grep 'QUERY_SERVICE_VERSION' $directyPath/cd-pipelines/query-service/"$env"-setup-variables.yaml)
    QUERY_SERVICE_VERSION=$(echo $QUERY_SERVICE_VERSION | cut -c25-)
    local QUERY_SERVICE_HELM_VERSION=$(grep 'ref: refs/tags/' $directyPath/cd-pipelines/query-service/"$env"-deploy-001.yaml)
    QUERY_SERVICE_HELM_VERSION=$(echo "${QUERY_SERVICE_HELM_VERSION}" | awk '{$1=$1;print}'| cut -c5-)
    echo "$QUERY_SERVICE_IMAGE_SHA $QUERY_SERVICE_VERSION $QUERY_SERVICE_HELM_VERSION"
}

function resource_monitor () {
    local env=$1
    local RESOURCE_MONITOR_IMAGE_SHA=$(grep 'IMAGE_SHA' $directyPath/cd-pipelines/resource-monitor/"$env"-setup-variables.yaml)
    RESOURCE_MONITOR_IMAGE_SHA=$(echo $RESOURCE_MONITOR_IMAGE_SHA | cut -c12-)
    local RESOURCE_MONITOR_VERSION=$(grep 'RESOURCE_MONITOR_VERSION' $directyPath/cd-pipelines/resource-monitor/"$env"-setup-variables.yaml)
    RESOURCE_MONITOR_VERSION=$(echo $RESOURCE_MONITOR_VERSION | cut -c28-)
    local RESOURCE_MONITOR_HELM_VERSION=$(grep 'ref: refs/tags/' $directyPath/cd-pipelines/resource-monitor/"$env"-deploy-001.yaml)
    RESOURCE_MONITOR_HELM_VERSION=$(echo "${RESOURCE_MONITOR_HELM_VERSION}" | awk '{$1=$1;print}'| cut -c5-)
    echo "$RESOURCE_MONITOR_IMAGE_SHA $RESOURCE_MONITOR_VERSION $RESOURCE_MONITOR_HELM_VERSION"
}

function identity_server () {
    local env=$1
#    local TEST_VERSION_LINE=$(grep -w 'TEST_VERSION' $directyPath/cd-pipelines/identity-server/"$env"-test-variables.yaml | sed 's/ *//')"
    local IS_IMAGE_SHA=$(grep 'IMAGE_SHA' $directyPath/cd-pipelines/identity-server/"$env"-setup-variables.yaml)
    IS_IMAGE_SHA=$(echo $IS_IMAGE_SHA | cut -c12-)
    local IS_VERSION=$(grep 'IS_VERSION' $directyPath/cd-pipelines/identity-server/"$env"-setup-variables.yaml)
    IS_VERSION=$(echo $IS_VERSION | cut -c12-)
    local ASGARDEO_VERSION=$(grep 'ASGARDEO_BUILD_VERSION' $directyPath/cd-pipelines/identity-server/"$env"-setup-variables.yaml)
    ASGARDEO_VERSION=$(echo $ASGARDEO_VERSION | cut -c25-)
    local IS_HELM_VERSION=$(grep 'HELM_VERSION' $directyPath/cd-pipelines/identity-server/"$env"-setup-variables.yaml)
    IS_HELM_VERSION=$(echo $IS_HELM_VERSION | cut -c15-)
    local TEST_VERSION=$(grep 'TEST_VERSION' $directyPath/cd-pipelines/identity-server/"$env"-test-variables.yaml)
    TEST_VERSION=$(echo $TEST_VERSION | cut -c15-)
    echo "$IS_IMAGE_SHA $IS_VERSION $ASGARDEO_VERSION $IS_HELM_VERSION $TEST_VERSION"
}

function website () {
    local env=$1
    local WEBSITE_IMAGE_SHA=$(grep 'IMAGE_SHA' $directyPath/cd-pipelines/cloud-website/"$env"-setup-variables.yaml)
    WEBSITE_IMAGE_SHA=$(echo $WEBSITE_IMAGE_SHA | cut -c12-)
    local WEBSITE_VERSION=$(grep 'WEBSITE_VERSION' $directyPath/cd-pipelines/cloud-website/"$env"-setup-variables.yaml)
    WEBSITE_VERSION=$(echo $WEBSITE_VERSION | cut -c18-)
    local WEBSITE_HELM_VERSION=$(grep 'HELM_VERSION' $directyPath/cd-pipelines/cloud-website/"$env"-setup-variables.yaml)
    WEBSITE_HELM_VERSION=$(echo $WEBSITE_HELM_VERSION | cut -c15-)
    echo "$WEBSITE_IMAGE_SHA $WEBSITE_VERSION $WEBSITE_HELM_VERSION"
}

function activemq () {
    local env=$1
    local ACTIVEMQ_IMAGE_SHA=$(grep 'IMAGE_SHA' $directyPath/cd-pipelines/activemq/"$env"-setup-variables.yaml)
    ACTIVEMQ_IMAGE_SHA=$(echo $ACTIVEMQ_IMAGE_SHA | cut -c12-)
    local ACTIVEMQ_VERSION=$(grep 'ACTIVEMQ_VERSION' $directyPath/cd-pipelines/activemq/"$env"-setup-variables.yaml)
    ACTIVEMQ_VERSION=$(echo $ACTIVEMQ_VERSION | cut -c19-)
    local ACTIVEMQ_HELM_VERSION=$(grep 'ref: refs/tags/' $directyPath/cd-pipelines/activemq/"$env"-deploy-001.yaml)
    ACTIVEMQ_HELM_VERSION=$(echo "${ACTIVEMQ_HELM_VERSION}" | awk '{$1=$1;print}'| cut -c5-)
    echo "$ACTIVEMQ_IMAGE_SHA $ACTIVEMQ_VERSION $ACTIVEMQ_HELM_VERSION"
}

function log_mgt () {
    local env=$1
    local LOG_MGT_IMAGE_SHA=$(grep 'IMAGE_SHA' $directyPath/cd-pipelines/log-mgt/"$env"-setup-variables.yaml)
    LOG_MGT_IMAGE_SHA=$(echo $LOG_MGT_IMAGE_SHA | cut -c12-)
    local LOG_MGT_VERSION=$(grep 'LOG_MGT_VERSION' $directyPath/cd-pipelines/log-mgt/"$env"-setup-variables.yaml)
    LOG_MGT_VERSION=$(echo $LOG_MGT_VERSION | cut -c18-)
    local LOG_MGT_HELM_VERSION=$(grep 'ref: refs/tags/' $directyPath/cd-pipelines/log-mgt/"$env"-deploy-001.yaml)
    LOG_MGT_HELM_VERSION=$(echo "${LOG_MGT_HELM_VERSION}" | awk '{$1=$1;print}'| cut -c5-)
    echo "$LOG_MGT_IMAGE_SHA $LOG_MGT_VERSION $LOG_MGT_HELM_VERSION"
}

function onprem_userstore () {
    local env=$1
    local ONPREM_USERSTORE_IMAGE_SHA=$(grep 'IMAGE_SHA' $directyPath/cd-pipelines/onprem-userstore/"$env"-setup-variables.yaml)
    ONPREM_USERSTORE_IMAGE_SHA=$(echo $ONPREM_USERSTORE_IMAGE_SHA | cut -c12-)
    local ONPREM_USERSTORE_VERSION=$(grep 'SERVER_VERSION' $directyPath/cd-pipelines/onprem-userstore/"$env"-setup-variables.yaml)
    ONPREM_USERSTORE_VERSION=$(echo $ONPREM_USERSTORE_VERSION | cut -c16-)
    local ONPREM_USERSTORE_HELM_VERSION=$(grep 'ref: refs/tags/' $directyPath/cd-pipelines/onprem-userstore/"$env"-deploy-001.yaml)
    ONPREM_USERSTORE_HELM_VERSION=$(echo "${ONPREM_USERSTORE_HELM_VERSION}" | awk '{$1=$1;print}'| cut -c5-)
    echo "$ONPREM_USERSTORE_IMAGE_SHA $ONPREM_USERSTORE_VERSION $ONPREM_USERSTORE_HELM_VERSION"
}

function subscription_service () {
    local env=$1
    local SUBSCRIPTION_SERVICE_IMAGE_SHA=$(grep 'IMAGE_SHA' $directyPath/cd-pipelines/subscription-service/"$env"-setup-variables.yaml)
    SUBSCRIPTION_SERVICE_IMAGE_SHA=$(echo $SUBSCRIPTION_SERVICE_IMAGE_SHA | cut -c12-)
    local SUBSCRIPTION_SERVICE_VERSION=$(grep 'SUBSCRIPTION_SERVICE_VERSION' $directyPath/cd-pipelines/subscription-service/"$env"-setup-variables.yaml)
    SUBSCRIPTION_SERVICE_VERSION=$(echo $SUBSCRIPTION_SERVICE_VERSION | cut -c30-)
    local SUBSCRIPTION_SERVICE_HELM_VERSION=$(grep 'ref: refs/tags/' $directyPath/cd-pipelines/subscription-service/"$env"-deploy-001.yaml)
    SUBSCRIPTION_SERVICE_HELM_VERSION=$(echo "${SUBSCRIPTION_SERVICE_HELM_VERSION}" | awk '{$1=$1;print}'| cut -c5-)
    echo "$SUBSCRIPTION_SERVICE_IMAGE_SHA $SUBSCRIPTION_SERVICE_VERSION $SUBSCRIPTION_SERVICE_HELM_VERSION"
}

function tenant_deletion () {
    local env=$1
    local TENANT_DELETION_IMAGE_SHA=$(grep 'IMAGE_SHA' $directyPath/cd-pipelines/tenant-deletion/"$env"-setup-variables.yaml)
    TENANT_DELETION_IMAGE_SHA=$(echo $TENANT_DELETION_IMAGE_SHA | cut -c12-)
    local TENANT_DELETION_VERSION=$(grep 'TENANT_DELETION_VERSION' $directyPath/cd-pipelines/tenant-deletion/"$env"-setup-variables.yaml)
    TENANT_DELETION_VERSION=$(echo $TENANT_DELETION_VERSION | cut -c25-)
    local TENANT_DELETION_HELM_VERSION=$(grep 'ref: refs/tags/' $directyPath/cd-pipelines/tenant-deletion/"$env"-deploy-001.yaml)
    TENANT_DELETION_HELM_VERSION=$(echo "${TENANT_DELETION_HELM_VERSION}" | awk '{$1=$1;print}'| cut -c5-)
    echo "$TENANT_DELETION_IMAGE_SHA $TENANT_DELETION_VERSION $TENANT_DELETION_HELM_VERSION"
}

function tier_controller () {
    local env=$1
    local TIER_CONTROLLER_IMAGE_SHA=$(grep 'IMAGE_SHA' $directyPath/cd-pipelines/tier-controller/"$env"-setup-variables.yaml)
    TIER_CONTROLLER_IMAGE_SHA=$(echo $TIER_CONTROLLER_IMAGE_SHA | cut -c12-)
    local TIER_CONTROLLER_VERSION=$(grep 'TIER_CONTROLLER_VERSION' $directyPath/cd-pipelines/tier-controller/"$env"-setup-variables.yaml)
    TIER_CONTROLLER_VERSION=$(echo $TIER_CONTROLLER_VERSION | cut -c25-)
    local TIER_CONTROLLER_HELM_VERSION=$(grep 'ref: refs/tags/' $directyPath/cd-pipelines/tier-controller/"$env"-deploy-001.yaml)
    TIER_CONTROLLER_HELM_VERSION=$(echo "${TIER_CONTROLLER_HELM_VERSION}" | awk '{$1=$1;print}'| cut -c5-)
    echo "$TIER_CONTROLLER_IMAGE_SHA $TIER_CONTROLLER_VERSION $TIER_CONTROLLER_HELM_VERSION"
}

function user_mgt () {
    local env=$1
    local USER_MGT_IMAGE_SHA=$(grep 'IMAGE_SHA' $directyPath/cd-pipelines/user-mgt/"$env"-setup-variables.yaml)
    USER_MGT_IMAGE_SHA=$(echo $USER_MGT_IMAGE_SHA | cut -c12-)
    local USER_MGT_VERSION=$(grep 'TENANT_MGT_VERSION' $directyPath/cd-pipelines/user-mgt/"$env"-setup-variables.yaml)
    USER_MGT_VERSION=$(echo $USER_MGT_VERSION | cut -c20-)
    local USER_MGT_HELM_VERSION=$(grep 'ref: refs/tags/' $directyPath/cd-pipelines/user-mgt/"$env"-deploy-001.yaml)
    USER_MGT_HELM_VERSION=$(echo "${USER_MGT_HELM_VERSION}" | awk '{$1=$1;print}'| cut -c5-)
    echo "$USER_MGT_IMAGE_SHA $USER_MGT_VERSION $USER_MGT_HELM_VERSION"
}

function network_policy () {
    local env=$1
    local NETWORK_POLICY_HELM_VERSION=$(grep 'ref: refs/tags/' $directyPath/cd-pipelines/network-policy/"$env"-deploy-001.yaml)
    NETWORK_POLICY_HELM_VERSION=$(echo "${NETWORK_POLICY_HELM_VERSION}" | awk '{$1=$1;print}'| cut -c5-)
    echo "$NETWORK_POLICY_HELM_VERSION"
}

git -C "$directyPath" checkout d853cf4ac3488e5f56375e7b9808e15a8ca81ab5

read QUERY_SERVICE_OLD_IMAGE_SHA QUERY_SERVICE_OLD_VERSION QUERY_SERVICE_OLD_HELM_VERSION <<< "$(query_service $old_env)"
read RESOURCE_MONITOR_OLD_IMAGE_SHA RESOURCE_MONITOR_OLD_VERSION RESOURCE_MONITOR_OLD_HELM_VERSION <<< "$(resource_monitor $old_env)"
read IS_OLD_IMAGE_SHA IS_OLD_VERSION ASGARDEO_OLD_VERSION IS_OLD_HELM_VERSION IS_OLD_TEST_VERSION <<< "$(identity_server $old_env)"
read WEBSITE_OLD_IMAGE_SHA WEBSITE_OLD_VERSION WEBSITE_OLD_HELM_VERSION <<< "$(website $old_env)"
read ACTIVEMQ_OLD_IMAGE_SHA ACTIVEMQ_OLD_VERSION ACTIVEMQ_OLD_HELM_VERSION <<< "$(activemq $old_env)"
read LOG_MGT_OLD_IMAGE_SHA LOG_MGT_OLD_VERSION LOG_MGT_OLD_HELM_VERSION <<< "$(log_mgt $old_env)"
read ONPREM_USERSTORE_OLD_IMAGE_SHA ONPREM_USERSTORE_OLD_VERSION ONPREM_USERSTORE_OLD_HELM_VERSION <<< "$(onprem_userstore $old_env)"
read SUBSCRIPTION_SERVICE_OLD_IMAGE_SHA SUBSCRIPTION_SERVICE_OLD_VERSION SUBSCRIPTION_SERVICE_OLD_HELM_VERSION <<< "$(subscription_service $old_env)"
read TENANT_DELETION_OLD_IMAGE_SHA TENANT_DELETION_OLD_VERSION TENANT_DELETION_OLD_HELM_VERSION <<< "$(tenant_deletion $old_env)"
read TIER_CONTROLLER_OLD_IMAGE_SHA TIER_CONTROLLER_OLD_VERSION TIER_CONTROLLER_OLD_HELM_VERSION <<< "$(tier_controller $old_env)"
read USER_MGT_OLD_IMAGE_SHA USER_MGT_OLD_VERSION USER_MGT_OLD_HELM_VERSION <<< "$(user_mgt $old_env)"
read NETWORK_POLICY_OLD_HELM_VERSION <<< "$(network_policy $old_env)"


#Get existing env values

git -C "$directyPath" checkout "$new_branch"

read QUERY_SERVICE_NEW_IMAGE_SHA QUERY_SERVICE_NEW_VERSION QUERY_SERVICE_NEW_HELM_VERSION <<< "$(query_service $new_env)"
read RESOURCE_MONITOR_NEW_IMAGE_SHA RESOURCE_MONITOR_NEW_VERSION RESOURCE_MONITOR_NEW_HELM_VERSION <<< "$(resource_monitor $new_env)"
read IS_NEW_IMAGE_SHA IS_NEW_VERSION ASGARDEO_NEW_VERSION IS_NEW_HELM_VERSION IS_NEW_TEST_VERSION <<< "$(identity_server $new_env)"
read WEBSITE_NEW_IMAGE_SHA WEBSITE_NEW_VERSION WEBSITE_NEW_HELM_VERSION <<< "$(website $new_env)"
read ACTIVEMQ_NEW_IMAGE_SHA ACTIVEMQ_NEW_VERSION ACTIVEMQ_NEW_HELM_VERSION <<< "$(activemq $new_env)"
read LOG_MGT_NEW_IMAGE_SHA LOG_MGT_NEW_VERSION LOG_MGT_NEW_HELM_VERSION <<< "$(log_mgt $new_env)"
read ONPREM_USERSTORE_NEW_IMAGE_SHA ONPREM_USERSTORE_NEW_VERSION ONPREM_USERSTORE_NEW_HELM_VERSION <<< "$(onprem_userstore $new_env)"
read SUBSCRIPTION_SERVICE_NEW_IMAGE_SHA SUBSCRIPTION_SERVICE_NEW_VERSION SUBSCRIPTION_SERVICE_NEW_HELM_VERSION <<< "$(subscription_service $new_env)"
read TENANT_DELETION_NEW_IMAGE_SHA TENANT_DELETION_NEW_VERSION TENANT_DELETION_NEW_HELM_VERSION <<< "$(tenant_deletion $new_env)"
read TIER_CONTROLLER_NEW_IMAGE_SHA TIER_CONTROLLER_NEW_VERSION TIER_CONTROLLER_NEW_HELM_VERSION <<< "$(tier_controller $new_env)"
read USER_MGT_NEW_IMAGE_SHA USER_MGT_NEW_VERSION USER_MGT_NEW_HELM_VERSION <<< "$(user_mgt $new_env)"
read NETWORK_POLICY_NEW_HELM_VERSION <<< "$(network_policy $new_env)"

#Update the new environment with the old environment values
sed -i '' -e 's|'"${QUERY_SERVICE_NEW_IMAGE_SHA}"'|'"${QUERY_SERVICE_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/query-service/dr-setup-variables.yaml
sed -i '' -e 's|'"${QUERY_SERVICE_NEW_IMAGE_SHA}"'|'"${QUERY_SERVICE_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/query-service/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${QUERY_SERVICE_NEW_VERSION}"'|'"${QUERY_SERVICE_OLD_VERSION}"'|' $directyPath/cd-pipelines/query-service/dr-setup-variables.yaml
sed -i '' -e 's|'"${QUERY_SERVICE_NEW_VERSION}"'|'"${QUERY_SERVICE_OLD_VERSION}"'|' $directyPath/cd-pipelines/query-service/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${QUERY_SERVICE_NEW_HELM_VERSION}"'|'"${QUERY_SERVICE_OLD_HELM_VERSION}"'|' $directyPath/cd-pipelines/query-service/"$new_env"-deploy-001.yaml

sed -i '' -e 's|'"${RESOURCE_MONITOR_NEW_IMAGE_SHA}"'|'"${RESOURCE_MONITOR_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/resource-monitor/dr-setup-variables.yaml
sed -i '' -e 's|'"${RESOURCE_MONITOR_NEW_IMAGE_SHA}"'|'"${RESOURCE_MONITOR_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/resource-monitor/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${RESOURCE_MONITOR_NEW_VERSION}"'|'"${RESOURCE_MONITOR_OLD_VERSION}"'|' $directyPath/cd-pipelines/resource-monitor/dr-setup-variables.yaml
sed -i '' -e 's|'"${RESOURCE_MONITOR_NEW_VERSION}"'|'"${RESOURCE_MONITOR_OLD_VERSION}"'|' $directyPath/cd-pipelines/resource-monitor/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${RESOURCE_MONITOR_NEW_HELM_VERSION}"'|'"${RESOURCE_MONITOR_OLD_HELM_VERSION}"'|' $directyPath/cd-pipelines/resource-monitor/"$new_env"-deploy-001.yaml

sed -i '' -e 's|'"${IS_NEW_IMAGE_SHA}"'|'"${IS_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/identity-server/dr-setup-variables.yaml
sed -i '' -e 's|'"${IS_NEW_IMAGE_SHA}"'|'"${IS_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/identity-server/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${IS_NEW_VERSION}"'|'"${IS_OLD_VERSION}"'|' $directyPath/cd-pipelines/identity-server/dr-setup-variables.yaml
sed -i '' -e 's|'"${IS_NEW_VERSION}"'|'"${IS_OLD_VERSION}"'|' $directyPath/cd-pipelines/identity-server/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${ASGARDEO_NEW_VERSION}"'|'"${ASGARDEO_OLD_VERSION}"'|' $directyPath/cd-pipelines/identity-server/dr-setup-variables.yaml
sed -i '' -e 's|'"${ASGARDEO_NEW_VERSION}"'|'"${ASGARDEO_OLD_VERSION}"'|' $directyPath/cd-pipelines/identity-server/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${IS_NEW_HELM_VERSION}"'|'"${IS_OLD_HELM_VERSION}"'|' $directyPath/cd-pipelines/identity-server/dr-setup-variables.yaml
sed -i '' -e 's|'"${IS_NEW_HELM_VERSION}"'|'"${IS_OLD_HELM_VERSION}"'|' $directyPath/cd-pipelines/identity-server/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${IS_NEW_TEST_VERSION}"'|'"${IS_OLD_TEST_VERSION}"'|' $directyPath/cd-pipelines/identity-server/"$new_env"-test-variables.yaml

sed -i '' -e 's|'"${WEBSITE_NEW_IMAGE_SHA}"'|'"${WEBSITE_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/cloud-website/dr-setup-variables.yaml
sed -i '' -e 's|'"${WEBSITE_NEW_IMAGE_SHA}"'|'"${WEBSITE_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/cloud-website/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${WEBSITE_NEW_VERSION}"'|'"${WEBSITE_OLD_VERSION}"'|' $directyPath/cd-pipelines/cloud-website/dr-setup-variables.yaml
sed -i '' -e 's|'"${WEBSITE_NEW_VERSION}"'|'"${WEBSITE_OLD_VERSION}"'|' $directyPath/cd-pipelines/cloud-website/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${WEBSITE_NEW_HELM_VERSION}"'|'"${WEBSITE_OLD_HELM_VERSION}"'|' $directyPath/cd-pipelines/cloud-website/dr-setup-variables.yaml
sed -i '' -e 's|'"${WEBSITE_NEW_HELM_VERSION}"'|'"${WEBSITE_OLD_HELM_VERSION}"'|' $directyPath/cd-pipelines/cloud-website/"$new_env"-setup-variables.yaml

sed -i '' -e 's|'"${ACTIVEMQ_NEW_IMAGE_SHA}"'|'"${ACTIVEMQ_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/activemq/dr-setup-variables.yaml
sed -i '' -e 's|'"${ACTIVEMQ_NEW_IMAGE_SHA}"'|'"${ACTIVEMQ_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/activemq/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${ACTIVEMQ_NEW_VERSION}"'|'"${ACTIVEMQ_OLD_VERSION}"'|' $directyPath/cd-pipelines/activemq/dr-setup-variables.yaml
sed -i '' -e 's|'"${ACTIVEMQ_NEW_VERSION}"'|'"${ACTIVEMQ_OLD_VERSION}"'|' $directyPath/cd-pipelines/activemq/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${ACTIVEMQ_NEW_HELM_VERSION}"'|'"${ACTIVEMQ_OLD_HELM_VERSION}"'|' $directyPath/cd-pipelines/activemq/"$new_env"-deploy-001.yaml

sed -i '' -e 's|'"${LOG_MGT_NEW_IMAGE_SHA}"'|'"${LOG_MGT_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/log-mgt/dr-setup-variables.yaml
sed -i '' -e 's|'"${LOG_MGT_NEW_IMAGE_SHA}"'|'"${LOG_MGT_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/log-mgt/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${LOG_MGT_NEW_VERSION}"'|'"${LOG_MGT_OLD_VERSION}"'|' $directyPath/cd-pipelines/log-mgt/dr-setup-variables.yaml
sed -i '' -e 's|'"${LOG_MGT_NEW_VERSION}"'|'"${LOG_MGT_OLD_VERSION}"'|' $directyPath/cd-pipelines/log-mgt/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${LOG_MGT_NEW_HELM_VERSION}"'|'"${LOG_MGT_OLD_HELM_VERSION}"'|' $directyPath/cd-pipelines/log-mgt/"$new_env"-deploy-001.yaml

sed -i '' -e 's|'"${ONPREM_USERSTORE_NEW_IMAGE_SHA}"'|'"${ONPREM_USERSTORE_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/onprem-userstore/dr-setup-variables.yaml
sed -i '' -e 's|'"${ONPREM_USERSTORE_NEW_IMAGE_SHA}"'|'"${ONPREM_USERSTORE_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/onprem-userstore/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${ONPREM_USERSTORE_NEW_VERSION}"'|'"${ONPREM_USERSTORE_OLD_VERSION}"'|' $directyPath/cd-pipelines/onprem-userstore/dr-setup-variables.yaml
sed -i '' -e 's|'"${ONPREM_USERSTORE_NEW_VERSION}"'|'"${ONPREM_USERSTORE_OLD_VERSION}"'|' $directyPath/cd-pipelines/onprem-userstore/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${ONPREM_USERSTORE_NEW_HELM_VERSION}"'|'"${ONPREM_USERSTORE_OLD_HELM_VERSION}"'|' $directyPath/cd-pipelines/onprem-userstore/"$new_env"-deploy-001.yaml

sed -i '' -e 's|'"${SUBSCRIPTION_SERVICE_NEW_IMAGE_SHA}"'|'"${SUBSCRIPTION_SERVICE_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/subscription-service/dr-setup-variables.yaml
sed -i '' -e 's|'"${SUBSCRIPTION_SERVICE_NEW_IMAGE_SHA}"'|'"${SUBSCRIPTION_SERVICE_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/subscription-service/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${SUBSCRIPTION_SERVICE_NEW_VERSION}"'|'"${SUBSCRIPTION_SERVICE_OLD_VERSION}"'|' $directyPath/cd-pipelines/subscription-service/dr-setup-variables.yaml
sed -i '' -e 's|'"${SUBSCRIPTION_SERVICE_NEW_VERSION}"'|'"${SUBSCRIPTION_SERVICE_OLD_VERSION}"'|' $directyPath/cd-pipelines/subscription-service/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${SUBSCRIPTION_SERVICE_NEW_HELM_VERSION}"'|'"${SUBSCRIPTION_SERVICE_OLD_HELM_VERSION}"'|' $directyPath/cd-pipelines/subscription-service/"$new_env"-deploy-001.yaml

sed -i '' -e 's|'"${TENANT_DELETION_NEW_IMAGE_SHA}"'|'"${TENANT_DELETION_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/tenant-deletion/dr-setup-variables.yaml
sed -i '' -e 's|'"${TENANT_DELETION_NEW_IMAGE_SHA}"'|'"${TENANT_DELETION_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/tenant-deletion/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${TENANT_DELETION_NEW_VERSION}"'|'"${TENANT_DELETION_OLD_VERSION}"'|' $directyPath/cd-pipelines/tenant-deletion/dr-setup-variables.yaml
sed -i '' -e 's|'"${TENANT_DELETION_NEW_VERSION}"'|'"${TENANT_DELETION_OLD_VERSION}"'|' $directyPath/cd-pipelines/tenant-deletion/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${TENANT_DELETION_NEW_HELM_VERSION}"'|'"${TENANT_DELETION_OLD_HELM_VERSION}"'|' $directyPath/cd-pipelines/tenant-deletion/"$new_env"-deploy-001.yaml

sed -i '' -e 's|'"${TIER_CONTROLLER_NEW_IMAGE_SHA}"'|'"${TIER_CONTROLLER_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/tier-controller/dr-setup-variables.yaml
sed -i '' -e 's|'"${TIER_CONTROLLER_NEW_IMAGE_SHA}"'|'"${TIER_CONTROLLER_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/tier-controller/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${TIER_CONTROLLER_NEW_VERSION}"'|'"${TIER_CONTROLLER_OLD_VERSION}"'|' $directyPath/cd-pipelines/tier-controller/dr-setup-variables.yaml
sed -i '' -e 's|'"${TIER_CONTROLLER_NEW_VERSION}"'|'"${TIER_CONTROLLER_OLD_VERSION}"'|' $directyPath/cd-pipelines/tier-controller/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${TIER_CONTROLLER_NEW_HELM_VERSION}"'|'"${TIER_CONTROLLER_OLD_HELM_VERSION}"'|' $directyPath/cd-pipelines/tier-controller/"$new_env"-deploy-001.yaml

sed -i '' -e 's|'"${USER_MGT_NEW_IMAGE_SHA}"'|'"${USER_MGT_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/user-mgt/dr-setup-variables.yaml
sed -i '' -e 's|'"${USER_MGT_NEW_IMAGE_SHA}"'|'"${USER_MGT_OLD_IMAGE_SHA}"'|' $directyPath/cd-pipelines/user-mgt/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${USER_MGT_NEW_VERSION}"'|'"${USER_MGT_OLD_VERSION}"'|' $directyPath/cd-pipelines/user-mgt/dr-setup-variables.yaml
sed -i '' -e 's|'"${USER_MGT_NEW_VERSION}"'|'"${USER_MGT_OLD_VERSION}"'|' $directyPath/cd-pipelines/user-mgt/"$new_env"-setup-variables.yaml
sed -i '' -e 's|'"${USER_MGT_NEW_HELM_VERSION}"'|'"${USER_MGT_OLD_HELM_VERSION}"'|' $directyPath/cd-pipelines/user-mgt/"$new_env"-deploy-001.yaml

sed -i '' -e 's|'"${NETWORK_POLICY_NEW_HELM_VERSION}"'|'"${NETWORK_POLICY_OLD_HELM_VERSION}"'|' $directyPath/cd-pipelines/network-policy/"$new_env"-deploy-001.yaml
