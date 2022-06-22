#! /bin/bash

set -o errexit

#######################################################
# Build the Docker image
#######################################################

docker_image="srp33/tabular_data_compression"
docker build -t "${docker_image}" .

#######################################################
# Specify Docker command prefix
#######################################################

# This command is executed interactively
dockerCommand="docker run -i -t --rm --user $(id -u):$(id -g) -v $(pwd):/sandbox -v $(pwd)/data:/data -v /tmp:/tmp --workdir=/sandbox ${docker_image}"

# This command is executed in the background (detached)
#dockerCommand="docker run --rm --user $(id -u):$(id -g) -v $(pwd):/sandbox -v $(pwd)/data:/data -v /tmp:/tmp --workdir=/sandbox ${docker_image}"

#######################################################
# Download and decompress GTF file
# Create a compressed version with bgzip
#######################################################

if [ ! -f data/gencode.v40.gtf.bgz ]
then
  $dockerCommand bash -c "cd data; wget -O gencode.v40.gtf.gz https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_40/gencode.v40.chr_patch_hapl_scaff.basic.annotation.gtf.gz"
  $dockerCommand bash -c "cd data; gunzip -f gencode.v40.gtf.gz"
  $dockerCommand bash -c "cd data; bgzip < gencode.v40.gtf > gencode.v40.gtf.bgz"
fi

#######################################################
# Create medium-sized test file
#######################################################

if [ ! -f data/medium.tsv ]
then
  $dockerCommand bash -c "time python3 BuildTsv.py 2 2 1000 data/medium.tsv"
fi

#######################################################
# Create large test files (tall and wide)
#######################################################

if [ ! -f data/wide.tsv ]
then
  $dockerCommand bash -c "time python3 BuildTsv.py 100 900 1000000 data/tall.tsv"
  $dockerCommand bash -c "time python3 BuildTsv.py 100000 900000 1000 data/wide.tsv"
fi

#######################################################
# Build compressed files
#######################################################

#TODO: Add ability to record time, disk space used
#        See /Analysis/Tabular_File_Benchmark/test.sh
#TODO: Use tabix to build index and then query GTF.bgz file
#TODO: Modify the code below to focus on GTF file. Later, we can do stuff with the small/medium/large files.

mkdir -p compressed_data

#$dockerCommand python3 CompressFiles.py small gzip 1
#$dockerCommand python3 CompressFiles.py small gzip 5
#$dockerCommand python3 CompressFiles.py small gzip 9
#$dockerCommand python3 CompressFiles.py small bz2 1
#$dockerCommand python3 CompressFiles.py small bz2 5
#$dockerCommand python3 CompressFiles.py small bz2 9
#$dockerCommand python3 CompressFiles.py small lzma 0
#$dockerCommand python3 CompressFiles.py small snappy 0
#$dockerCommand python3 CompressFiles.py small zstd 1
#$dockerCommand python3 CompressFiles.py small zstd 5
#$dockerCommand python3 CompressFiles.py small zstd 9
#$dockerCommand python3 CompressFiles.py small lz4 1
#$dockerCommand python3 CompressFiles.py small lz4 5
#$dockerCommand python3 CompressFiles.py small lz4 9

#######################################################
# Run query tests
#######################################################


