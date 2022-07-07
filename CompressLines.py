import gzip
import sys

file_name = sys.argv[1]
compression_type = sys.argv[2]
compression_level = int(sys.argv[3])

tsv_file_path = f"data/{file_name}"
cmpr_file_path = f"compressed_data/{file_name}.{compression_type}.{compression_level}"

if compression_type == "gzip_lines":
    import gzip as cmpr
    compression_code = f"cmpr.compress(line, compresslevel={compression_level})"
elif compression_type == "bz2_lines":
    import bz2 as cmpr
    compression_code = f"cmpr.compress(line, compresslevel={compression_level})"
elif compression_type == "lzma_lines":
    import lzma as cmpr
    compression_code = "cmpr.compress(line)"
elif compression_type == "snappy_lines":
    import snappy as cmpr
    compression_code = "cmpr.compress(line)"
elif compression_type == "zstd_lines":
    # See https://pypi.org/project/zstandard
    import zstandard
    cmpr = zstandard.ZstdCompressor(level=int(compression_level))
    compression_code = "cmpr.compress(line)"
elif compression_type == "lz4_lines":
    # See https://python-lz4.readthedocs.io/en/stable/quickstart.html#simple-usage
    import lz4.frame as cmpr
    compression_code = f"cmpr.compress(line, compression_level={compression_level})"
else:
    print(f"No matching compression type: {compression_type}")
    sys.exit(1)

with open(tsv_file_path, "rb") as tsv_file:
    with open(cmpr_file_path, "wb") as cmpr_file:
        for line in tsv_file:
            line = line.rstrip(b"\n")

            compressed_line = eval(compression_code)

            cmpr_file.write(compressed_line)
