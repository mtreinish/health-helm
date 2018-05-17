HEALTH_API_IMAGE=api
HEALTH_DB_IMAGE=database
HEALTH_FRONTEND_IMAGE=frontend
IMAGE_REG=registry.ng.bluemix.net/ci-pipeline/
BUILDER=bx cr build -t

all: api db frontend

api:
	$(BUILDER) $(IMAGE_REG)$(HEALTH_API_IMAGE):1 images/$(HEALTH_API_IMAGE)

db:
	$(BUILDER) $(IMAGE_REG)$(HEALTH_DB_IMAGE):1 images/$(HEALTH_DB_IMAGE)

frontend:
	$(BUILDER) $(IMAGE_REG)$(HEALTH_FRONTEND_IMAGE):1 images/$(HEALTH_FRONTEND_IMAGE)
