#!/bin/bash -l

while read accession; do
    prefetch "$accession" &
done < accession.txt

wait