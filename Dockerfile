FROM docker:cli
RUN apk add --no-cache bash jq curl
ADD rootfs /
RUN chmod +x /promstack-housekeeping-agent.sh
CMD [ "/promstack-housekeeping-agent.sh" ]
