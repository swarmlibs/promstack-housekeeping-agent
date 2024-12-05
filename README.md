# About
A housekeeping agent for removing unused/out-dated Promstack, Grafana and Prometheus's Docker config objects on an interval.

## Usage

```yml
services:
  housekeeping-agent:
    image: swarmlibs/promstack-housekeeping-agent
    volumes:
      - type: bind
        source: /var/run/docker.sock
        target: /var/run/docker.sock
```
