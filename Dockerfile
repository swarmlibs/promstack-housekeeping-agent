FROM docker:cli
ADD rootfs /
RUN chmod +x /promstack-housekeeping-agent.sh
CMD [ "/promstack-housekeeping-agent.sh" ]
