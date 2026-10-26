# "raw" directory에서 .fastq로 끝나는 파일을 list화
files <- list.files("raw", pattern = "\\.fastq$")

# folder 생성 후 FASTQ files 복사. Bash의 for 구문과 동일하게 {}내 처리하도록 반복문
for (file in files) {
  parts <- strsplit(file, "_")[[1]]  # _를 기준으로 문자열 파일이름을 구분
  condition <- parts[2]  # 파일이름의 2번째 요소인 condition을 추출
  read <- sub("\\.fastq$", "", parts[4])  # 확장자인 .fastq를 제거하고 read를 추출
  dest_dir <- file.path("sorted_R", condition, read)  # 파일을 저장할 경로를 설정
  dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)  # 폴더를 생성
  file.copy(file.path("raw", file),
            file.path(dest_dir, file))  # raw 원본을 sorted_R 복사본으로 복사
}

# sorted_R에 있는 파일 목록 출력
print(list.files("sorted_R", recursive = TRUE))

# 총 파일 개수 출력
print(length(list.files("sorted_R", recursive = TRUE)))	

# Bash와 R 코드 비교 확인 검증
# Bash와 R의 전체 정렬 파일 목록 출력
print(sort(list.files("sorted_R", recursive = TRUE, full.names = TRUE)))

# 위 2가지 코드의 결과 파일 목록을 지정
bash_files <- sort(list.files("sorted_bash", recursive = TRUE))
r_files <- sort(list.files("sorted_R", recursive = TRUE))

# Bash 코드의 파일 개수 출력
cat("Bash file count:", length(bash_files), "\n")

# R 코드의 파일 개수 출력
cat("R file count:", length(r_files), "\n")

# 2가지 코드 결과의 파일명과 상대경로가 동일한지 확인
cat("Same filenames:", identical(bash_files, r_files), "\n")
