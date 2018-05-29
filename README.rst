====================================
Health - A CI data analysis pipeline
====================================

Building and Deploy
-------------------

The Docker images used by Health can be built locally through make or using
skaffold_.

.. code:: shell

  # Build locally using make
  make

Skaffold also pushes the image to the specified registry and deployes the helm
chart to either minikube or a remote cluster.

.. code:: shell

  # Build locally and push to registry using skaffold
  export IMAGE_REG=registry.ng.bluemix.net/ci-pipeline
  export PR_NUMBER=<pull request number>
  skaffold run

Skaffold can be used in development mode, in which case it will monitor the
workspace of all Docker images for changes and automatically re-trigger a build
when something changes and re-deploy.

.. code:: shell

  # Using skaffold
  export IMAGE_REG=registry.ng.bluemix.net/ci-pipeline
  skaffold dev

Note: the skaffold configuration uses a skaffold feature which is not merged
yet: https://github.com/GoogleContainerTools/skaffold/pull/602.

.. _skaffold: https://github.com/GoogleContainerTools/skaffold
