FROM ubuntu:16.04
LABEL author="Adam Ewing <adam.ewing@gmail.com>"

WORKDIR /opt
ENV PATH=$PATH:$HOME/bin
ARG DEBIAN_FRONTEND=noninteractive
RUN chmod 777 /opt

#install the bareminimum and remove the cache
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-dev \
    python3-numpy \
    python3-scipy \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    cython \
    zlib1g-dev \
    libbz2-dev \
    libncurses5-dev \
    liblzma-dev \
    libglib2.0-dev \
    git \
    wget \
    bzip2 \
    pkg-config \
    automake \
    autoconf \
    gcc \
    g++ \
    make \
    default-jre

RUN rm -rf /var/lib/apt/lists/* && apt-get autoremove

ENV VELVET_VERSION 1.2.10
ENV PICARD_VERSION 2.21.2
ENV BWA_VERSION 0.7.17
ENV SAMTOOLS_VERSION 1.9
ENV BCFTOOLS_VERSION 1.9

####################### VELVET #######################
RUN wget https://github.com/dzerbino/velvet/archive/refs/tags/v${VELVET_VERSION}.tar.gz \
    && tar -xvzf v${VELVET_VERSION}.tar.gz \
    && make -C velvet-${VELVET_VERSION}

ENV PATH=/opt/velvet-${VELVET_VERSION}:$PATH

##################### EXONERATE #####################
RUN git clone https://github.com/adamewing/exonerate.git \
    && cd exonerate \
    && autoreconf -fi \
    && ./configure \
    && make \
    && make install

###################### SAMTOOLS ######################
RUN wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && tar -xjf samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && rm -f samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && cd /opt/samtools-${SAMTOOLS_VERSION}/ \
    && make \
    && make install

ENV PATH="/opt/samtools-${SAMTOOLS_VERSION}/:$PATH"

###################### BCFTOOLS ######################
RUN wget https://github.com/samtools/bcftools/releases/download/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
    && tar -xjf bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
    && rm -f bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
    && cd /opt/bcftools-${BCFTOOLS_VERSION}/ \
    && make \
    && make install

ENV PATH="/opt/samtools-${BCFTOOLS_VERSION}/:$PATH"

######################## BWA ########################
RUN wget https://github.com/lh3/bwa/releases/download/v${BWA_VERSION}/bwa-${BWA_VERSION}.tar.bz2 \
    && tar -xjf bwa-${BWA_VERSION}.tar.bz2 \
    && rm -f bwa-${BWA_VERSION}.tar.bz2 \
    && cd /opt/bwa-${BWA_VERSION}/ \
    && make

ENV PATH="/opt/bwa-${BWA_VERSION}/:$PATH"

#################### BAMSURGEON ####################
#we really need that version and nothing more, because of backwards compatibility
RUN pip3 install pysam==0.12.0

# Use current code in docker in case local changes were made
COPY . /opt/bamsurgeon

###################### PICARD ######################
RUN wget -O /opt/picard.jar https://github.com/broadinstitute/picard/releases/download/${PICARD_VERSION}/picard.jar

ENV BAMSURGEON_PICARD_JAR=/opt/picard.jar

RUN chmod -R o+rx /opt

CMD []
