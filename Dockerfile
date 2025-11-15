ARG GO_IMAGE=golang:1.25.3-alpine3.22
FROM ${GO_IMAGE} AS builder

# these are automatically set by Docker Buildx for multi-arch builds
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

WORKDIR /src

# download modules first (leverages Docker cache)
COPY go.mod go.sum ./
RUN go mod download

# copy source and build statically
COPY . .
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM=${TARGETVARIANT#v} go build -ldflags='-s -w' -o /out/pb-app

## -- Final image
FROM alpine:3.19 AS runtime

# install only ca-certificates for TLS, tini for PID 1 and su-exec to drop privileges later
RUN apk add --no-cache ca-certificates tini su-exec

# create a non-root user and group with fixed uid/gid
RUN addgroup -S pbgroup && adduser -S -G pbgroup -h /pb -s /sbin/nologin -u 10001 pbuser \
    && mkdir -p /pb

WORKDIR /pb

# copy binary and set permissions
COPY --from=builder /out/pb-app /pb/pb-app
RUN chmod 0755 /pb/pb-app

# keep user as root so the entrypoint can chown mounted volumes on startup,
# the entrypoint will drop privileges to pbuser using su-exec

# minimal healthcheck using wget (part of busybox in alpine)
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -qO- --timeout=2 http://127.0.0.1:8080/api/health || exit 1

EXPOSE 8080

# copy an entrypoint that will chown the data dir if needed and then run the app as pbuser
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 0755 /usr/local/bin/docker-entrypoint.sh && chown root:root /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/pb/pb-app", "serve", "--http=0.0.0.0:8080"]