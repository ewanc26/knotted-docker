# Tangled Knot Server in Docker

[Tangled](https://tangled.sh) is a git platform on top of the [AT Protocol](https://atproto.com), with the "knot servers" being where repositories are stored rather than [the user PDS](https://github.com/bluesky-social/pds). As such, this is a Dockerised form of [the official knot server](https://tangled.sh/@tangled.sh/core). It is not affiliated with the developers of Tangled or the AT Protocol.

## Prerequisites

1. **Docker**: Ensure Docker is installed on your system. You can download and install Docker from [here](https://docs.docker.com/get-docker/).
2. **Docker Compose**: Ensure Docker Compose is installed. Docker Compose is included with Docker Desktop, or you can install it separately by following the instructions [here](https://docs.docker.com/compose/install/).

### Optional

3. **Cloudflare Tunnel**: Ensure you have a Cloudflare Tunnel set up and configured via the Cloudflare web interface.

## Running yourself

1. Clone the repository:

    ```sh
    git clone https://github.com/ewanc26/knotted-docker.git
    cd knotted-docker
    ```

2. Edit `.local.env` to point to your local server's hostname and update the secret:

    ```env
    KNOT_SERVER_HOSTNAME=your.local.server
    KNOT_SERVER_SECRET=your_secret
    ```

3. Build and run the Docker containers in the background using `docker compose`:

    ```sh
    docker compose up --build -d
    ```

4. The server will be accessible on the ports defined in the `docker-compose.yml` file:
    - Knot Server: `http://your.local.server:5555`
    - Internal Listen Address: `127.0.0.1:5444`

### If routing through a Cloudflare Tunnel

5. Access the server through your existing Cloudflare Tunnel:
    - Ensure your Cloudflare Tunnel is configured to route traffic to `http://your.local.server:5555`.
    - Access your server via the Cloudflare Tunnel URL you have set up.

## Troubleshooting

If you encounter an `Already registered` error on the domain, follow these steps to resolve it:

1. List running Docker containers:

    ```sh
    docker ps
    ```

    Example output:

    ```log
    CONTAINER ID   IMAGE                            COMMAND                  CREATED          STATUS                  PORTS                                                                                      NAMES
    abcdef123456   knotted-docker-knot              "/usr/local/bin/knot…"   24 seconds ago   Up 7 seconds            0.0.0.0:5444->5444/tcp, [::]:5444->5444/tcp, 0.0.0.0:5555->5555/tcp, [::]:5555->5555/tcp   knotted-docker-knot-1
    ```

2. Execute a command inside the running container to list the contents of the `/knot` directory:

    ```sh
    docker exec -it <container_id> ls -l /knot
    ```

    Example output:

    ```log
    total 136
    drwxr-xr-x 2 git  git   4096 Mar 10 20:32 git
    -rw-r--r-- 1 root root  4096 Mar 10 20:32 knotserver.db
    -rw-r--r-- 1 root root 32768 Mar 10 21:53 knotserver.db-shm
    -rw-r--r-- 1 root root 94792 Mar 10 20:34 knotserver.db-wal
    ```

3. Stop and remove the container:

    ```sh
    docker stop <container_id>
    docker rm <container_id>
    ```

4. Remove the Docker volume:

    ```sh
    docker volume rm knotted-docker_knot_data
    ```

5. Rebuild and restart the Docker containers:

    ```sh
    docker compose up --build -d
    ```

These steps should help resolve the `Already registered` error on the domain.
