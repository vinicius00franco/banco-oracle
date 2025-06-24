# Oracle XE 21c with Docker

This repository provides scripts and configuration files to build and run an Oracle XE 21c database using Docker.

## Requirements

- **Docker** and **Docker Compose** must be installed and running.
- You need to log in to the Oracle Container Registry to download the image `container-registry.oracle.com/database/express:21.3.0-xe`.

## Quick start

1. Clone this repository and navigate into it:
   ```bash
   git clone <repo-url>
   cd banco-oracle
   ```
2. Ensure Docker and Docker Compose are installed. On Ubuntu you can install them with:
   ```bash
   sudo apt-get update
   sudo apt-get install -y docker.io docker-compose
   sudo systemctl enable --now docker
   ```
3. Log in to the Oracle Container Registry:
   ```bash
   docker login container-registry.oracle.com
   ```
   Accept the license for the `database/express` repository in your Oracle account before logging in.
4. Run the setup script, which builds the image and starts the container:
   ```bash
   ./setup-oracle.sh
   ```
   The first run may take several minutes while the image is downloaded and initialized.

The container exposes port **1521** for database connections and port **5500** for Oracle Enterprise Manager. An optional Adminer container is exposed on port **8080**.

## Scripts

- `setup-oracle.sh` – builds the Docker image, starts the database container and executes SQL scripts located in `scripts-sql/`.
- `monitor-oracle.sh` – shows container status, resource usage and recent logs.
- `backup-oracle.sh` – exports the `lab_acidentes` schema to `./data/backup/` using `expdp`.

## Data persistence

Persistent volumes are defined in `docker-compose.yml` and mapped to the `./data/oracle` and `./data/backup` directories on the host.

## Troubleshooting

If Docker cannot start due to missing privileges or kernel capabilities, ensure you are running in an environment that supports Docker (for example, a local machine or VM with full root access). Container-based environments without the necessary kernel features may not be able to start the Docker daemon.
