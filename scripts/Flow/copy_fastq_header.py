import sys
import gzip

def process_fastq_files(read1_file, read2_umi_file, output_file):
    with gzip.open(read1_file, 'rt') as f1, gzip.open(read2_umi_file, 'rt') as f2, \
         open(output_file, 'w') as out:
        
        while True:
            # Read 4 lines at a time (1 complete FASTQ record)
            r1_lines = [f1.readline().strip() for _ in range(4)]
            r2_lines = [f2.readline().strip() for _ in range(4)]
            
            # Break if we've reached the end of the file
            if not r1_lines[0] or not r2_lines[0]:
                break
            
            # Replace read 1 header with read 2 header
            r1_lines[0] = r2_lines[0]
            
            # Write modified read 1 to output file
            out.write('\n'.join(r1_lines) + '\n')

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <sample_id>")
        sys.exit(1)
    
    sample_id = sys.argv[1]
    read1_file = f"{sample_id}_1.sync.fastq.gz"
    read2_umi_file = f"{sample_id}_2.umi_extracted.fastq.gz"
    output_file = f"{sample_id}_1.umi_extracted.fastq"
    
    process_fastq_files(read1_file, read2_umi_file, output_file)
