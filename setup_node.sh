#!/bin/bash

# setup_node.sh - Скрипт для настройки сервера

# Значения по умолчанию
SETUP=false

# Чтение аргументов командной строки
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -setup) SETUP=true ;;  # Установить флаг настройки
        *) echo "Неизвестный параметр: $1"; exit 1 ;;  # Ошибка для неизвестного параметра
    esac
    shift
done

# Если флаг -setup не указан, выводим ошибку
if ! $SETUP; then
    echo "Ошибка: укажите флаг -setup."
    echo "Использование: ./setup_node.sh -setup"
    exit 1
fi

# Функция для выполнения настройки сервера
setup_server() {
    echo "Начало настройки сервера..."

    # Установка необходимых утилит
    echo "Обновление списка пакетов и установка утилит..."
    sudo apt-get update &&
    sudo apt-get install -y vim ca-certificates curl git || {
        echo "Ошибка при установке базовых утилит.";
        exit 1;
    }

    # Установка Docker CE
    echo "Установка Docker CE..."
    sudo install -m 0755 -d /etc/apt/keyrings &&
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc &&
    sudo chmod a+r /etc/apt/keyrings/docker.asc &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | 
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null &&
    sudo apt-get update &&
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || {
        echo "Ошибка при установке Docker CE.";
        exit 1;
    }

    # Запуск Docker
    echo "Запуск Docker..."
    sudo systemctl start docker || {
        echo "Ошибка при запуске Docker.";
        exit 1;
    }

    # Настройка времени
    echo "Настройка времени с помощью chrony..."
    sudo apt-get install -y chrony &&
    sudo systemctl start chrony.service &&
    sudo chronyc -a makestep &&
    sudo hwclock --systohc || {
        echo "Ошибка при настройке времени.";
        exit 1;
    }

    # Установка PM2
    echo "Установка PM2..."
    sudo apt-get install -y npm &&
    sudo npm install pm2@latest -g || {
        echo "Ошибка при установке PM2.";
        exit 1;
    }

    echo "Настройка сервера завершена успешно!"
}

# Выполнение настройки, если указан флаг -setup
if $SETUP; then
    setup_server
fi