input_file="introns.bed"
output_file="Wide_Canonical_splice_sites.bed"

awk 'BEGIN{OFS="\t"}
{
    chr=$1
    start=$2
    end=$3
    name=$4
    strand=$6

    if (strand == "+") {
        splice_site = start
    } else if (strand == "-") {
        splice_site = end
    } else {
        next  # skip if strand is not defined
    }

    new_start = splice_site - 50
    new_end = splice_site + 50

    if (new_start < 0) new_start = 0  # prevent negative coords

    print chr, new_start, new_end, name, 1, strand
}' "$input_file" > "$output_file"
