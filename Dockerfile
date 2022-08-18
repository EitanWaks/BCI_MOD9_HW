FROM python:3.10-bullseye

ENV DOCKER_BUILDKIT=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set git credentials; credentials must be in PATH
ARG gitusername=$GIT_USERNAME
ARG gitpassword=$GIT_PASSWORD

# Set github credentials
ARG githubnamespace=EitanWaks
ARG githubreponame=BCI_MOD9_HW
ARG githubrepo=${githubnamespace}/${githubreponame}.git

# Set dataset name and filetype; used for the url (permalink)
ARG datasetname=1
ARG datasettype=edf
ARG dataseturl=https://gin.g-node.org/robintibor/high-gamma-dataset/src/395f86583b7342e687dbfa5ef9077377b0428370/data/train/${datasetname}.${datasettype}

# Dataset hashed July, 20, 2022
ARG DATASET_SHA256=943390216871aee03dac6cda77e0f0ba34bc9adfc9d8bc7790127981b13b7bc4

# JupyterLab max_buffer_size (set in bytes)
ARG jupyterlab_max_buffer_size=24000000000

# Node.js version (latest or lts)
ARG npm_version=latest
ARG nodejs_version=lts

# Download High Gamma Dataset from https://gin.g-node.org/robintibor/high-gamma-dataset
WORKDIR /app
# ADD ${dataseturl} ./data/${datasetname}.${datasettype} #downloaded dataset does not load correctly
COPY ${datasetname}.${datasettype} ./data/${datasetname}.${datasettype}

# Hash checksum for the dataset
RUN echo "${DATASET_SHA256}  ./data/${datasetname}.${datasettype}" | sha256sum --check

# Download latest source code from github
RUN git clone https://${gitusername}:${gitpassword}@github.com/${githubrepo}

# Upgrade pip and install packages
RUN /usr/local/bin/python -m pip install --upgrade pip
RUN python -m pip install -r ./${githubreponame}/requirements.txt

# Install Node.js
RUN apt-get update && apt-get install -y \
    software-properties-common \
    npm
RUN npm install npm@${npm_version} -g && \
    npm install n -g && \
    n ${nodejs_version}

CMD ["jupyter-lab","--ip=0.0.0.0","--no-browser","--allow-root", "--ServerApp.max_buffer_size=${jupyterlab_max_buffer_size}"] 
