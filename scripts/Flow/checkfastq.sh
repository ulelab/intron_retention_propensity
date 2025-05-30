#!/bin/bash -l

# Function to check FASTQ file
check_fastq() {
    local file=$1
    local total_lines=$(wc -l < "$file")
    local records=$((total_lines / 4))

    echo "Checking file: $file"
    echo "Total lines: $total_lines"
    echo "Number of records: $records"

    # Check if the number of lines is divisible by 4
    if [ $((total_lines % 4)) -ne 0 ]; then
        echo "ERROR: Number of lines is not divisible by 4. File may be corrupted."
        return 1
    fi

    # Check the first character of every 4th line (should be @)
    if ! awk 'NR % 4 == 1 {if (substr($0,1,1) != "@") {exit 1}}' "$file"; then
        echo "ERROR: Not all sequence identifiers start with @. File may be corrupted."
        return 1
    fi

    # Check the first character of every 4th+2 line (should be +)
    if ! awk 'NR % 4 == 3 {if (substr($0,1,1) != "+") {exit 1}}' "$file"; then
        echo "ERROR: Not all quality score identifiers start with +. File may be corrupted."
        return 1
    fi

    echo "File appears to be a valid FASTQ file."
    return 0
}

# Main script
for file in *.fastq; do
    if [ -f "$file" ]; then
        check_fastq "$file"
        echo "-------------------"
    fi
done

echo "All checks completed."
