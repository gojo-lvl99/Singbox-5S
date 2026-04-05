FROM alpine:3.21 AS downloader
ARG SINGBOX_VERSION=1.10.0
ARG TARGETARCH=amd64
RUN apk add --no-cache wget ca-certificates \
    && wget -qO /tmp/sb.tar.gz \
       "https://github.com/SagerNet/sing-box/releases/download/v${SINGBOX_VERSION}/sing-box-${SINGBOX_VERSION}-linux-${TARGETARCH}.tar.gz" \
    && tar -xzf /tmp/sb.tar.gz -C /tmp \
    && mv /tmp/sing-box-*/sing-box /usr/local/bin/sing-box \
    && chmod +x /usr/local/bin/sing-box

FROM alpine:3.21
RUN apk add --no-cache ca-certificates
COPY --from=downloader /usr/local/bin/sing-box /usr/local/bin/sing-box
COPY config.json /config.json
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/sing-box", "run", "-c", "/config.json"]
