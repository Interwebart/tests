#!/bin/bash

# Значения по умолчанию
PEER_IN=500
PEER_OUT=500

# Чтение аргументов командной строки
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --in) PEER_IN="$2"; shift ;;  # Входящие пиры
        --out) PEER_OUT="$2"; shift ;;  # Исходящие пиры
        *) echo "Неизвестный параметр: $1"; exit 1 ;;  # Ошибка для неизвестного параметра
    esac
    shift
done

# Проверка наличия файла docker-compose.yml
if [[ ! -f "docker-compose.yml" ]]; then
    echo "Ошибка: файл docker-compose.yml не найден."
    exit 1
fi

# Генерация docker-compose.override.yml
echo "Создание docker-compose.override.yml на основе docker-compose.yml..."
cp docker-compose.yml docker-compose.override.yml

# Добавление изменений в docker-compose.override.yml
echo "Добавление параметров --in=$PEER_IN и --out=$PEER_OUT в override..."
sed -i "/common:/a \ \ \ \ environment:\n      - PEER_IN=${PEER_IN}\n      - PEER_OUT=${PEER_OUT}" docker-compose.override.yml

# Запуск Docker Compose
echo "Запуск контейнеров с docker-compose.override.yml..."
docker-compose down --volumes
docker-compose up -d