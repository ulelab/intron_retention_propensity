import pyfaidx
import sys

def reverse_complement(seq):
    complement = str.maketrans("ACGTacgtNn", "TGCAtgcaNn")
    return seq.translate(complement)[::-1]

def bed_to_fasta(bed_file, fasta_file, output_file):
    genome = pyfaidx.Fasta(fasta_file)

    with open(bed_file, 'r') as bed, open(output_file, 'w') as out:
        for line in bed:
            if line.startswith('#') or not line.strip():
                continue  # skip comments or empty lines

            fields = line.strip().split('\t')
            chrom = fields[0]
            start = int(fields[1])
            end = int(fields[2])
            name_in_bed = fields[3] if len(fields) >= 4 else f"{chrom}:{start}-{end}"
            strand = fields[5] if len(fields) >= 6 else '+'

            # Build header: gene::chr:start-end(strand)
            header = f"{name_in_bed}::chr{chrom}:{start}-{end}({strand})"

            seq = genome[chrom][start:end].seq

            if strand == '-':
                seq = reverse_complement(seq)

            out.write(f">{header}\n{seq}\n")

    genome.close()

if __name__ == '__main__':
    # usage: python extract_fasta_rbpnet.py introns50ens.bed genome.fa output.fa
    bed_to_fasta(sys.argv[1], sys.argv[2], sys.argv[3])

