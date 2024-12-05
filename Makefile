it:
	docker buildx bake --load dev

run:
	docker run --rm -it \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-e HOUSEKEEPING_INTERVAL=15 \
	swarmlibs/promstack-housekeeping-agent:dev
