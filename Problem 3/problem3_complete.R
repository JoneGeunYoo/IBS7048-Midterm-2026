
# Problem 3: Sequencing platform comparison

# Given code
sequencing <- data.frame(
  platform = c("Illumina", "Oxford Nanopore", "PacBio HiFi"),
  yield_Gb = c(18, 30, 12),
  host_fraction = c(0.20, 0.70, 0.10),
  cost_USD = c(150, 200, 300)
)
budget <- 600

# Floor 함수로 소수점 아래 버리고 제한된 예산으로 처리 가능한 샘플 수 계산
sequencing$n_samples <- floor(budget / sequencing$cost_USD)

# 다음 계산식을 통해서 샘플당 microbial Gb 계산
sequencing$microbial_Gb_per_sample <- sequencing$yield_Gb * (1 - sequencing$host_fraction)

# 다음 계산식을 통해서 Total microbial Gb 계산
sequencing$total_microbial_Gb <- sequencing$n_samples * sequencing$microbial_Gb_per_sample

# 각 platform별로 계산 결과 출력
print(sequencing)

# Total microbial Gb가 가장 큰 플랫폼의 이름을 출력
print(sequencing$platform[which.max(sequencing$total_microbial_Gb)])

