#!/usr/bin/env bash

# Copyright 2019-2020 Darren Weber
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Source this file from ~/.bashrc or similar shell-init, such
# as copy the file to /etc/profile.d/

# https://python-release-cycle.glitch.me/
# Declare a minimal python version to support; this is usually the lowest
# version that is still in active maintenance and it is not the default
# python version for conda.  As a python version approaches EOF support,
# bumping this to the next lowest version can assist migration strategies.
export PYTHON_SUPPORT_VERSION=3.7

# The conda-venv-py?? functions could be run anytime there is a patch release to
# any python version, updates to conda or anytime a clean conda env is required
# with a non-default python version.

conda-venv-py36 () {
    conda deactivate
    conda env remove -n py3.6 || true
    conda create -y -n py3.6 python=3.6
}

conda-venv-py37 () {
    conda deactivate
    conda env remove -n py3.7 || true
    conda create -y -n py3.7 python=3.7
}

conda-venv-py38 () {
    conda deactivate
    conda env remove -n py3.8 || true
    conda create -y -n py3.8 python=3.8
}

# declare some useful aliases to use a conda python version
alias conda-py36='conda deactivate; conda activate py3.6'
alias conda-py37='conda deactivate; conda activate py3.7'
alias conda-py38='conda deactivate; conda activate py3.8'

conda-project () {
    # The project name is defined by CONDA_ENV or the current working directory
    project=${CONDA_ENV:-$(pwd)}
    basename "${project}"
}

conda-venv-activate () {
    # try to activate a conda environment with the name of
    # the current directory (often this is a project name).
    wd=$(conda-project)
    conda deactivate
    conda activate "$wd"
}

conda-venv-create () {
    # create and activate a conda environment with the name
    # of the current directory (often this is a project name).
    py_ver="${1:-${PYTHON_SUPPORT_VERSION}}"
    wd=$(conda-project)
    conda deactivate

    conda create -n "$wd" python="${py_ver}" \
      --channel conda-forge --override-channels \
    && conda activate "$wd" \
    && conda config --env --add channels conda-forge \
    && conda config --env --set channel_priority strict
}

conda-venv-remove () {
    # try to activate a conda environment with the name of
    # the current directory (often this is a project name).
    wd=$(conda-project)
    conda deactivate
    conda env remove -n "$wd"
}

conda-venv () {
    # create and activate a conda environment with the name
    # of the current directory (often this is a project name).
    py_ver="${1:-${PYTHON_SUPPORT_VERSION}}"
    wd=$(conda-project)

    if conda env list | grep -E "^${wd}\s+" > /dev/null; then
        conda-venv-activate
    else
        conda-venv-create "${py_ver}"
    fi
    command -v poetry > /dev/null
    python --version
}

conda-pipenv () {
    conda-venv "$1"
    command -v pipenv > /dev/null | python -m pip install -U pipenv
    pipenv --python="$(conda run which python)" --site-packages
}

conda-install () {
    # Support OSX and Linux - a Windows user can add support for it later
    OS=$(uname)
    if [ "$OS" == "Darwin" ]; then
        installer='https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh'
    elif [ "$OS" == "Linux" ]; then
        installer='https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh'
    fi
    install_script="/tmp/$(basename $installer)"
    curl --silent $installer > "$install_script"
    /bin/bash "$install_script" -u
}

