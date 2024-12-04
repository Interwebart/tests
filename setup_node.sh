#!/bin/bash

# setup_and_run_node.sh - Скрипт для настройки и запуска Subtensor

set -e  # Остановить выполнение при любой ошибке

# Обновление системы и установка необходимых пакетов
echo "Обновление системы и установка необходимых пакетов..."
sudo apt-get update
sudo apt-get install -y vim ca-certificates curl

# Установка Docker
echo "Установка Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker

# Клонирование репозитория Subtensor
echo "Клонирование репозитория Subtensor..."
mkdir -p node
cd node
if [[ ! -d "subtensor" ]]; then
    git clone https://github.com/opentensor/subtensor.git
fi
cd subtensor
git checkout main
git pull

# Очистка Docker ресурсов
echo "Очистка ресурсов Docker..."
docker compose down --volumes
docker system prune -a --volumes -f

# Запуск Subtensor
echo "Запуск Subtensor..."
./scripts/run/subtensor.sh -e docker --network mainnet --node-type lite

# Просмотр логов
echo "Просмотр логов Subtensor..."
docker compose logs --tail=0 --follow