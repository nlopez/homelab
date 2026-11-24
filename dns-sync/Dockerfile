FROM alpine:3.22

# kubectl talks to the in-cluster API, jq renders the record snapshot,
# and the push to the gateways is a plain ssh client session.
RUN apk add --no-cache kubectl jq openssh-client

COPY sync.sh /usr/local/bin/dns-sync
RUN chmod 0755 /usr/local/bin/dns-sync

USER 65532:65532
ENTRYPOINT ["/bin/sh", "/usr/local/bin/dns-sync"]
