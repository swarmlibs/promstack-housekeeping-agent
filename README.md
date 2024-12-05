# About
A housekeeping agent for Promstack

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
