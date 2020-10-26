# build it with
# docker build . --network=host --tag mertes/drop:latest --tag mertes/drop

# base image
FROM conda/miniconda3-centos7
ARG DROP_VERSION=1.0.0

# update and setup system
RUN yum update -y --exclude=setup \
    && yum install -y which bc less wget vim \
    && yum clean all \
    && conda update -n base -c defaults conda

# init drop env
RUN conda create -y -c conda-forge -c bioconda -n drop \
        drop=$DROP_VERSION \
        r-base=4.0.2 \
        #bioconductor-mafdb.gnomad.r2.1.grch38 \ 
        #bioconductor-mafdb.gnomad.r2.1.hs37d5
    && conda clean --all -y 

# create user 
RUN useradd -d /drop -ms /bin/bash drop \
    && chmod -R ugo+rwX /drop

# setup bash with conda and locals (language pack)
USER drop:drop
RUN conda init bash \
    && echo -e "\n# activate drop environemnt\nconda activate drop\n" >> ~/.bashrc \
    && echo -e "\n# read/write for group\numask 002\n" >> ~/.bashrc \
    && echo -e "\n# add local language support for CLICK\nexport LC_ALL=en_US.utf8\nexport LANG=en_US.utf8\n" >> ~/.bashrc \
    && mkdir /drop/analysis \
    && chmod -R ugo+rwX /drop
WORKDIR /drop/analysis

# set entry point for image
COPY entry_point.sh /usr/local/bin/entry_point.sh
ENTRYPOINT [ "entry_point.sh" ]
CMD [ "bash" ]

