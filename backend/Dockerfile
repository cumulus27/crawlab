FROM golang:1.14.3-alpine AS build

WORKDIR /go/src/app
COPY . .

ENV GO111MODULE on
ENV GOPROXY https://mirrors.aliyun.com/goproxy/

RUN go mod vendor
RUN go install -v ./...

FROM centos:centos7
WORKDIR /root
COPY --from=build /go/src/app .
COPY --from=build /go/bin/crawlab /usr/local/bin

EXPOSE 8000
CMD ["crawlab"]
