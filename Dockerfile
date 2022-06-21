FROM python:3.10.2-buster

RUN python3 -m pip install --upgrade pip \
 && python3 -m pip install fastnumbers==3.2.1 zstandard==0.17.0 bitarray==2.5.1 \
                           python-snappy==0.6.1 lz4==4.0.1
