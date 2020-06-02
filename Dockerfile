# base image
FROM conda/miniconda3-centos7

# build it with
# docker build . --no-cache --network=host --tag mertes/drop:latest --tag mertes/drop

# update and setup system
RUN yum update -y \
    && yum install -y which bc less wget vim \
    && yum clean all \
    && conda update -n base -c defaults conda

# init drop env
COPY environment.yml /tmp/
RUN conda env create -f /tmp/environment.yml \
    && conda clean --all -y

# taken from: https://pythonspeed.com/articles/activate-conda-dockerfile/
# Make RUN commands use the new environment:
SHELL ["conda", "run", "-n", "drop-docker", "/bin/bash", "-c"]

# install tMAE
RUN R -e "BiocManager::install(\"mumichae/tMAE\", ask=FALSE, update=FALSE, dependencies=FALSE)" \
    && R -e "BiocManager::install(\"c-mertes/FRASER\", ask=FALSE, update=FALSE, depndencies=FALSE)"

# tweak drop to work on root
SHELL [ "bash", "-c" ]
RUN sed 's/tar -zx/tar --no-same-owner -zx/' -i /usr/local/envs/drop-docker/lib/python3.7/site-packages/drop/download_data.sh \
    && conda init bash \
    && echo -e "\n# activate drop environemnt\nconda activate drop-docker\n" >> ~/.bashrc \
    && echo -e "\n# read/write for group\numask 002\n" >> ~/.bashrc

# install bcftools
RUN yum install -y autoconf git vim
SHELL ["conda", "run", "-n", "drop-docker", "/bin/bash", "-c"]
RUN export CC=x86_64-conda_cos6-linux-gnu-gcc \
    && git clone git://github.com/samtools/bcftools.git \
    && git clone git://github.com/samtools/htslib.git \
    && cd htslib \
        && autoheader \
        && autoconf \
        && ./configure --prefix=/usr/local/envs/drop-docker/ \
    && cd ../bcftools \
        && autoheader \
        && autoconf \
        && ./configure --prefix=/usr/local/envs/drop-docker/ \
        && make -j 4 \
        && make install

# problem with wbuild/drop?
RUN sed -re 's/(self.path=os.path.abspath.self.path)/\1[0]/' -i /usr/local/envs/drop-docker/lib/python3.7/site-packages/wbuild/utils.py

WORKDIR /drop
COPY entry_point.sh /usr/local/bin/entry_point.sh
ENTRYPOINT [ "entry_point.sh" ]
CMD [ "bash" ]



#CMD [ "conda", "run", "-n", "drop-docker" ]

# init user space
# entry point to enable conda env on the fly
#SHELL [ "bash", "-c" ]
#RUN groupadd -g 1000 drop \
#    && useradd -u 1000 -g 1000 drop
# COPY entry_point.sh /usr/local/bin/
#COPY entry_point_plain.sh /usr/local/bin/entry_point.sh
#RUN sed 's/^if . shopt -q.*/if [ "true" == "true" ] ; then # always on ;)/' -i /etc/bashrc

#USER drop:drop
#RUN echo "conda activate drop-docker" >> ~/.bashrc

#SHELL [ "bash", "--rcfile", "/etc/bashrc_init", "-c" ]
#ENTRYPOINT [ "entry_point.sh" ]
#CMD [ "bash" ]

#SHELL [ "bash", "-c" ]
#ENTRYPOINT [ "bash", "--rcfile" "/etc/bashrc_init", "-c" ]
#CMD [ "bash" ]
#COPY conda.sh /etc/profile.d/
#COPY conda.sh /etc/bashrc_init
#RUN { echo -e "if [ -f /etc/bashrc ]; then \n  . /etc/bashrc\nfi"; cat /etc/bashrc_init; } >> /etc/bashrc_init_tmp && mv /etc/bashrc_init_tmp /etc/bashrc_init
# RUN conda init

