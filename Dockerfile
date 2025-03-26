FROM golang:1.24
WORKDIR /app
COPY . .
RUN go mod tidy && go build -o urlShortener
EXPOSE 8080
CMD ["./urlShortener"]