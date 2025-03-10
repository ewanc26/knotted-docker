# Tangled.sh Knot Server running locally

## Prerequisites

1. **Docker**: Ensure Docker is installed on your system. You can download and install Docker from [here](https://docs.docker.com/get-docker/).
2. **Docker Compose**: Ensure Docker Compose is installed. Docker Compose is included with Docker Desktop, or you can install it separately by following the instructions [here](https://docs.docker.com/compose/install/).
3. **Cloudflare Tunnel**: Ensure you have a Cloudflare Tunnel set up and configured via the Cloudflare web interface.

## Running yourself

1. Clone the repository:

    ```sh
    git clone https://github.com/ewanc26/knotted-docker.git
    cd knotted-docker
    ```

2. Edit `.local.env` to point to your local server's hostname:

    ```env
    KNOT_SERVER_HOSTNAME=your.local.server
    ```

3. Build and run the Docker containers using `docker compose`:

    ```sh
    docker compose up --build
    ```

4. The server will be accessible on the ports defined in the `docker-compose.yml` file:
    - Knot Server: `http://your.local.server:5555`
    - Internal Listen Address: `127.0.0.1:5444`

5. Access the server through your existing Cloudflare Tunnel:
    - Ensure your Cloudflare Tunnel is configured to route traffic to `http://your.local.server:5555`.
    - Access your server via the Cloudflare Tunnel URL you have set up.
