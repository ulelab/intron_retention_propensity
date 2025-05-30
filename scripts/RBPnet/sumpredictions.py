# summarize_rbpnet_predictions.py

def extract_id(header_line):
    return header_line.split()[0]

def process_block(lines):
    header = extract_id(lines[0])
    profile = list(map(float, lines[2].strip().split()))
    
    first_75 = sum(profile[:75])
    middle = sum(profile[75:-75])
    last_75 = sum(profile[-75:])
     
    return f"{header}\t{first_75:.6f}\t{middle:.6f}\t{last_75:.6f}"

def main():
    input_file = "predtrim.tsv"
    output_file = "pred_sums.tsv"

    with open(input_file, "r") as infile, open(output_file, "w") as outfile:
        lines = []
        for line in infile:
            if line.strip() == "":
                continue
            lines.append(line)
            if len(lines) == 6:
                result = process_block(lines)
                outfile.write(result + "\n")
                lines = []

if __name__ == "__main__":
    main()
