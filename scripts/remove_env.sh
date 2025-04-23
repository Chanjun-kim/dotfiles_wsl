source "$HOME/miniconda3/etc/profile.d/conda.sh"

conda init bash

conda env remove -n "$1" -y
jupyter kernelspec uninstall "$1" -y