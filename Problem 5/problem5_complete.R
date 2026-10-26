# Given data
condition <- c("Untreated", "Treated")
total_reads <- c(20000000, 20000000)
host_fraction <- c(0.99, 0.90)
taxon_X_fraction <- c(0.10, 0.91)

# microbial reads(전체 - host = microbiome)
microbial_reads <- total_reads * (1 - host_fraction)

# reads remaining after excluding Taxon_X
remaining_reads <- microbial_reads * (1 - taxon_X_fraction)

# fold change (Treated / Untreated)
microbial_FC <- microbial_reads[2] / microbial_reads[1]
remaining_FC <- remaining_reads[2] / remaining_reads[1]

# result table
result <- data.frame(
  condition,
  microbial_reads,
  remaining_reads
)

print(result)

cat("Microbial reads fold change:", microbial_FC, "\n")

cat("Remaining reads fold change:", remaining_FC, "\n")
