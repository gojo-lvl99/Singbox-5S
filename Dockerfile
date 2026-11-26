# -----------------------------------------------------------------------------
# Multi-stage image: download the pinned sing-box binary, then copy it into the
# smaller runtime image without carrying downloader tools into production.
# -----------------------------------------------------------------------------

# Build stage: fetch and prepare the sing-box executable.
FROM alpine:3.24.4 AS downloader

# Keep the sing-box release and target architecture explicit and overridable.
ARG SINGBOX_VERSION=1.14.4
ARG TARGETARCH=amd64

# Install download and certificate tools, then extract the release binary.
RUN apk add --no-cache wget ca-certificates \
    && wget -qO /tmp/sb.tar.gz \
       "https://github.com/SagerNet/sing-box/releases/download/v${SINGBOX_VERSION}/sing-box-${SINGBOX_VERSION}-linux-${TARGETARCH}.tar.gz" \
    && tar -xzf /tmp/sb.tar.gz -C /tmp \
    && mv /tmp/sing-box-*/sing-box /sing-box \
    && chmod +x /sing-box

# Runtime stage: use Alpine with only the CA certificates required at runtime.
FROM alpine:3.24.4
RUN apk add --no-cache ca-certificates

# Copy the prepared binary and the service configuration from the build context.
COPY --from=downloader /sing-box /usr/local/bin/sing-box
COPY config.json /etc/sing-box/config.json

# Cloud Run supplies PORT; expose the same default port used by config.json.
ENV PORT=8080
EXPOSE 8080

# Start sing-box directly as the container's main process.
ENTRYPOINT ["/usr/local/bin/sing-box", "run", "-c", "/etc/sing-box/config.json"]
