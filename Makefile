
.PHONI: run-and-test run jenkins-test
run-and-test: run jenkins-test
	docker compose down
	(info test has finished succesfully)

run:
	#docker compose build --no-cache && docker compose up -d
	docker compose up -d
	while ! docker logs jenkins-ldap 2>&1 | grep "Jenkins is fully up and running" ; do sleep 1; done

jenkins-test:
	if docker exec -t jenkins-ldap curl -k -u jenkins:password http://localhost:8080/metrics/currentUser/ping | grep pong; then \
	  	echo "Jenkins LDAP auth OK"; \
	else \
		docker compose down; \
		echo "Jenkins cant authenticate using LDAP credentials"; \
	fi