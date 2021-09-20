FROM golang:1.11-alpine AS builder
RUN apk add --update --no-cache ca-certificates tzdata && update-ca-certificates

RUN echo "[WARNING] Make sure you have run 'goreleaser release', before 'docker build'!"
ADD ./target/dist /opt/

FROM alpine as runner

RUN apk add --update --no-cache diffutils

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /opt/drone-cache_linux_amd64/drone-cache /bin/drone-cache

ARG BUILD_DATE
ARG VERSION
ARG VCS_REF
ARG DOCKERFILE_PATH

LABEL vendor="hummer12007" \
    name="hummer12007/drone-cache" \
    description="A Drone plugin for caching current workspace files between builds to reduce your build times." \
    maintainer="Kemal Akkoyun <kakkoyun@gmail.com>" \
    version="$VERSION" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.description="A Drone plugin for caching current workspace files between builds to reduce your build times." \
    org.label-schema.docker.cmd="docker run --rm -v '$(pwd)':/app -e DRONE_REPO=octocat/hello-world -e DRONE_REPO_BRANCH=master -e DRONE_COMMIT_BRANCH=master -e PLUGIN_MOUNT=/app/node_modules -e PLUGIN_RESTORE=false -e PLUGIN_REBUILD=true -e PLUGIN_BUCKET=<bucket> -e AWS_ACCESS_KEY_ID=<token> -e AWS_SECRET_ACCESS_KEY=<secret> meltwater/drone-cache" \
    org.label-schema.docker.dockerfile=$DOCKERFILE_PATH \
    org.label-schema.name="meltwater/drone-cache" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/hummer12007/drone-cache" \
    org.label-schema.vendor="hummer12007/drone-cache" \
    org.label-schema.version=$VERSION

ENTRYPOINT ["/bin/drone-cache"]
