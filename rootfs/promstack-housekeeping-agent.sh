#!/bin/sh

DOCKER_STACK_NAMESPACE=${DOCKER_STACK_NAMESPACE:-promstack}
HOUSEKEEPING_INTERVAL=${HOUSEKEEPING_INTERVAL:-300}

logfmt() {
	echo "ts=\"$(date +'%Y-%m-%dT%H:%M:%S%z')\" $*"
}

logfmt_oneline() {
	echo -n "ts=\"$(date +'%Y-%m-%dT%H:%M:%S%z')\" $*"
}

logfmt 'msg="Starting Promstack housekeeping agent..."'

exec 2>&1

while true; do
	logfmt 'msg="Schedule housekeeping on Docker config objects in '${HOUSEKEEPING_INTERVAL}' seconds..."'
	sleep ${HOUSEKEEPING_INTERVAL}

	count=0

	# Promstask
	for cid in $(docker config ls -q --filter=label=com.docker.stack.namespace=${DOCKER_STACK_NAMESPACE}); do
		logfmt_oneline 'msg="Perform housekeeping on Docker config object"' 'filter="label=com.docker.stack.namespace='${DOCKER_STACK_NAMESPACE}'"' 'id="'$cid'"'
		if docker config rm $cid > /dev/null 2>&1; then
			echo ' status="removed"'
		else
			echo ' status="skipped"'
		fi
	done

	# Prometheus
	for cid in $(docker config ls -q --filter=label=io.prometheus.scrape_config=true); do
		logfmt_oneline 'msg="Perform housekeeping on Docker config object"' 'filter="label=io.prometheus.scrape_config=true"' 'id="'$cid'"'
		if docker config rm $cid > /dev/null 2>&1; then
			echo ' status="removed"'
			count=$((count+1))
		else
			echo ' status="skipped"'
		fi
	done

	# Grafana
	for cid in $(docker config ls -q --filter=label=io.grafana.dashboard=true); do
		logfmt_oneline 'msg="Perform housekeeping on Docker config object"' 'filter="label=io.grafana.dashboard=true"' 'id="'$cid'"'
		if docker config rm $cid > /dev/null 2>&1; then
			echo ' status="removed"'
			count=$((count+1))
		else
			echo ' status="skipped"'
		fi
	done
	for cid in $(docker config ls -q --filter=label=io.grafana.provisioning.alerting=true); do
		logfmt_oneline 'msg="Perform housekeeping on Docker config object"' 'filter="label=io.grafana.provisioning.alerting=true"' 'id="'$cid'"'
		if docker config rm $cid > /dev/null 2>&1; then
			echo ' status="removed"'
			count=$((count+1))
		else
			echo ' status="skipped"'
		fi
	done
	for cid in $(docker config ls -q --filter=label=io.grafana.provisioning.dashboard=true); do
		logfmt_oneline 'msg="Perform housekeeping on Docker config object"' 'filter="label=io.grafana.provisioning.dashboard=true"' 'id="'$cid'"'
		if docker config rm $cid > /dev/null 2>&1; then
			echo ' status="removed"'
			count=$((count+1))
		else
			echo ' status="skipped"'
		fi
	done
	for cid in $(docker config ls -q --filter=label=io.grafana.provisioning.datasource=true); do
		logfmt_oneline 'msg="Perform housekeeping on Docker config object"' 'filter="label=io.grafana.provisioning.datasource=true"' 'id="'$cid'"'
		if docker config rm $cid > /dev/null 2>&1; then
			echo ' status="removed"'
		else
			echo ' status="skipped"'
		fi
	done

	if [ $count -gt 0 ]; then
		logfmt 'msg="Housekeeping done, removed '${count}' Docker config objects."'
	fi
done

exit 0
