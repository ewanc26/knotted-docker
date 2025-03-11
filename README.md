# Tangled Knot Server in Docker

[Tangled](https://tangled.sh) is a git platform built on the [AT Protocol](https://atproto.com), with "knot servers" serving as repositories rather than [the user PDS](https://github.com/bluesky-social/pds). This Dockerized version of the [official knot server](https://tangled.sh/@tangled.sh/core) is unaffiliated with the developers of Tangled or the AT Protocol.

## Prerequisites

1. **Docker**: Ensure Docker is installed on your system. You can download and install Docker from [here](https://docs.docker.com/get-docker/). For a comprehensive introduction to Docker, consider watching the following tutorial:

   [Docker Tutorial for Beginners](https://www.youtube.com/watch?v=3c-iBn73dDE)

2. **Docker Compose**: Verify that Docker Compose is installed. Docker Compose is included with Docker Desktop, or you can install it separately by following the instructions [here](https://docs.docker.com/compose/install/).

3. **Cloudflare Tunnel**: If you plan to route your server through a Cloudflare Tunnel, install and configure `cloudflared` on your Ubuntu server.

### Installing and Configuring Cloudflared (Ubuntu)

1. **Install `cloudflared`**

   ```sh
   curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
   chmod +x cloudflared
   sudo mv cloudflared /usr/local/bin/
   ```

2. **Authenticate Cloudflare Tunnel**

   ```sh
   cloudflared tunnel login
   ```

   This will open a browser where you must log into your Cloudflare account and authorize `cloudflared`.

3. **Create a new Cloudflare Tunnel**

   ```sh
   cloudflared tunnel create my-tunnel
   ```

   Replace `my-tunnel` with a name of your choice.

4. **Configure the Tunnel**

   ```sh
   sudo mkdir -p /etc/cloudflared
   sudo nano /etc/cloudflared/config.yml
   ```

   Add the following:

   ```yaml
   tunnel: my-tunnel
   credentials-file: /root/.cloudflared/my-tunnel.json

   ingress:
     - hostname: yourdomain.com
       service: http://localhost:5555
     - service: http_status:404
   ```

   Replace `yourdomain.com` with your actual domain.

5. **Run the Tunnel**

   ```sh
   cloudflared tunnel run my-tunnel
   ```

   To run it as a service:

   ```sh
   sudo cloudflared service install
   sudo systemctl start cloudflared
   sudo systemctl enable cloudflared
   ```

## Running the Server

1. Clone the repository:

   ```sh
   git clone https://github.com/ewanc26/knotted-docker.git
   cd knotted-docker
   ```

2. Edit `.local.env` to specify your local server's hostname and update the secret:

   ```env
   KNOT_SERVER_HOSTNAME=your.local.server
   KNOT_SERVER_SECRET=your_secret
   ```

   **Security Note:** Do not hardcode sensitive information in `.local.env` if you plan to share your repository. Consider adding `.local.env` to `.gitignore` to prevent accidental exposure.

3. Build and run the Docker containers in the background using `docker compose`:

   ```sh
   docker compose up --build -d
   ```

4. Access the server on the ports defined in the `docker-compose.yml` file:
   - Knot Server: `http://your.local.server:5555`
   - Internal Listen Address: `127.0.0.1:5444`

### Routing Through a Cloudflare Tunnel

1. Ensure your Cloudflare Tunnel routes traffic to `http://your.local.server:5555`.
2. Access your server via the Cloudflare Tunnel URL you have set up.

### Configuring SSH for Git via Cloudflare Tunnel

1. Set up SSH for Git to work through your Cloudflare Tunnel:

   - Configure your Cloudflare Tunnel to route traffic to your SSH server (typically running on port 22).
   - Add a new service in your Cloudflare Tunnel configuration for SSH. For example, if your SSH server runs on `localhost:22`, you can add a service like this:

   ```sh
   cloudflared tunnel route dns <tunnel-name> git.yourdomain.com
   ```

   - Update your SSH configuration by editing your `~/.ssh/config` file to include:

   ```ssh
   Host git.yourdomain.com
       HostName git.yourdomain.com
       User git
       Port 22
       ProxyCommand cloudflared access ssh --hostname %h
   ```

   - Replace `git.yourdomain.com` with the hostname configured in your Cloudflare Tunnel.

2. Update your Git remote URL to use the configured Cloudflare Tunnel:

   ```sh
   git remote set-url origin ssh://git@git.yourdomain.com:22/your/repo.git
   ```

   - Replace `git.yourdomain.com` with your configured hostname and `your/repo.git` with your repository path.

3. Clone your Git repository via SSH using the Cloudflare Tunnel:

   ```sh
   git clone ssh://git@git.yourdomain.com:22/your/repo.git
   ```

## Troubleshooting

### Resolving `Already registered` Error

1. **List running Docker containers:**

   ```sh
   docker ps
   ```

2. **Check the contents of the `/knot` directory inside the running container:**

   ```sh
   docker exec -it <container_id> ls -l /knot
   ```

3. **Stop and remove the container:**

   ```sh
   docker stop <container_id>
   docker rm <container_id>
   ```

4. **Remove the Docker volume to clear persistent data:**

   ```sh
   docker volume rm knotted-docker_knot_data
   ```

5. **Rebuild and restart the Docker containers:**

   ```sh
   docker compose up --build -d
   ```

Following these steps should resolve the `Already registered` error and allow you to restart the Knot server successfully.
