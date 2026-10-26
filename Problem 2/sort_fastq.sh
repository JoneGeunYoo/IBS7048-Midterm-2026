
#!/bin/bash

mkdir -p sorted_bash/{Treated,Control}/{R1,R2}

for file in raw/*.fastq
do
    filename=$(basename "$file")
    condition=$(echo "$filename" | cut -d'_' -f2)
    read=$(echo "$filename" | cut -d'_' -f4 | cut -d'.' -f1)

    cp "$file" "sorted_bash/$condition/$read/"
done

