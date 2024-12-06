#!/bin/sh

LOGLEVEL=${LOGLEVEL:-info}
HOUSEKEEPING_INTERVAL=${HOUSEKEEPING_INTERVAL:-300}
DOCKER_STACK_NAMESPACE=${DOCKER_STACK_NAMESPACE:-promstack}

logfmt() {
	echo "ts=\"$(date +'%Y-%m-%dT%H:%M:%S%z')\" level=${LOGLEVEL:-info} $*"
}
logfmt_debug() {
	if [ "${LOGLEVEL}" = "debug" ]; then
		logfmt $*
	fi
}

logfmt_oneline() {
	echo -n "ts=\"$(date +'%Y-%m-%dT%H:%M:%S%z')\" $*"
}

function docker_config_prune() {
	local filter=$1
	for cid in $(docker config ls -q --filter=label=${filter}); do
		if docker config rm $cid > /dev/null 2>&1; then
			logfmt 'msg="Perform housekeeping on Docker config object"' 'filter="label='${filter}'"' 'id="'$cid'"' 'status="removed"'
		else
			logfmt_debug 'msg="Perform housekeeping on Docker config object"' 'filter="label='${filter}'"' 'id="'$cid'"' 'status="removed"'
		fi
		sleep 0.1
	done
}

exec 2>&1

if [ "$(docker node inspect self --format '{{.ManagerStatus.Leader}}')" != "true" ]; then
	logfmt 'msg="Promstack housekeeping agent is not running on the Swarm leader node, the agent will sleep forever."'
	sleep infinity
else
	logfmt 'msg="Starting Promstack housekeeping agent..."'
	logfmt 'msg="Schedule housekeeping task on Docker config objects every '${HOUSEKEEPING_INTERVAL}' seconds..."'

	while true; do
		sleep ${HOUSEKEEPING_INTERVAL}

		logfmt_debug 'msg="Starting the housekeeping task..."'
		start=$(date +%s)

		docker_config_prune "io.grafana.dashboard=true"
		docker_config_prune "io.grafana.provisioning.alerting=true"
		docker_config_prune "io.grafana.provisioning.dashboard=true"
		docker_config_prune "io.grafana.provisioning.datasource=true"
		docker_config_prune "io.prometheus.scrape_config=true"
		docker_config_prune "com.docker.stack.namespace=${DOCKER_STACK_NAMESPACE}"
		
		end=$(date +%s)
		duration=$((end-start))
		logfmt_debug 'msg="The housekeeping task finished in '${duration}' seconds."'
	done
fi

exit 0
