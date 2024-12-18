ifndef CMD
	CMD=cd /opt/test && /opt/test/test.sh
endif

IMG_TAG=auriema/jenkins:test
V_TEST=-v "$(PWD)/test:/opt/test"
V_STARTUP=-v "$(PWD)/startup:/opt/startup"
DOCKER_PARAMS=--env-file .env \
	--name jenkins-test \
	--network jenkins-test

DOCKER_DOWN=docker compose down --remove-orphans

.PHONI: build run

build:
	@docker build --no-cache -t $(IMG_TAG) .

test: up
	@docker run -d --rm \
	$(V_TEST) \
	$(V_STARTUP) \
	$(DOCKER_PARAMS) \
	$(IMG_TAG)

	@docker exec -it -u root jenkins-test chmod -R +rwx /opt/test
	@docker exec -it jenkins-test /bin/bash -c '$(CMD)'

	@$(MAKE) down

ci-test: up
	@docker run -d --rm \
	$(V_TEST) \
	$(DOCKER_PARAMS) \
	$(IMG_TAG)

	@docker exec -u root jenkins-test chmod -R +rwx /opt/test
	@docker exec jenkins-test /bin/bash -c '$(CMD)'

	@$(MAKE) down

run: up
	@docker run -it --rm \
	-p "8080:8080" \
	$(V_STARTUP) \
	$(DOCKER_PARAMS) \
	$(IMG_TAG)
	@$(DOCKER_DOWN)


#run:
#	docker compose up -d
#	while ! docker logs jenkins-ldap 2>&1 | grep "Jenkins is fully up and running" ; do sleep 1; done
#
#jenkins-test:
#	if docker exec -t jenkins-ldap curl -k -u jenkins:password http://localhost:8080/metrics/currentUser/ping | grep pong; then \
#	  	echo "Jenkins LDAP auth OK"; \
#	else \
#		docker compose down; \
#		echo "Jenkins cant authenticate using LDAP credentials"; \
#	fi

up:
	@docker compose up -d

down:
	@docker stop jenkins-test || true
	@$(DOCKER_DOWN)
