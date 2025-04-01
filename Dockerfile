FROM alpine AS base

LABEL maintainer="meteormin"

ARG TIME_ZONE="Asia/Seoul"

RUN apk --no-cache add tzdata curl && \
	cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime && \
	echo "${TIME_ZONE}" > /etc/timezone \
	apk del tzdata

FROM golang:1.24-alpine AS build

WORKDIR /app

COPY go.mod .

COPY ./api .

RUN go mod download && go build -o main main.go

FROM base AS production

WORKDIR /app

COPY --from=build /app/main .

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "./main"]
