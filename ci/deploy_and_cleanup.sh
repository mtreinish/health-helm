#!/bin/bash

SLEEP_INTERVAL=10
MAX_ATTEMPTS=10
status="not-queried"
timedout="yes"

# Define the BRANCH_NAME that we use for the helm release name
RELEASE_ID=${TRAVIS_COMMIT:0:7}
# RELEASE_ID is used to build the release number
export RELEASE_NAME=health-dev-$RELEASE_ID
export RELEASE_ID

# Target the CI cluster
echo "Release $RELEASE_NAME: build and deploy against the ci-dev cluster."
eval $(bx cs cluster-config --export ci-dev)
# Init helm just in case
helm init
# Build & deploy
~/build/skaffold run || exit $?

# Wait to helm deployment to be complete
for ((i=1;i<=MAX_ATTEMPTS;i++)); do
  all_done="yes"
  for status in $(kubectl get pods --selector=$RELEASE_NAME= -o jsonpath='{.items[*].status.phase}'); do
    if [[ ! "$status" =~ "Succeeded Failed Unknown" ]]; then
      all_done="no"
      break
    fi
  done
  if [[ "$all_done" == "yes "]]; then
    timedout="no"
    break
  fi
  sleep $SLEEP_INTERVAL
done

exit_rc=0
for status in $(kubectl get pods --selector=release=development -o jsonpath='{.items[*].status.phase}'); do
  if [[ "$status" != "Succeeded" ]]; then
    exit_rc=$(( exit_rc + 1 ))
    if [[ "$timeout" == "yes" ]]; then
      echo "Timed out waiting for job to complete. Last status: $status." >&2
    else
      echo "Job failed with status: $status" >&2
    fi
  fi
done
if [[ $exit_rc == 0 ]]; then
    echo "Job completed successfully."
    helm status $RELEASE_NAME
    if [[ ! "$TRAVIS_PULL_REQUEST" == "false" ]]; then
      # The result is avaible for review
      echo "Health running with this PR is available at:"
      echo "API: http://${CLUSTER_DOMAIN}/health-dev-${PR_NUMBER}-api"
      echo "Dashboard: http://${CLUSTER_DOMAIN}/health-dev-${PR_NUMBER}-health"
      echo
      echo "Remember to delete release when done"
    fi
fi

# We only keep the cluster around for pull requests
if [[ "$TRAVIS_PULL_REQUEST" == "false" || $exit_rc != 0 ]]; then
  ~/build/skaffold delete
fi

exit $exit_rc
