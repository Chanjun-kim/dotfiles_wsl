#!/bin/bash

# 1. bw 설치 확인
if ! command -v bw &> /dev/null; then
  echo "📦 Bitwarden CLI (bw) 설치 중..."
  curl -Lso bw.zip "https://vault.bitwarden.com/download/?app=cli&platform=linux"
  unzip bw.zip
  sudo mv bw /usr/local/bin
  rm bw.zip
  sudo apt update && sudo apt install jq -y
else
  echo "✅ Bitwarden CLI 이미 설치됨"
fi

# 2. 사용자 입력 받기
read -p "📧 Bitwarden 이메일 주소: " EMAIL
read -sp "🔑 Bitwarden 마스터 비밀번호: " PASSWORD
echo

# 3. 로그인 (이미 로그인 상태면 무시)
echo "👉 Bitwarden 계정에 로그인 중..."
bw login "$EMAIL" "$PASSWORD" || echo "✅ 이미 로그인 상태일 수 있음"

# 4. Vault Unlock → 세션 키 추출
SESSION_KEY=$(bw unlock "$PASSWORD" --raw)

if [ -z "$SESSION_KEY" ]; then
  echo "❗️ 세션 키를 얻지 못했습니다. 비밀번호를 다시 확인하세요."
  exit 1
fi

echo "✅ 세션 키 발급 완료"

# 5. 환경변수 등록 (.bashrc 기준)
echo "🔧 세션 키를 ~/.bashrc 에 저장 중..."
grep -q "export BW_SESSION=" ~/.bashrc && sed -i "/export BW_SESSION=/d" ~/.bashrc
echo "export BW_SESSION=$SESSION_KEY" >> ~/.bashrc

echo "✅ ~/.bashrc에 세션 키 등록 완료"
echo "💡 새 터미널을 열거나 아래 명령어로 적용:"
echo "    source ~/.bashrc"
