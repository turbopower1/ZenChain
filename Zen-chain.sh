#!/bin/bash
# Color Variables for Resulting
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

# Prompts the user for the validator name
read -p "Enter validator name: " VALIDATOR_NAME

# Make sure the system has the required dependencies
install_dependencies() {
    echo -e "${YELLOW}Checking and installing required dependencies...${NC}"
    sudo apt-get update
    sudo apt-get install -y jq curl git build-essential
}

# Make sure Docker and Docker Compose are installed.
check_docker_installation() {
    if ! command -v docker &>/dev/null; then
        echo -e "${YELLOW}Docker not found. Installing Docker...${NC}"
        sudo apt-get install -y docker.io
        sudo systemctl start docker
        sudo systemctl enable docker
    else
        echo -e "${GREEN}Docker is installed.${NC}"
    fi

    if ! command -v docker-compose &>/dev/null; then
        echo -e "${YELLOW}Docker Compose not found. Installing Docker Compose...${NC}"
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.17.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        echo -e "${GREEN}Docker Compose is installed.${NC}"
    fi
}

# Verify that the data chain directory exists and has the correct permissions.
ensure_chain_data_directory() {
    echo -e "${YELLOW}Make sure the ./chain-data directory and permissions are correct...${NC}"

    # Required directory

    mkdir -p ./chain-data

    # Fixed directory permissions
    sudo chown -R $USER:$USER ./chain-data
    sudo chmod -R 755 ./chain-data

    echo -e "${GREEN}The ./chain-data directory and permissions are configured.${NC}"
}

# Create a docker-compose.yml file in the current directory.
create_docker_compose_file() {
    echo -e "${YELLOW}Create a docker-compose.yml file...${NC}"
    cat <<EOF >./docker-compose.yml
version: '3.8'
services:
  zenchain:
    image: ghcr.io/zenchain-protocol/zenchain-testnet:latest
    container_name: zenchain
    ports:
      - "9955:9944"
    volumes:
      - ./chain-data:/chain-data
      - ./zenchain-config:/config
    user: "${UID}:${GID}"  # Add user and group IDs according to those used on the host.
    command: >
      ./usr/bin/zenchain-node
      --base-path=/chain-data
      --rpc-cors=all
      --rpc-methods=unsafe
      --unsafe-rpc-external
      --validator
      --name=${VALIDATOR_NAME}
      --bootnodes=/dns4/node-7242611732906999808-0.p2p.onfinality.io/tcp/26266/p2p/12D3KooWLAH3GejHmmchsvJpwDYkvacrBeAQbJrip5oZSymx5yrE
      --chain=zenchain_testnet
EOF
    echo -e "${GREEN}The docker-compose.yml file is successfully created in the current directory.${NC}\n"
}

# Before running docker-compose, make sure you are in the correct directory.
run_docker_compose() {
    echo -e "${YELLOW}Running Docker Compose for the ZenChain node...${NC}"

    # Saves the current directory
    CURRENT_DIR=$(pwd)

    # Make sure we are in the same directory as docker-compose.yml.
    if [[ ! -f ./docker-compose.yml ]]; then
        echo -e "${RED}The file docker-compose.yml was not found in this directory!${NC}"
        exit 1
    fi

    # Run docker-compose from the directory where the files are located.
    docker-compose down
    docker-compose up -d
    echo -e "${GREEN}The ZenChain node is running successfully.${NC}"
}

# Wait 60 seconds to ensure RPC is active.
wait_for_rpc() {
    echo -e "${YELLOW}Waiting 60 seconds to make sure RPC is active...${NC}"
    sleep 60
}

# Get session keys
get_session_keys() {
    echo -e "${YELLOW}Obtaining session keys...${NC}"
    SESSION_KEYS=$(curl --max-time 10 --silent --retry 5 --retry-delay 5 --url http://localhost:9944 -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"author_rotateKeys","params":[],"id":1}' | jq -r .result)
    if [[ -z "$SESSION_KEYS" ]]; then
        echo -e "${YELLOW}Failed to obtain session keys. Make sure port 9944 is open.${NC}"
    else
        echo -e "${GREEN}Session keys successfully received: ${SESSION_KEYS}${NC}"
        echo "$SESSION_KEYS" > session_keys.txt
        echo -e "${GREEN}Session keys are displayed in the session_keys.txt file.${NC}"
    fi
}

# Viewing logs from Zenchain Docker containers
view_logs() {
    echo -e "${YELLOW}Viewing logs from a Zenchain Docker container...${NC}"
    docker logs -f zenchain
}

# Asks if you want to view the logs after the installation is complete.
view_logs_option() {
    echo -e "${YELLOW}Want to view ZenChain node logs?(y/n)${NC}"
    read -p "Pilih opsi: " VIEW_LOGS
    if [[ "$VIEW_LOGS" == "y" || "$VIEW_LOGS" == "Y" ]]; then
        view_logs
    else
        echo -e "${GREEN}The process is complete. Session keys are stored in the session_keys.txt file.${NC}"
    fi
}

# Displays an invitation to join a Telegram channel.
join_telegram_channel() {
    echo -e "${GREEN}Don't forget to write thanks in Telegram  ${NC}"
    echo -e "${GREEN}рџ‘‰ ${YELLOW}https://t.me/Swapapparat${NC}"
}

# We carry out all the steps
install_dependencies
check_docker_installation
ensure_chain_data_directory
create_docker_compose_file
run_docker_compose
wait_for_rpc
get_session_keys

# Displays the ability to view logs
view_logs_option

# Displays an invitation to join a Telegram channel.
join_telegram_channel
