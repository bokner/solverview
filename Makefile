.PHONY: help

APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`


build_docker: ## Build the Docker image
	docker build --no-cache -t ${USER}/$(APP_NAME):latest .

run_docker: ## Run the app in Docker
	docker run -p 4000:4000 --rm -it ${USER}/$(APP_NAME):latest
