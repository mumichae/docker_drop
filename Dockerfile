# base image
FROM conda/miniconda3-centos7

WORKDIR /drop

# build it with
# docker build . --no-cache --network=host --tag mertes/drop:latest --tag mertes/drop


# update system and conda 
RUN yum update -y
RUN conda update -n base -c defaults conda

# init drop env
COPY . .
RUN conda env create -f environment.yml

# clean cache
RUN conda clean --all -y
RUN yum clean all

# init conda and activate it always
RUN conda init bash
RUN echo "conda activate drop" > ~/.bashrc

# install tMAE
RUN conda activate drop && \
    R -e 'devtools::install("mumichae/tMAE")'

