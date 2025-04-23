echo "📦 Miniconda 다운로드 중..."
cd ~
curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

echo "📦 Miniconda 설치 중..."
bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3

# === 2. Conda 초기화 및 활성화 ===
echo "🔧 Conda 초기화..."
source "$HOME/miniconda3/etc/profile.d/conda.sh"
conda init bash
source ~/.bashrc

conda config --set auto_activate_base false

pip install -U pip
pip install jupyterlab ipykernel

echo "⚙️ Jupyter 설정 중..."
jupyter lab --generate-config

JUPYTER_CONFIG="$HOME/.jupyter/jupyter_lab_config.py"

echo "🔐 토큰/패스워드 없는 설정 추가..."
cat <<EOL >> $JUPYTER_CONFIG

c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.disable_check_xsrf = True
EOL
