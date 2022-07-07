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

#mkdir -p compressed_data

if [ ! -f data/gencode.v40.gtf ]
then
  $dockerCommand bash -c "cd data; wget -O gencode.v40.gtf.gz https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_40/gencode.v40.chr_patch_hapl_scaff.basic.annotation.gtf.gz"
  $dockerCommand bash -c "cd data; gunzip -f gencode.v40.gtf.gz"
fi

#######################################################
# Build compressed files
#######################################################

function doCompression {
  dataset=$1
  compression_scheme=$2
  compression_level=$3
  cmd=$4

  elapsed_seconds=$($dockerCommand python3 TimeCommand.py "${cmd}")

  compressed_file_path=compressed_data/${dataset}.${compression_scheme}.${compression_level}

  total_bytes=$(python3 PrintFilesSize.py ${compressed_file_path})

  echo -e "${dataset}\t${compression_scheme}\t${compression_level}\t${elapsed_seconds}\t${total_bytes}"
}

mkdir -p results

resultFile=results/Compression.tsv

#if [ ! -f compressed_data/gencode.v40.gtf.lz4.9 ]
#then
  dataset=gencode.v40.gtf

  echo -e "Dataset\tCompression_Scheme\tCompression_Level\tElapsed_Seconds\tTotal_Bytes" > $resultFile

  doCompression $dataset bgz 1 "cd data;bgzip --compress-level 1  < ${dataset} > ../compressed_data/${dataset}.bgz.1" >> $resultFile
  doCompression $dataset bgz 5 "cd data;bgzip --compress-level 5  < ${dataset} > ../compressed_data/${dataset}.bgz.5" >> $resultFile
  doCompression $dataset bgz 9 "cd data;bgzip --compress-level 9  < ${dataset} > ../compressed_data/${dataset}.bgz.9" >> $resultFile

  doCompression $dataset gz 1 "cd data;gzip -1  < ${dataset} > ../compressed_data/${dataset}.gz.1" >> $resultFile
  doCompression $dataset gz 5 "cd data;gzip -5  < ${dataset} > ../compressed_data/${dataset}.gz.5" >> $resultFile
  doCompression $dataset gz 9 "cd data;gzip -9  < ${dataset} > ../compressed_data/${dataset}.gz.9" >> $resultFile

#TODO: Figure out why the files are so much larger when compressing by line.
#        Try a gradient of larger (and smaller?) sized blocks and see if that is the key difference.
#        Understand more about how gzip works.
#          https://www.youtube.com/watch?v=OtDxDvCpPL4 (high level intro)
#          https://www.youtube.com/watch?v=ZEQRz7BmGtA (longer, probably useful)
#          https://www.youtube.com/watch?v=wLx5OGxOYUc (might be useful, some irrelevant details toward the end)
#          https://www.youtube.com/watch?v=M5c_RFKVkko (entropy - what's the theoretical best you can do)
#          https://www.youtube.com/watch?v=goOa3DGezUA (it's okay)
#          https://www.youtube.com/watch?v=oi2lMBBjQ8s (long, not sure what background knowledge is expected)
#          https://datatracker.ietf.org/doc/html/rfc1950 (official specification for zlib)
#          https://datatracker.ietf.org/doc/html/rfc1951 (official specification for deflate)
#          https://datatracker.ietf.org/doc/html/rfc1952 (official specification for gzip)
#      Try https://pypi.org/project/zopfli/
#      Try it for zstd using a training dictionary.

  # These lines compress the files one line at a time.
#  doCompression $dataset gzip_lines 1 "python3 CompressLines.py ${dataset} gzip_lines 1" >> $resultFile
#  doCompression $dataset gzip_lines 5 "python3 CompressLines.py ${dataset} gzip_lines 5" >> $resultFile
#  doCompression $dataset gzip_lines 9 "python3 CompressLines.py ${dataset} gzip_lines 9" >> $resultFile

  #$dockerCommand python3 CompressLines.py ${dataset} bz2_lines 1
  #$dockerCommand python3 CompressLines.py ${dataset} bz2_lines 5
  #$dockerCommand python3 CompressLines.py ${dataset} bz2_lines 9
  #$dockerCommand python3 CompressLines.py ${dataset} lzma_lines 0
  #$dockerCommand python3 CompressLines.py ${dataset} snappy_lines 0
  #$dockerCommand python3 CompressLines.py ${dataset} zstd_lines 1
  #$dockerCommand python3 CompressLines.py ${dataset} zstd_lines 5
  #$dockerCommand python3 CompressLines.py ${dataset} zstd_lines 9
  #$dockerCommand python3 CompressLines.py ${dataset} lz4_lines 1
  #$dockerCommand python3 CompressLines.py ${dataset} lz4_lines 5
  #$dockerCommand python3 CompressLines.py ${dataset} lz4_lines 9
#fi

#TODO: Use tabix to build index
#TODO: Build CSI index (alternative to tabix)
#TODO: Evaluate benefits gained from parallelization?
#TODO: Compare against GPresss? https://academic.oup.com/bioinformatics/article/36/18/4810/5865850

#######################################################
# Run query tests
#######################################################









#######################################################
# Create medium-sized test file
#######################################################

#if [ ! -f data/medium.tsv ]
#then
#  $dockerCommand bash -c "time python3 BuildTsv.py 2 2 1000 data/medium.tsv"
#fi

#######################################################
# Create large test files (tall and wide)
#######################################################

#if [ ! -f data/wide.tsv ]
#then
#  $dockerCommand bash -c "time python3 BuildTsv.py 100 900 1000000 data/tall.tsv"
#  $dockerCommand bash -c "time python3 BuildTsv.py 100000 900000 1000 data/wide.tsv"
#fi
