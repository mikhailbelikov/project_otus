#ENV
USER_NAME=mikhailbelikov
CRAWLER_UI_VERSION=1.0
CRAWLER_ENGINE_VERSION=1.0

# DOCKER BUILDS
# build:: build-crawler-engine build-crawler-ui 
build:: build-crawler-ui 

build-crawler-engine::
	cd ../src/search_engine_crawler/ && \
	docker build --no-cache -t $(USER_NAME)/crawler-engine:$(CRAWLER_ENGINE_VERSION) .
build-crawler-ui::
	cd ../src/search_engine_ui/ && \
	docker build --no-cache -t $(USER_NAME)/crawler-ui:$(CRAWLER_UI_VERSION) .

# DOCKER PUSH
push:: push-crawler-engine push-crawler-ui

push-crawler-engine::
	docker push $(USER_NAME)/crawler-engine:$(CRAWLER_ENGINE_VERSION)
push-crawler-ui::
	docker push $(USER_NAME)/crawler-ui:$(CRAWLER_UI_VERSION)
