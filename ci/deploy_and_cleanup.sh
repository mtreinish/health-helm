#!/bin/bash

if [[ ! "$TRAVIS_PULL_REQUEST" == "false" ]]; then
  # Target the CI cluster
  echo "Pull request $TRAVIS_PULL_REQUEST: build and deploy against the ci-dev cluster."
  eval $(bx cs cluster-config --export ci-dev)
  # Init helm just in case
  helm init
  # PR_NUMBER is used to build the release number
  export PR_NUMBER=$TRAVIS_PULL_REQUEST
  # Build & deploy
  ~/build/skaffold run
  # The result is avaible for review
  echo "Health running with this PR is available at:"
  echo "API: http://${CLUSTER_DOMAIN}/health-dev-${PR_NUMBER}-api"
  echo "Dashboard: http://${CLUSTER_DOMAIN}/health-dev-${PR_NUMBER}-health"
fi
