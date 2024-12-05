#!/bin/sh

DOCKER_STACK_NAMESPACE=${DOCKER_STACK_NAMESPACE:-promstack}
HOUSEKEEPING_INTERVAL=${HOUSEKEEPING_INTERVAL:-300}

logfmt() {
	echo "ts=\"$(date +'%Y-%m-%dT%H:%M:%S%z')\" $*"
}

logfmt_oneline() {
	echo -n "ts=\"$(date +'%Y-%m-%dT%H:%M:%S%z')\" $*"
}

function docker_config_prune() {
	local filter=$1
	for cid in $(docker config ls -q --filter=label=${filter}); do
		logfmt_oneline 'msg="Perform housekeeping on Docker config object"' 'filter="label='${filter}'"' 'id="'$cid'"'
		if docker config rm $cid > /dev/null 2>&1; then
			echo ' status="removed"'
		else
			echo ' status="skipped"'
		fi
		sleep 0.2
	done
}

exec 2>&1

if [ "$(docker node inspect self --format '{{.ManagerStatus.Leader}}')" != "true" ]; then
	logfmt 'msg="Promstack housekeeping agent is not running on the Swarm leader node, the agent will sleep forever."'
	sleep infinity
else
	logfmt 'msg="Starting Promstack housekeeping agent..."'

	while true; do
		logfmt 'msg="Schedule housekeeping on Docker config objects in '${HOUSEKEEPING_INTERVAL}' seconds..."'
		sleep ${HOUSEKEEPING_INTERVAL}

		count=0

		docker_config_prune "io.grafana.dashboard=true"
		docker_config_prune "io.grafana.provisioning.alerting=true"
		docker_config_prune "io.grafana.provisioning.dashboard=true"
		docker_config_prune "io.grafana.provisioning.datasource=true"
		docker_config_prune "io.prometheus.scrape_config=true"
		docker_config_prune "com.docker.stack.namespace=${DOCKER_STACK_NAMESPACE}"

		if [ $count -gt 0 ]; then
			logfmt 'msg="Housekeeping done, removed '${count}' Docker config objects."'
		fi
	done
fi

exit 0
