# About
A housekeeping agent for removing unused/out-dated Promstack config objects and Prometheus scrape configs on an interval.

## Usage

```yml
services:
  promstack-housekeeping-agent:
    image: swarmlibs/promstack-housekeeping-agent
    volumes:
      - type: bind
        source: /var/run/docker.sock
        target: /var/run/docker.sock
```
