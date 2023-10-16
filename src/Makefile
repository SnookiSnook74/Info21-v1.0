## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
## @copyright Copyright [2023] <Phylis Cristobal>  ##
## @file Makefile                                  ##
## @date 2023-09-13                                ##
## @author Phylis Cristobal (phyliscr)             ##
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##

CONTAINER := sql_info_v1
VOLUME := $(shell docker inspect --format='{{range .Mounts}}{{.Name}}{{end}}' $(CONTAINER))

.PHONY: list new prune

list:
	@-docker container ls --filter='name=$(CONTAINER)' 
	@echo VOLUME: $(VOLUME)

new:
	@-docker ps --all
	@-docker run --name $(CONTAINER) -e POSTGRES_PASSWORD=test12345 -d -p 5432:5432 postgres
	@-docker ps --all

prune:
	@-docker stop $(CONTAINER) 
	@-docker container rm $(CONTAINER)
	@-docker volume rm $(VOLUME)
