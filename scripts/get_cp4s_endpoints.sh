#!/bin/bash

eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig) NAMESPACE=\(.namespace)"')"

# Obtains the credentials and endpoints for the installed CP4I Dashboard
results() {
  console_url_address=$1

  # NOTE: The credentials are static and defined by the installer, in the future this
  # may not be the case.
  # username="admin"

  jq -n \
    --arg endpoint "$console_url_address"
  exit 0
}

route=$(kubectl get routes/isc-route-default -n cp4s --ignore-not-found=true -o jsonpath='{.spec.host}')

results "${route}"