#!/bin/bash

# Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No color (color reset)

 # Make sure the system has the required dependencies
    install_dependencies() {
    echo -e "${YELLOW}Проверка и установка необходимых зависимостей...${NC}"
    sudo apt-get update
    sudo apt-get install -y jq curl git build-essential
}

 # Make sure Docker and Docker Compose are installed.
    check_docker_installation() {
    if ! command -v docker &>/dev/null; then
        echo -e "${YELLOW}Докер не найден. Установка Докера...${NC}"
        sudo apt-get install -y docker.io
        sudo systemctl start docker
        sudo systemctl enable docker
    else
        echo -e "${GREEN}Докер установлен..${NC}"
    fi

    if ! command -v docker-compose &>/dev/null; then
        echo -e "${YELLOW}Docker Compose не найден. Установка Docker Compose...${NC}"
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.17.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        echo -e "${GREEN}Docker Compose установлен..${NC}"
    fi
}


        # Menu
        echo -e "${YELLOW}Выберите действие:${NC}"
        echo -e "${BLUE}1) Установка ноды${NC}"
        echo -e "${BLUE}2) Удаление ноды${NC}"
        echo -e "${BLUE}3) Обновление ноды${NC}"
        echo -e "${BLUE}4) Получить сессионый ключ${NC}"
        echo -e "${BLUE}5) Проверка логов (выход CTRL+C)${NC}"

        echo -e "${YELLOW}Введите номер:${NC} "
        read choice

case $choice in
    1)
        echo -e "${BLUE}Установка ноды ...${NC}"

        # Update and install the necessary packages
        sudo apt update && sudo apt upgrade -y
        sleep 1
      

        # Installation
        echo -e "${BLUE}Загрузка ...${NC}"
        docker pull ghcr.io/zenchain-protocol/zenchain-testnet:v1.1.2

        # Creating a directory
        mkdir -p "$HOME/chain-data"
        chmod -R 777 "$HOME/chain-data"

        # Enter validator name
        echo -e "${BLUE}Начнемс, следуйте подсказкам на экране ...${NC}"
        read -p "Введите имя валидатора (Пример: HiWorld): " VALIDATOR_NAME

               
               
        # Checking for conflicts with the container name
        echo -e "${BLUE}Проверка существующего контейнера с именем «zenchain»....${NC}"
        if docker ps -a --format '{{.Names}}' | grep -Eq "^zenchain\$"; then
            echo -e "${YELLOW}Контейнер с именем «zenchain» уже существует. Удаляем его...${NC}"
            docker stop zenchain && docker rm zenchain
            echo -e "${GREEN}Существующий контейнер успешно удален.${NC}"
        fi

        # Restarting the node installation
        echo -e "${BLUE}Запускаем процесс установки заново...${NC}"
        docker run \
        -d \
        --name zenchain \
        -p 9955:9944 \
        -v ./chain-data:/chain-data \
        --user $(id -u):$(id -g) \
        ghcr.io/zenchain-protocol/zenchain-testnet:v1.1.2 \
        ./usr/bin/zenchain-node \
        --base-path=/chain-data \
        --rpc-cors=all \
        --rpc-methods=Unsafe \
        --unsafe-rpc-external \
        --validator \
        --name=${VALIDATOR_NAME} \
        --bootnodes=/dns4/node-7274523776613056512-0.p2p.onfinality.io/tcp/24453/ws/p2p/12D3KooWDLh2E27VUrXRBvCP6YMz7PzZCVK3Kpwv42Sj1MHJJvN6 \
        --chain=zenchain_testnet

        # Final Conclusion
        echo -e "${GREEN}Установка завершена и узел запущен! После установки получите сеансовый ключ, перезапустив скрипт командой (./Zen-chain.sh)${NC}"
        echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
        echo -e "${CYAN}Discord-longlifemmm${NC}"
        echo -e "${CYAN}Telegram-https://t.me/swapapparat${NC}"
        echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
               ;;
    
    2)
        echo -e "${BLUE}Удаление ноды ...${NC}"

        # Stop and delete
        docker stop zenchain
        docker rm zenchain
        sleep 1
              
        
        echo -e "${GREEN}Нода успешно удалена!${NC}"

        # Final conclusion
        echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
        echo -e "${CYAN}Discord-longlifemmm${NC}"
        echo -e "${CYAN}Telegram-https://t.me/swapapparat${NC}"
        echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
        ;;
    4) 
        echo -e "${BLUE}Создание сессионого ключа ...${NC}"    
        # Key creation
        curl -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "author_rotateKeys", "params":[]}' http://localhost:9955

        echo -e "${GREEN}Сохраните в надежном месте!${NC}"
    ;;
    
    5)
        docker logs -f zenchain
        
        
        
        ;;
        
        3)
        echo -e "${BLUE}Обновление ноды ...${NC}"

        # Update and install the necessary packages
        sudo apt update && sudo apt upgrade -y
        sleep 1
      

        # Installation
        echo -e "${BLUE}Загрузка ...${NC}"
        docker pull ghcr.io/zenchain-protocol/zenchain-testnet:v1.1.2

        # Removing a container
        docker stop zenchain
        docker rm zenchain
        sleep 1
              
        # Enter validator name
        echo -e "${BLUE}Начнемс, следуйте подсказкам на экране ...${NC}"
        read -p "Введите имя валидатора (Пример: HiWorld): " VALIDATOR_NAME

        # Node installation
        docker run \
  -d \
  --name zenchain \
  -p 9955:9944 \
  -v ./chain-data:/chain-data \
  --user $(id -u):$(id -g) \
  ghcr.io/zenchain-protocol/zenchain-testnet:v1.1.2 \
  ./usr/bin/zenchain-node \
  --base-path=/chain-data \
  --rpc-cors=all \
  --rpc-methods=Unsafe \
  --unsafe-rpc-external \
  --validator \
  --name=${VALIDATOR_NAME} \
  --bootnodes=/dns4/node-7274523776613056512-0.p2p.onfinality.io/tcp/24453/ws/p2p/12D3KooWDLh2E27VUrXRBvCP6YMz7PzZCVK3Kpwv42Sj1MHJJvN6 \
  --chain=zenchain_testnet


        # Final Conclusion
        echo -e "${GREEN}Обновление завершено, нода запущена! Всего хорошего!${NC}"
        ;;
        
esac

