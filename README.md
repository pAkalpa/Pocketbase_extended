# Extended Version of Pocketbase

This is an extended version of the Pocketbase project. The original project can be found [here](https://github.com/pocketbase/pocketbase).

In this version, I have added the following features:

- Configure visibility of the pocketbase admin UI through the `ADMIN_ENABLED` environment variable.

## How to run the project

### Run locally

1. Clone the repository
2. Run `ADMIN_ENABLED=true go run . serve` in the root directory of the project

### Use Docker

1. Clone the repository
2. Run `docker build -t pbe:latest .` in the root directory of the project
3. Run `docker run -p 8080:8080 -e ADMIN_ENABLED=true pbe:latest` to start the server

### Use Docker Compose

1.  Create a `docker-compose.yml` file with the following content:

```yaml
services:
  pb:
    build: . # use the pushed image by replacing this line with: image: pasinduakalpa/pbe:latest
    container_name: pocketbase
    ports:
      - "8080:8080"
    environment:
      - ADMIN_ENABLED=true
    volumes:
      - ./data:/pb/pb_data
```

2.  Run `docker-compose up -d` to start the server

## How to access the admin UI

The admin UI can be accessed at `http://localhost:8080/_` if the `ADMIN_ENABLED` environment variable is set to `true`.
