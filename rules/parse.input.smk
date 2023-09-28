import glob
import os

def get_files(fastq_input):
    # If it's a directory, get all .fastq or .fastq.gz files
    if os.path.isdir(fastq_input):
        fastq_files = glob.glob(os.path.join(fastq_input, "*.fastq"))
        fastq_gz_files = glob.glob(os.path.join(fastq_input, "*.fastq.gz"))
        return [fastq_files, fastq_gz_files]
    
    # If it's a file, check if it's a fofn
    elif os.path.isfile(fastq_input):
        with open(fastq_input, 'r') as f:
            # Check the first line; if it looks like a path, assume it's a fofn
            first_line = f.readline().strip()
            if os.path.isfile(first_line):
                all_lines = [first_line]
                all_lines += [line.strip() for line in f if os.path.isfile(line.strip())]
                return all_lines
            # If not a fofn, assume it's a single file input
            else:
                return [fastq_input]
    else:
        print(fastq_input)
        raise ValueError(f"Invalid path specified: {fastq_input}")
        
        
