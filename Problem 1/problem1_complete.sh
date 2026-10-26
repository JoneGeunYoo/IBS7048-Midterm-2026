#!/bin/bash
set -e

# raw 디렉터리를 생성하고, Problem 2에서도 사용할 원본 FASTQ 파일을 보관
mkdir -p IBS7048_2026/raw
cd IBS7048_2026

# Sample(5개), Condition(2개), Replicate(2개), Read direction(2개)의 조합으로 총 40개의 dummy FASTQ 파일 생성
for sample in S01 S02 S03 S04 S05
do
  for condition in Treated Control
  do
    for rep in 1 2
    do
      for read in R1 R2
      do
        file="${sample}_${condition}_${rep}_${read}.fastq"
        printf '@%s\nACGTACGTACGT\n+\nFFFFFFFFFFFF\n' \
          "$file" > "raw/$file"
      done
    done
  done
done

# 현재 작업 directory 경로 확인
pwd

# raw directory에서 wc(word count)를 통해 대상 파일의 개수 확인
find raw -type f | wc -l

# sorted_bash 내부에 Condition(Treated, Control)과 Read direction(R1, R2)에 따른 4개의 하위 directory 생성
mkdir -p sorted_bash/{Treated,Control}/{R1,R2}

# raw directory의 모든 FASTQ 파일을 하나씩 처리
for file in raw/*.fastq
do
    # raw 디렉터리에서 파일명만 추출
    filename=$(basename "$file")

    # 파일명을 '_' 기준으로 구분하여 두 번째 필드인 Condition(Treated, Control)을 추출
    condition=$(echo "$filename" | cut -d'_' -f2)

    # 네 번째 필드에서 확장자를 제거하여 Read direction(R1 또는 R2)을 추출
    read=$(echo "$filename" | cut -d'_' -f4 | cut -d'.' -f1)

    # 추출한 Condition과 Read direction에 해당하는 디렉터리로 FASTQ 파일을 복사 (raw 원본 유지)
    cp "$file" "sorted_bash/$condition/$read/"
done

# sorted_bash directory 내 총 FASTQ 파일 개수 확인
find sorted_bash -type f | wc -l

# sorted_bash directory 내부의 4가지 Condition/Read direction 조합을 반복하여 각 directory의 파일 수를 echo로 출력
for dir in sorted_bash/{Treated,Control}/{R1,R2}
do
    echo "$dir: $(find "$dir" -type f | wc -l) files"
done

# 총 40개의 파일명을 sort로 정렬하여 육안으로 분류 결과 확인
find sorted_bash -type f | sort

