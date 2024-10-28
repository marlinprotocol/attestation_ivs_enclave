# base image
FROM alpine:3.17

# install dependency tools
RUN apk add --no-cache net-tools iptables iproute2 wget

# working directory
WORKDIR /app

# supervisord to manage programs
COPY supervisord ./
RUN chmod +x supervisord

# transparent proxy component inside the enclave to enable outgoing connections
COPY ip-to-vsock-transparent ./
RUN chmod +x ip-to-vsock-transparent

# key generator to generate static keys
COPY keygen ./
RUN chmod +x keygen

# attestation server inside the enclave that generates attestations
COPY attestation-server ./
RUN chmod +x attestation-server

# proxy to expose attestation server outside the enclave
COPY vsock-to-ip ./
RUN chmod +x vsock-to-ip

# dnsproxy to provide DNS services inside the enclave
COPY dnsproxy ./
RUN chmod +x dnsproxy

COPY oyster-keygen ./
RUN chmod +x oyster-keygen

# supervisord config
COPY supervisord.conf /etc/supervisord.conf

COPY input-verification-executable ./
RUN chmod +x input-verification-executable

# setup.sh script that will act as entrypoint
COPY setup.sh ./
RUN chmod +x setup.sh

# entry point
ENTRYPOINT [ "/app/setup.sh" ]