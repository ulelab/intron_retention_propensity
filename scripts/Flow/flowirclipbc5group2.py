import requests # type: ignore
import getpass

PROJECT_ID = "677924933669785575"
PREP_EXECUTION_ID = "369697880705125688"
PIPELINE_ID = "960154035051242353"
VERSION = "1.4"

# Authenticate
username = input("Enter your username: ")
password = getpass.getpass("Enter your password: ")
response = requests.post("https://api.flow.bio/login", json={"username": username, "password": password})
data = response.json()
if "token" not in data:
    raise Exception("Invalid username or password")
token = data["token"]

# Get samples
import csv

# Load sample names with barcodes AAGTC or ACTGA
valid_sample_names = set()
allowed_barcodes = {"AAGTC", "ACTGA"}

with open("irCLIP.tsv", "r") as f:
    reader = csv.DictReader(f, delimiter="\t")
    for row in reader:
        barcode = row["5' Barcode Sequence"].strip()
        if barcode in allowed_barcodes:
            valid_sample_names.add(row["Sample Name"].strip())

# Fetch samples from FlowBio and filter by valid names
samples = []
for page in range(1, 4):  # Pages 1, 2, 3
    print(f"Fetching page {page}")
    response = requests.get(
        f"https://api.flow.bio/projects/{PROJECT_ID}/samples?page={page}&count=100",
        headers={"Authorization": f"Bearer {token}"},
        timeout=30
    )
    data = response.json()
    if "samples" not in data:
        raise Exception(f"Failed to fetch page {page}: {data}")
    
    # Filter by barcode-matching names
    for s in data["samples"]:
        if s["name"] in valid_sample_names:
            samples.append({
                "id": s["id"],
                "name": s["name"],
                "group": s["name"],
                "replicate": "1"
            })

print(f"\nFiltered {len(samples)} samples:")
for s in samples:
    print(f"  {s['id']}: {s['name']}")

# Get pipeline version ID
response = requests.get(
    f"https://api.flow.bio/pipelines/{PIPELINE_ID}",
    headers={"Authorization": f"Bearer {token}"}
)
pipeline = response.json()
version_match = next((v for v in pipeline["versions"] if v["name"] == VERSION), None)
if not version_match:
    raise Exception(f"Version {VERSION} not found")
version_id = version_match["id"]

# Get prep execution inputs
response = requests.get(
    f"https://api.flow.bio/executions/{PREP_EXECUTION_ID}",
    headers={"Authorization": f"Bearer {token}"}
)
ex = response.json()
inputs = list(ex["data_params"].values())
all_files = inputs[:]
for proc_ex in ex["process_executions"]:
    all_files.extend(proc_ex["downstream_data"])

# Define desired files
print("\nGenome inputs:")
file_map = {
    "fasta": "Homo_sapiens.GRCh38.fasta",
    "gtf": "Homo_sapiens.GRCh38.109.gtf",
    "smrna_fasta": "Homo_sapiens.GRCh38.smrna.fasta",
    "fasta_fai": "Homo_sapiens.GRCh38.fasta.fai",
    "chrom_sizes": "Homo_sapiens.GRCh38.fasta.sizes",
    "target_genome_index": "star",
    "smrna_genome_index": "bowtie",
    "smrna_fasta_fai": "Homo_sapiens.GRCh38.smrna.fasta.fai",
    "smrna_chrom_sizes": "Homo_sapiens.GRCh38.smrna.fasta.sizes",
    "longest_transcript": "longest_transcript.txt",
    "longest_transcript_fai": "longest_transcript.fai",
    "longest_transcript_gtf": "longest_transcript.gtf",
    "filtered_gtf": "Homo_sapiens_filtered.gtf",
    "seg_gtf": "Homo_sapiens_seg.gtf",
    "seg_filt_gtf": "Homo_sapiens_filtered_seg.gtf",
    "seg_resolved_gtf": "Homo_sapiens_filtered_seg_genicOtherfalse.resolved.gtf",
    "seg_resolved_gtf_genic": "Homo_sapiens_filtered_seg_genicOthertrue.resolved.gtf",
    "regions_gtf": "Homo_sapiens_regions.gtf.gz",
    "regions_filt_gtf": "Homo_sapiens_filtered_regions.gtf.gz",
    "regions_resolved_gtf": "Homo_sapiens_filtered_regions_genicOtherfalse.resolved.gtf",
    "regions_resolved_gtf_genic": "Homo_sapiens_filtered_regions_genicOthertrue.resolved.gtf",
}

data_params = {}
for param_name, expected_filename in file_map.items():
    match = next((f for f in all_files if f["filename"] == expected_filename), None)
    if not match:
        raise Exception(f"File not found for parameter '{param_name}': {expected_filename}")
    data_params[param_name] = match["id"]
    print(f"  {param_name}: {match['filename']}")

# Prepare pipeline input
data = {
    "params": {
        "move_umi_to_header": "true",
        "umi_header_format": "NNNNN",
        "umi_separator": "_",
        "skip_umi_dedupe": "false",
        "crosslink_position": "start"
    },
    "data_params": data_params,
    "csv_params": {
        "samplesheet": {
            "rows": [{
                "sample": s["id"],
                "values": {
                    "group": s["group"],
                    "replicate": s["replicate"]
                }
            } for s in samples],
            "paired": "both",
        }
    },
    "retries": None,
    "nextflow_version": "23.04.3",
    "fileset": ex["fileset"]["id"],
    "resequence_samples": False
}

proceed = input("\nSubmit? (y/n): ")
if proceed != "y":
    exit()

# Submit job
response = requests.post(
    f"https://api.flow.bio/pipelines/versions/{version_id}/run",
    headers={"Authorization": f"Bearer {token}"},
    json=data
)
run_id = response.json()["id"]
print(f"https://app.flow.bio/executions/{run_id}")
