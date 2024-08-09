FROM golang:alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 go build -o /go/bin/app

FROM alpine:latest

RUN apk add --no-cache \
    ca-certificates \
    curl

WORKDIR /pb

COPY --from=builder /go/bin/app /pb

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "curl", "-f", "http://localhost:8080/api/health" ]

EXPOSE 8080

CMD ["/pb/app", "serve", "--http=0.0.0.0:8080"]