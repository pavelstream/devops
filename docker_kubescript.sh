#!/bin/bash

set -e  # Останавливает выполнение при первой ошибке

# Удаление текущих версий Docker (если установлены)
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y $pkg || { echo "Ошибка при удалении $pkg"; exit 1; }
done

# Обновление списка пакетов и установка необходимых утилит
sudo apt-get update || { echo "Ошибка при обновлении пакетов"; exit 1; }
sudo apt-get install -y ca-certificates curl || { echo "Ошибка при установке утилит"; exit 1; }
echo "Обновление  успешно!"

# Добавление ключа GPG Docker
sudo install -m 0755 -d /etc/apt/keyrings || { echo "Ошибка при создании директории"; exit 1; }
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc || { echo "Ошибка при загрузке ключа GPG"; exit 1; }
sudo chmod a+r /etc/apt/keyrings/docker.asc || { echo "Ошибка при установке прав"; exit 1; }

echo "Добавление ключа успешно!"

# Добавление репозитория Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || { echo "Ошибка при добавлении репозитория"; exit 1; }
echo "добавление репозитория успешно!"

# Обновление списка пакетов и установка Docker
sudo apt-get update -y || { echo "Ошибка при обновлении пакетов после добавления репозитория"; exit 1; }
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || { echo "Ошибка при установке Docker"; exit 1; }
echo "обновление пакетов и установка докер!"

# Добавление текущего пользователя в группу docker
sudo usermod -aG docker $USER || { echo "Ошибка при добавлении пользователя в группу"; exit 1; }
echo "добавления тек пользователя в группу!"
# Установка kubectl
curl -LO "https://dl.k8s.io/release/$(curl -LS https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" || { echo "Ошибка при загрузке kubectl"; exit 1; }
chmod +x ./kubectl || { echo "Ошибка при установке прав на kubectl"; exit 1; }
sudo mv ./kubectl /usr/local/bin/kubectl || { echo "Ошибка при перемещении kubectl"; exit 1; }

echo "Установка kubectl!"

# Установка minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 || { echo "Ошибка при загрузке minikube"; exit 1; }
chmod +x minikube || { echo "Ошибка при установке прав на minikube"; exit 1; }
sudo mv minikube /usr/local/bin/ || { echo "Ошибка при перемещении minikube"; exit 1; }

echo "Установка завершена успешно!"
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
newgrp docker
