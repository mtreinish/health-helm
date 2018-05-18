HEALTH_API_IMAGE=api
HEALTH_DB_IMAGE=database
HEALTH_FRONTEND_IMAGE=frontend
HEALTH_API_WAIT_IMAGE=api-wait
IMAGE_REG=registry.ng.bluemix.net/ci-pipeline/
BUILDER=bx cr build -t

all: api db frontend api-wait

api:
	$(BUILDER) $(IMAGE_REG)$(HEALTH_API_IMAGE):3 images/$(HEALTH_API_IMAGE)

db:
	$(BUILDER) $(IMAGE_REG)$(HEALTH_DB_IMAGE):2 images/$(HEALTH_DB_IMAGE)

frontend:
	$(BUILDER) $(IMAGE_REG)$(HEALTH_FRONTEND_IMAGE):1 images/$(HEALTH_FRONTEND_IMAGE)

api-wait:
	$(BUILDER) $(IMAGE_REG)$(HEALTH_API_WAIT_IMAGE):1 images/$(HEALTH_API_WAIT_IMAGE)
