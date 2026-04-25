FROM node:20-alpine AS assets-builder

WORKDIR /src/assets

ARG VERSION=4.15.0-next

COPY assets/package.json assets/yarn.lock assets/package-lock.json ./
RUN yarn install --network-timeout 1000000

COPY assets/ ./
RUN yarn version --new-version "${VERSION}" --no-git-tag-version \
    && yarn run build

FROM golang:1.25-alpine AS cloudreve-binary-builder

WORKDIR /src

ARG VERSION=4.15.0-next
ARG COMMIT=0000000

RUN apk add --no-cache git zip

COPY go.mod go.sum ./
RUN go mod download

COPY application ./application
COPY cmd ./cmd
COPY ent ./ent
COPY inventory ./inventory
COPY middleware ./middleware
COPY pkg ./pkg
COPY routers ./routers
COPY service ./service
COPY main.go ./

COPY --from=assets-builder /src/assets/build /tmp/assets/build

RUN mkdir -p application/statics \
    && cd /tmp \
    && zip -r - assets/build > /src/application/statics/assets.zip \
    && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GOAMD64=v1 \
        go build -trimpath \
        -ldflags="-s -w -X github.com/cloudreve/Cloudreve/v4/application/constants.BackendVersion=${VERSION} -X github.com/cloudreve/Cloudreve/v4/application/constants.LastCommit=${COMMIT}" \
        -o /out/cloudreve .

FROM scratch AS cloudreve-binary-export

COPY --from=cloudreve-binary-builder /out/cloudreve /cloudreve

FROM alpine:latest

WORKDIR /cloudreve

RUN apk update \
    && apk add --no-cache tzdata vips-tools ffmpeg libreoffice aria2 supervisor font-noto font-noto-cjk libheif libraw-tools\
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && mkdir -p ./data/temp/aria2 \
    && chmod -R 766 ./data/temp/aria2

ENV CR_ENABLE_ARIA2=1 \
    CR_SETTING_DEFAULT_thumb_ffmpeg_enabled=1 \
    CR_SETTING_DEFAULT_thumb_vips_enabled=1 \
    CR_SETTING_DEFAULT_thumb_libreoffice_enabled=1 \
    CR_SETTING_DEFAULT_media_meta_ffprobe=1  \
    CR_SETTING_DEFAULT_thumb_libraw_enabled=1

COPY .build/aria2.supervisor.conf .build/entrypoint.sh ./
COPY --from=cloudreve-binary /cloudreve /cloudreve

RUN chmod +x ./cloudreve \
    && chmod +x ./entrypoint.sh

EXPOSE 5212 443 6888 6888/udp

VOLUME ["/cloudreve/data"]

ENTRYPOINT ["sh", "./entrypoint.sh"]
