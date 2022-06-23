#!/bin/sh

# Required input parameters
# - KUBECONFIG : Not used directly but required by oc
# - STORAGE_CLASS_NAME
# - DOCKER_REGISTRY_PASS
# - DOCKER_USER_EMAIL
# - STORAGE_CLASS_CONTENT
# - INSTALLER_SENSITIVE_DATA
# - INSTALLER_JOB_CONTENT
# - SCC_ZENUID_CONTENT

# Software requirements:
# - oc
# - kubectl

# Optional input parameters with default values:
DEBUG=${DEBUG:-false}
DOCKER_USERNAME=${DOCKER_USERNAME:-cp}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io}  # adjust this if needed

JOB_NAME="cloud-installer"
WAITING_TIME=5

echo "Waiting for Ingress domain to be created"
while [[ -z $(kubectl get route -n openshift-ingress router-default -o jsonpath='{.spec.host}' 2>/dev/null) ]]; do
  sleep $WAITING_TIME
done

# echo "Creating namespace ${NAMESPACE}"
echo "creating namespace ${NAMESPACE}"
kubectl create namespace ${NAMESPACE}

evtCount=0
evtTimeout=15 #10 mins
SLEEP_TIME="60"
while true; do
  if [ "$evtCount" -eq "$evtTimeout" ]; then
    echo "Namespace is available"
    exit 1
  fi
  # Check to make sure it exists:
  # Check to see if the namespace exist yet.
  if [ "`kubectl get namespaces | grep cp4s`" != "" ]; then
    if [ "`kubectl get namespaces --ignore-not-found=true`" != "" ]; then
      break
    fi
  fi
  echo "Waiting for cp4s namespace to become available, sleeping ${SLEEP_TIME} seconds"
  sleep $SLEEP_TIME
  evtCount=$(( evtCount+1 ))
done

# While Orginaly not needed I have added this line to create teh appropriate namespace for OpenShift Serverless operator installed
echo "creating namespace openshift-serverless for OpenShift Serverless operator"
kubectl create namespace openshift-serverless

echo "Deploying Catalog Option ${OPERATOR_CATALOG}"
echo "${OPERATOR_CATALOG}" | kubectl apply -f -

echo "Deploying Catalog Option ${COMMON_SERVICES_CATALOG}"
echo "${COMMON_SERVICES_CATALOG}" | kubectl apply -f -

create_secret() {
  secret_name=$1
  namespace=$2
  link=$3

  echo "Creating secret ${secret_name} on ${namespace} from entitlement key"
  kubectl create secret docker-registry ${secret_name} \
    --docker-server=${DOCKER_REGISTRY} \
    --docker-username=${DOCKER_USERNAME} \
    --docker-password=${DOCKER_REGISTRY_PASS} \
    --docker-email=${DOCKER_USER_EMAIL} \
    --namespace=${NAMESPACE}

  # [[ "${link}" != "no-link" ]] && kubectl secrets -n ${namespace} link cpdinstall icp4d-anyuid-docker-pull --for=pull
}

create_secret ibm-entitlement-key ${NAMESPACE}

create_secret ibm-isc-pull-secret ${NAMESPACE}

#echo "Deploying Operator Group ${KNATIVE_OPERATOR_GROUP}"
#echo "${KNATIVE_OPERATOR_GROUP}" | kubectl apply -f -

sleep 10

# DEPLOYING OPENSHIFT SEVERLESS
echo "Deploying Operator  ${KNATIVE_SUBSCRIPTION}"
echo "${KNATIVE_SUBSCRIPTION}" | kubectl apply -f -
evtCount=0
evtTimeout=15 #15 mins
SLEEP_TIME="60"
while true; do
  if [ "$evtCount" -eq "$evtTimeout" ]; then
    echo "Kind: OpenShift Serverless did not create knativeservings resource. Please check the Installation: cp4s"
    exit 1
  fi
  # Check to make sure it exists:
  # Wait for knative resource creation and then check for the instance creation.
  if [ "`kubectl api-resources | grep knativeservings`" != "" ]; then
    break
  fi
  echo "Waiting for knativeservings resource, sleeping ${SLEEP_TIME} seconds"
  sleep $SLEEP_TIME
  evtCount=$(( evtCount+1 ))
done

#DEPLOYING KNATIVE
echo "Deploying Knative ${KNATIVE}"
echo "${KNATIVE}" | kubectl apply -f -
evtCount=0
evtTimeout=15 #15 mins
SLEEP_TIME="60"
while true; do
  if [ "$evtCount" -eq "$evtTimeout" ]; then
    echo "Kind: knativeservings name: knative resource. Please check the Installation: cp4s"
    exit 1
  fi
  # Check to make sure it exists:
  # Wait for knative resource creation and then check for the instance creation.
  if [ "`kubectl get knativeServing -n knative-serving  | grep knative-serving`" != "" ]; then
    if [ "`kubectl get knativeservings -n knative-serving --ignore-not-found=true`" != "" ]; then
      echo "Knative-serving created"
      break
    fi
  fi
  echo "Waiting for knativeservings resource, sleeping ${SLEEP_TIME} seconds"
  sleep $SLEEP_TIME
  evtCount=$(( evtCount+1 ))
done

echo "Deploying Operator Group ${OPERATOR_GROUP}"
echo "${OPERATOR_GROUP}" | kubectl apply -f -

# DEPLOYING CP4S OPERATOR
echo "Deploying Subscription ${SUBSCRIPTION}"
echo "${SUBSCRIPTION}" | kubectl apply -f -
evtCount=0
evtTimeout=20 #15 mins
SLEEP_TIME="60"
while true; do
  if [ "$evtCount" -eq "$evtTimeout" ]; then
    echo "Kind: subscription name: cp4s. Please check the Installation: cp4s"
    exit 1
  fi
  # Check to make sure it exists:
  # Wait for knative resource creation and then check for the instance creation.
  if [ "`kubectl api-resources -n cp4s | grep cp4sthreatmanagements`" != "" ]; then
    echo "cp4s operator deployed"
    break
  fi
  echo "Waiting for cp4sthreatmanagements api-resource, sleeping ${SLEEP_TIME} seconds"
  sleep $SLEEP_TIME
  evtCount=$(( evtCount+1 ))
done

# DEPLOYING THREAT MANAGEMENT INSTANCE
echo "Deploying Subscription ${CP4S_THREAT_MANAGEMENT}"
echo "${CP4S_THREAT_MANAGEMENT}" | kubectl apply -f -
evtCount=0
evtTimeout=35 #15 mins
SLEEP_TIME="60"
while true; do
  if [ "$evtCount" -eq "$evtTimeout" ]; then
    echo "Kind: threatmanagement name: threatmgmt did not complete."
    STATUS=`kubectl get cp4sthreatmanagement/threatmgmt -n cp4s --output=json | jq -c -r '.status.conditions[0].type'`
    MESSAGE=`kubectl get cp4sthreatmanagement/threatmgmt -n cp4s --output=json | jq -c -r '.status.conditions[0].message'`
    echo "Current status: $STATUS"
    echo "Message: $MESSAGE"
    exit 1
  fi
  # Check to make sure it exists:
  # Wait for knative resource creation and then check for the instance creation.
  if [ "`kubectl get cp4sthreatmanagements -n cp4s | grep threatmgmt`" != "" ]; then
    if [ "`kubectl get cp4sthreatmanagements -n cp4s --ignore-not-found=true`" != "" ]; then
      echo "threatmanagement created"
      STATUS=`kubectl get cp4sthreatmanagement/threatmgmt -n cp4s --output=json | jq -c -r '.status.conditions[0].type'`
      MESSAGE=`kubectl get cp4sthreatmanagement/threatmgmt -n cp4s --output=json | jq -c -r '.status.conditions[0].message'`
      echo "Current status: $STATUS"
      echo "Message: $MESSAGE"
      if [ "$STATUS" == "Success" ]; then
          break
      fi
    fi
  fi
  echo "Waiting for threatmgmt resource, sleeping ${SLEEP_TIME} seconds"
  sleep $SLEEP_TIME
  evtCount=$(( evtCount+1 ))
done

#CHECK ISC ROUTE//CP4S CONSOLE ROUTE IS CREATED
evtCount=0
evtTimeout=50 #15 mins
SLEEP_TIME="60"
while true; do
  if [ "$evtCount" -eq "$evtTimeout" ]; then
    echo "Kind: route name: isc-route-default. Please check the Installation: threatmgmt"
    exit 1
  fi
  # Check to make sure it exists:
  # Wait for knative resource creation and then check for the instance creation.
  if [ "`kubectl get routes -n cp4s | grep isc-route-default`" != "" ]; then
    echo "route available"
    break
  fi
  echo "Waiting for threatmgmt to create isc-route-default, sleeping ${SLEEP_TIME} seconds"
  sleep $SLEEP_TIME
  evtCount=$(( evtCount+1 ))
done

# TODO  while kubectl -n ${NAMESPACE} get cpdservice ${SERVICE}-cpdservice --output=json | jq -c -r '.status'
