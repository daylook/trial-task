
FROM golang:1.23-alpine AS builder

WORKDIR /src

COPY go.mod go.sum ./

RUN go mod download && go mod verify

COPY . .

RUN go version

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w" \
    -o /bin/app cmd/main.go

FROM alpine:3.19

RUN apk add --no-cache ca-certificates bash

WORKDIR /app

COPY --from=builder /bin/app /app/app

CMD ["/app/app"]