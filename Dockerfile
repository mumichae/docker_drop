# base image
FROM conda/miniconda3-centos7

WORKDIR /drop

# build it with
# docker build . --no-cache --network=host --tag mertes/drop:latest --tag mertes/drop

# update conda 
RUN conda update -n base -c defaults conda

# init drop env
COPY . .
RUN conda env create -f requirements.yml
