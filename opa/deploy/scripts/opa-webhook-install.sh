#!/usr/bin/env bash

#set -x

################################################################################
#### Variables, Arrays, and Hashes #############################################
################################################################################

RUN_TYPE="${1}"
DEPLOY_DIR="../../deploy"
POLICY_DIR="../../policy"
WEBHOOK_NAMESPACE="opa"
TEST_NAMESPACE="test2"

################################################################################
#### Functions #################################################################
################################################################################

# **********************************************
# Check the argument being passed to script
# **********************************************
help_message() {

  echo "You need to specify an argument (\"install\" or \"delete\")"

}

# **********************************************
# Check the argument being passed to script
# **********************************************
check_arguments() {

  if [ "${RUN_TYPE}" == "" ]; then

    help_message
    exit 1

  fi

}

# **********************************************
# Run install routine
# **********************************************
opa_install() {

  # Create Namespace for OPA
  kubectl create ns ${WEBHOOK_NAMESPACE}

  # Create Namespace for testing
  kubectl create ns ${TEST_NAMESPACE}
  kubectl label ns ${TEST_NAMESPACE} k8s.t-mobile.com/opa=enabled --overwrite

  # Setup SSL stuff
  ${DEPLOY_DIR}/scripts/webhook-ssl-cert-gen.sh \
    --service opa-webhook-svc \
    --secret opa-webhook-certs \
    --namespace ${WEBHOOK_NAMESPACE}

  cat ${DEPLOY_DIR}/opa-webhook-vwc.yaml | \
    ${DEPLOY_DIR}/scripts/webhook-patch-ca-bundle.sh > \
    ${DEPLOY_DIR}/opa-webhook-vwc-patched.yaml

  # Deploy Webhook Workload
  kubectl apply -f ${DEPLOY_DIR}/opa-webhook-deploy.yaml
  kubectl apply -f ${DEPLOY_DIR}/opa-webhook-svc.yaml
  kubectl apply -f ${DEPLOY_DIR}/opa-webhook-vwc-patched.yaml

  echo "Waiting for container pull"
  sleep 10

  # Create ConfigMaps for OPA Policies
  kubectl -n ${WEBHOOK_NAMESPACE} create cm policy-liveness-probe-check --from-file=${POLICY_DIR}/policy-liveness-probe-check.rego
  kubectl -n ${WEBHOOK_NAMESPACE} label cm policy-liveness-probe-check app=opa --overwrite
  kubectl -n ${WEBHOOK_NAMESPACE} create cm policy-readiness-probe-check --from-file=${POLICY_DIR}/policy-readiness-probe-check.rego
  kubectl -n ${WEBHOOK_NAMESPACE} label cm policy-readiness-probe-check app=opa --overwrite
  kubectl -n ${WEBHOOK_NAMESPACE} create cm policy-privileged-pod-check --from-file=${POLICY_DIR}/policy-privileged-pod-check.rego
  kubectl -n ${WEBHOOK_NAMESPACE} label cm policy-privileged-pod-check app=opa --overwrite
  kubectl -n ${WEBHOOK_NAMESPACE} create cm policy-ingress-whitelist-check --from-file=${POLICY_DIR}/policy-ingress-whitelist-check.rego
  kubectl -n ${WEBHOOK_NAMESPACE} label cm policy-ingress-whitelist-check app=opa --overwrite

  echo "Waiting for configMaps to register with OPA"
  sleep 10

  kubectl get cm -n ${WEBHOOK_NAMESPACE} -l app=opa -o jsonpath="{range .items[*]}{.metadata.name}{\"\t\t\"}{.metadata.annotations.openpolicyagent\.org/policy-status}{\"\n\"}"

}

# **********************************************
# Run delete routine
# **********************************************
opa_delete() {

  kubectl delete ns ${WEBHOOK_NAMESPACE}
  kubectl delete ns ${TEST_NAMESPACE}
  kubectl delete -f ${DEPLOY_DIR}/opa-webhook-deploy.yaml
  kubectl delete -f ${DEPLOY_DIR}/opa-webhook-vwc-patched.yaml

}

################################################################################
#### Main ######################################################################
################################################################################

check_arguments

case ${RUN_TYPE} in 

  install)
      opa_install
      ;;
  delete)
      opa_delete
      ;;
       *)
      help_message
      ;; 
esac