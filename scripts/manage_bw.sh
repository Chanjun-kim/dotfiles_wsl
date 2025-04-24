#!/bin/bash

# 🚀 bash 환경 보장
if [ -z "$BASH_VERSION" ]; then
  echo "❗️이 스크립트는 bash 환경에서 실행되어야 합니다."
  exec bash "$0" "$@"
fi

# 🛡️ Bitwarden 세션 확인 또는 unlock
if [[ -z "$BW_SESSION" ]]; then
  echo "🔐 Bitwarden Vault unlock 필요"
  read -sp "마스터 비밀번호: " PASSWORD
  echo
  export BW_SESSION=$(bw unlock "$PASSWORD" --raw)
  if [[ -z "$BW_SESSION" ]]; then
    echo "❌ unlock 실패. 비밀번호를 확인하세요."
    exit 1
  fi
fi

# 🔑 API Key 추가
add_key() {
  read -p "📝 저장할 키 이름: " NAME
  read -p "📄 설명 (옵션): " NOTES
  read -sp "🔐 API Key 값: " VALUE
  echo

  # JSON을 jq로 생성 → 절대 깨지지 않음
  JSON=$(jq -n \
    --arg name "$NAME" \
    --arg notes "$NOTES" \
    --arg user "API" \
    --arg pass "$VALUE" \
    '{
      type: 1,
      name: $name,
      notes: $notes,
      login: {
        username: $user,
        password: $pass
      }
    }')

  echo "🧪 생성된 JSON 구조:"
  echo "$JSON" | jq .

  # ✅ encode 한 후에 create에 전달
  ENCODED_JSON=$(echo "$JSON" | bw encode)
  bw create item "$ENCODED_JSON" --session "$BW_SESSION" > /dev/null

  echo "✅ [$NAME] 저장 완료"
}

# 🔍 키 조회
get_key() {
  read -p "🔍 조회할 키 이름: " NAME
  VALUE=$(bw get password "$NAME" --session "$BW_SESSION" 2>/dev/null)
  if [[ -z "$VALUE" ]]; then
    echo "❗️ [$NAME] 항목을 찾을 수 없습니다."
  else
    echo "🔐 $NAME = $VALUE"
  fi
}

# 📋 전체 목록
list_keys() {
  echo "📄 저장된 키 목록:"
  bw list items --session "$BW_SESSION" | jq -r '.[].name'
}

# 📜 메뉴 출력
echo "==============================="
echo "🗝️  Bitwarden Key Manager (WSL)"
echo "1) Key 추가"
echo "2) Key 조회"
echo "3) Key 목록 확인"
echo "0) 종료"
echo "==============================="
read -p "선택: " MENU

case $MENU in
  1) add_key ;;
  2) get_key ;;
  3) list_keys ;;
  0) echo "👋 종료합니다" ;;
  *) echo "❗️ 잘못된 선택" ;;
esac
