#!/bin/bash

# [1] Conda 초기화 스크립트를 명시적으로 source (가장 중요!)
source "$HOME/miniconda3/etc/profile.d/conda.sh"

# [2] 사용자 입력값 확인
if [ -z "$1" ]; then
    echo "❗️ Error: Environment name is required"
    exit 1
fi

ENV_NAME="$1"
PYTHON_VERSION="${2:-3.12}"

echo "📦 Creating conda env: $ENV_NAME (Python $PYTHON_VERSION)"
conda create -n "$ENV_NAME" python="$PYTHON_VERSION" -y

echo "🚀 Activating env: $ENV_NAME"
conda init bash
conda activate "$ENV_NAME"

echo "🐍 Python path: $(which python)"

# [3] Jupyter 관련 패키지 설치 및 커널 등록
pip install -U pip --quiet
pip install -U jupyter ipykernel --quiet
python -m ipykernel install --user --name "$ENV_NAME" --display-name "Python ($ENV_NAME)"

# [4] 사용자 정의 커널 수정 스크립트 실행
USER=$(whoami)
python ~/dotfiles_wsl/scripts/edit_kernel.py --env "$ENV_NAME" --user "$USER"

echo "✅ Kernel '$ENV_NAME' created and registered for Jupyter"
