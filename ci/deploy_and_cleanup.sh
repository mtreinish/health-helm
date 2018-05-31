#!/bin/bash

CLUSTER_DOMAIN=ci-dev-106092.us-south.containers.appdomain.cloud

SLEEP_INTERVAL=20
MAX_ATTEMPTS=20
status="not-queried"
timedout="yes"

# Define the RELEASE_ID that we use for the helm release name
RELEASE_ID=${TRAVIS_COMMIT:0:7}
# Define a DNS safe EVENT_TYPE for the release name
if [[ "$TRAVIS_EVENT_TYPE" == "pull_request" ]]; then
  EVENT_TYPE="pr"
else
  EVENT_TYPE="${TRAVIS_EVENT_TYPE:-api}"
fi
# RELEASE_ID is used to build the release number
export RELEASE_NAME=health-dev-$EVENT_TYPE-$RELEASE_ID
export RELEASE_ID EVENT_TYPE

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
  for service in api health; do
    status_header="$(curl -s -I http://$CLUSTER_DOMAIN/$RELEASE_NAME-$service/ | egrep '^HTTP\/1\.1.*$')"
    status="$(echo $status_header| egrep -c '^HTTP\/1\.1 [23][0-9][0-9] OK.*$')"
    echo "HTTP Status for ${service}: ${status_header%?} [code: ${status}]"
    if [[ ! "$status" == "1" ]]; then
      all_done="no"
      break
    fi
  done
  if [[ "$all_done" == "yes" ]]; then
    timedout="no"
    break
  fi
  sleep $SLEEP_INTERVAL
done

if [[ "$timedout" == "yes" ]]; then
  echo "Timed out waiting for job to complete." >&2
  exit_rc=1
else
  echo "Job completed successfully."
  exit_rc=0
  if [[ "$TRAVIS_EVENT_TYPE" == "pull_request" ]]; then
    # The result is avaible for review
    echo "Health running with this PR is available at:"
    echo "API: http://${CLUSTER_DOMAIN}/${RELEASE_NAME}-api"
    echo "Dashboard: http://${CLUSTER_DOMAIN}/${RELEASE_NAME}-health"
    echo
    echo "Remember to delete release when done: EVENT_TYPE=$EVENT_TYPE RELEASE_ID=$RELEASE_ID skaffold delete"
  fi
fi
helm status $RELEASE_NAME

# We only keep the cluster around for pull requests
if [[ ! "$TRAVIS_EVENT_TYPE" == "pull_request" || $exit_rc != 0 ]]; then
  ~/build/skaffold delete
fi

exit $exit_rc
