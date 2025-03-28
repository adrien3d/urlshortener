# UrlShortener

## Introduction

We want to build an **URL Shortener** service (only the API). The API can be used to turn a long URL into a tiny URL.

A long URL might look like:

> https://medium.com/equify-tech/the-three-fundamental-stages-of-an-engineering-career-54dac732fc74

And the service would turn it into a tiny URL that could look like this:

> https://\<my-domain\>/\<slug\>

When the user types this URL in its browser it is automatically redirected to the original URL via an HTTP redirect.

**_\<my-domain\>_** would be the domain of the API, for example tiny.io. For the purpose of this test, you can use localhost.

**_\<slug\>_** would be a random short string with letters and numbers. (eg. aY2Pv8, Lt1fov, 9vqp4g…)
```

# Installation and Setup

### Requirements
- GNU Make
- Docker
- Golang (if not using Docker)


## Usage

The Makefile allows you to perform the following actions:
1. Test
2. Fmt
3. Lint
4. Install
5. Build
6. Run

### Building the Docker Image

To build the Docker image, run:
```sh
docker build -t urlShortenet .
```
or just run `make build`

### Running the API
Then, to start the API on port 8080:
```sh
 docker compose up -d
```
or just run `make run`

Instead of you can run `make execute` which will compile and build the image first (no cache enabled)

## Running Tests
In order to test the code, just run `make test`.
