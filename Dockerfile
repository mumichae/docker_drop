# base image
FROM conda/miniconda3-centos7

WORKDIR /drop

# build it with
# docker build . --no-cache --network=host --tag mertes/drop:latest --tag mertes/drop


# update system and conda 
RUN yum update -y
# check what we need for drop/R compilation
RUN yum install -y which bc less 
RUN conda update -n base -c defaults conda

# init drop env
COPY environment.yml .
RUN conda env create -f environment.yml

# clean cache
RUN conda clean --all -y
RUN yum clean all


# taken from: https://pythonspeed.com/articles/activate-conda-dockerfile/
# Make RUN commands use the new environment:
SHELL ["conda", "run", "-n", "drop-docker", "/bin/bash", "-c"]

# install tMAE
RUN R -e "BiocManager::install(\"c-mertes/tMAE@patch-1\", ask=FALSE, update=FALSE, dependencies=FALSE)"

RUN conda init
RUN echo "conda activate drop-docker" >> ~/.bashrc

# entry point
SHELL [ "bash", "-c" ]
COPY entry_point.sh /usr/local/bin/
## ENTRYPOINT ["conda", "run", "-n", "drop-docker", "bash", "-i"]
ENTRYPOINT [ "entry_point.sh"  ]
CMD bash
