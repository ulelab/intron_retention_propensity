import sys
import csv
import os
import flowbio

# --- Handle arguments ---
if len(sys.argv) != 4:
    print("Usage: python upload_samples.py <csv_file> <start_row> <end_row>")
    sys.exit(1)

csv_file = sys.argv[1]
start_row = int(sys.argv[2])
end_row = int(sys.argv[3])

# --- Login ---
client = flowbio.Client()
client.login("Chromojones", "Yamanaka2007!iPSC")

# --- Read CSV and upload samples ---
with open(csv_file, newline='') as f:
    reader = csv.DictReader(f, delimiter='\t')
    rows = list(reader)[start_row - 1:end_row]

    for row in rows:
        sample_name = row["Sample Name"]
        file_path = os.path.expanduser(f"/scratch/prj/ppn_rnp_networks/users/mike.jones/data/flash/fastq/{row['File']}")
        metadata = {
            "category": "CLIP",
            "project": row["Project Name"],
            "pi": row["PI"],
            "scientist": row["Scientist"],
            "organisation": row["Organisation"],
            "purification_agent": row["Purification Agent"],
            "experimental_method": row["Experimental Method"],
            "condition": row["Condition"],
            "sequencer": row["Sequencer"],
            "five_prime_barcode_sequence": row["5' Barcode Sequence"],
            "three_prime_barcode_sequence": row["3' Barcode Sequence"],
            "geo": row["GEO ID"],
            "ena": row["ENA ID"],
            "pubmed": row["PubMed ID"],
            "sample_type": row["Type"],
            "source": row["Cell or Tissue"],
            "organism": row["Organism"],
            "purification_target_text": row["Protein (Purification Target)"],
        }

        sample = client.upload_sample(
            sample_name,
            file_path,
            progress=True,
            metadata={k: v for k, v in metadata.items() if v}
        )
        print(sample)

