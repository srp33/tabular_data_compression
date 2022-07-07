FROM python:3.10.2-buster

RUN apt-get update \
 && apt-get install wget -y \
 && python3 -m pip install --upgrade pip \
 && python3 -m pip install fastnumbers==3.2.1 zstandard==0.17.0 bitarray==2.5.1 \
                           python-snappy==0.6.1 lz4==4.0.1

RUN wget https://github.com/samtools/htslib/releases/download/1.15.1/htslib-1.15.1.tar.bz2 \
 && tar -xvf htslib-1.15.1.tar.bz2 \
 && rm htslib-1.15.1.tar.bz2 \
 && cd /htslib-1.15.1 \
 && mkdir /htslib \
 && ./configure --prefix=/htslib \
 && make \
 && make install

ENV PATH=/htslib/bin:$PATH
