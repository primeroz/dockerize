FROM golang:alpine3.11 AS binary

RUN apk -U add openssl git

ADD . /go/src/github.com/primeroz/dockerize
WORKDIR /go/src/github.com/primeroz/dockerize

RUN go mod download
RUN go install

FROM alpine:3.11
MAINTAINER Francesco Ciocchetti <primeroznl@gmail.com>

COPY --from=binary /go/bin/dockerize /usr/local/bin

ENTRYPOINT ["dockerize"]
CMD ["--help"]
