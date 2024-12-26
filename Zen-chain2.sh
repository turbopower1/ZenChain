#!/bin/bash

# Цвета текста
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Нет цвета (сброс цвета)

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


# Меню
echo -e "${YELLOW}Выберите действие:${NC}"
echo -e "${GREEN}1) Установка ноды${NC}"
echo -e "${GREEN}2) Удаление ноды${NC}"
echo -e "${GREEN}3) Обновление ноды${NC}"
echo -e "${GREEN}4) Получение сессионого ключа${NC}"
echo -e "${GREEN}5) Проверка логов (выход из логов CTRL+C)${NC}"

echo -e "${YELLOW}Введите номер:${NC} "
read choice

case $choice in
    1)
        echo -e "${BLUE}Устанавливаем ноду ...${NC}"

        # Обновляем и устанавливаем необходимые пакеты
        sudo apt update && sudo apt upgrade -y
        sleep 1
      

        # Установка бинарника
        echo -e "${BLUE}Загружаем бинарник ...${NC}"
        docker pull ghcr.io/zenchain-protocol/zenchain-testnet:v1.1.2

        # Создание директории 
        mkdir -p "$HOME/chain-data"
        chmod -R 777 "$HOME/chain-data"

# Введите имя валидатора
echo -e "${BLUE}Начнемс, скрипт все за тебя сделает ...${NC}"
read -p "Введите имя валидатора: " VALIDATOR_NAME

        # Установка ноды
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


        # Заключительный вывод
        echo -e "${GREEN}Установка завершена и нода запущена!${NC}"

               ;;
    
    2)
        echo -e "${BLUE}Удаление ноды ...${NC}"

        # Остановка и удаление
        docker stop zenchain
        docker rm zenchain
        sleep 1
              
        
        echo -e "${GREEN}Нода успешно удалена!${NC}"

        # Завершающий вывод
        echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
        echo -e "${YELLOW}Команда для проверки логов:${NC}" 
        echo "docker logs -f zenchain"
        echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
                echo -e "${CYAN}Telegram https://t.me/swapapparat${NC}"
        ;;
    4) 
    echo -e "${BLUE}Создаем сессионый ключ ...${NC}"    
    # Создание ключа
    curl -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "author_rotateKeys", "params":[]}' http://localhost:9955

    echo -e "${GREEN}Сохраните ключ в надежное место!${NC}"
    ;;
    
    5)
        docker logs -f zenchain
        
        
        
        ;;
        
        3)
        echo -e "${BLUE}Обновляем ноду ...${NC}"

        # Обновляем и устанавливаем необходимые пакеты
        sudo apt update && sudo apt upgrade -y
        sleep 1
      

        # Установка бинарника
        echo -e "${BLUE}Загружаем бинарник ...${NC}"
        docker pull ghcr.io/zenchain-protocol/zenchain-testnet:v1.1.2

# Удаление контейнера
  docker stop zenchain
        docker rm zenchain
        sleep 1
              
# Введите имя валидатора
echo -e "${BLUE}Начнемс, скрипт все за тебя сделает ...${NC}"
read -p "Введите имя валидатора: " VALIDATOR_NAME

        # Установка ноды
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


        # Заключительный вывод
        echo -e "${GREEN}Обновление завершено и нода запущена!${NC}"
        ;;
        
esac
