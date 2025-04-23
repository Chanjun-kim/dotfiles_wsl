#!/bin/bash

set -e  # 오류 발생 시 스크립트 즉시 종료

echo "🐳 [1] 필수 패키지 설치 중..."
sudo apt update
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "🔐 [2] Docker GPG 키 추가 중..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "📦 [3] Docker 저장소 등록 중..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "📥 [4] Docker 엔진 설치 중..."
sudo apt update
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo "✅ Docker 설치 완료!"

echo "🧪 [5] hello-world 테스트 실행 중..."
sudo docker run hello-world

echo "👤 [6] sudo 없이 docker 사용 설정 중..."
sudo groupadd docker 2>/dev/null || echo "⚠️ docker 그룹 이미 존재함"
sudo usermod -aG docker "$USER"

echo "🔁 현재 세션에 docker 그룹 적용 중..."
newgrp docker << END
echo "✅ 현재 세션에 docker 권한 적용됨!"
docker version
docker compose version
END

echo ""
echo "🎉 모든 작업 완료! 새 터미널을 열거나 logout → login 하면 sudo 없이 docker 사용 가능!"
