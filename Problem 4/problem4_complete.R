# Rscript 실행 시 현재 Working Directory와 관계없이 스크립트가 있는 폴더에 결과 저장
args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", args, value = TRUE)
if (length(script_arg) != 1) {
  stop("Run this script using Rscript (see README).")
}
output_dir <- dirname(normalizePath(sub("^--file=", "", script_arg)))
filtered_dir <- file.path(output_dir, "filtered")
dir.create(filtered_dir, recursive = TRUE, showWarnings = FALSE)

# Given code: DADA2 패키지 사용
library(dada2)
rawpath <- system.file("extdata", package = "dada2")
fnFs <- file.path(rawpath, c("sam1F.fastq.gz", "sam2F.fastq.gz"))
fnRs <- file.path(rawpath, c("sam1R.fastq.gz", "sam2R.fastq.gz"))
sample.names <- c("sam1", "sam2")
stopifnot(all(file.exists(c(fnFs, fnRs))))

# Plot quality profiles of forward reads
png(file.path(output_dir, "forward_quality_profiles.png"), width = 1200, height = 700, res = 140)
print(plotQualityProfile(fnFs))
dev.off()

# Plot quality profiles of reverse reads
png(file.path(output_dir, "reverse_quality_profiles.png"), width = 1200, height = 700, res = 140)
print(plotQualityProfile(fnRs))
dev.off()

# filtered FASTQ files의 path 지정 
filtFs <- file.path(filtered_dir, paste0(sample.names, "_F_filt.fastq.gz"))
filtRs <- file.path(filtered_dir, paste0(sample.names, "_R_filt.fastq.gz"))

# Filter and trim함수를 사용하여 paired-end reads 처리
out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs,
                     truncLen = c(230, 160),
                     maxN = 0,
                     maxEE = c(2, 2),
                     truncQ = 2,
                     rm.phix = TRUE,
                     compress = TRUE,
                     multithread = FALSE)

# input and filtered reads의 수 표시
print(out)

# filtered forward reads의 error rate
errF <- learnErrors(filtFs, multithread = FALSE)

# filtered reverse reads의 error rate
errR <- learnErrors(filtRs, multithread = FALSE)

# Visualize error rates
png(file.path(output_dir, "forward_error_rates.png"), width = 1200, height = 800, res = 140)
print(plotErrors(errF, nominalQ = TRUE))
dev.off()
png(file.path(output_dir, "reverse_error_rates.png"), width = 1200, height = 800, res = 140)
print(plotErrors(errR, nominalQ = TRUE))
dev.off()

# filtered forward reads에서 ASV 도출(denoising)
dadaFs <- dada(filtFs, err = errF, multithread = FALSE)

# filtered reverse reads에서 ASV 도출
dadaRs <- dada(filtRs, err = errR, multithread = FALSE)

# denoising 결과 확인 (1이 sam1, 2가 sam2)
print(dadaFs[[1]])
print(dadaRs[[1]])
print(dadaFs[[2]])
print(dadaRs[[2]])

# Merge denoised forward and reverse reads
mergers <- mergePairs(dadaFs, filtFs, dadaRs, filtRs, verbose = TRUE)

# merged results
print(head(mergers[[1]]))

# merged reads에서 ASV table 만들기
seqtab <- makeSequenceTable(mergers)

# ASV table dimension 확인하기
print(dim(seqtab))

# ASV sequence lengths 확인
print(table(nchar(getSequences(seqtab))))

# ASV table에서 chimeric sequences 제거
seqtab.nochim <- removeBimeraDenovo(
  seqtab,
  method = "consensus",
  multithread = FALSE,
  verbose = TRUE
)
# chimera 제거 후 ASV table dimension 확인
print(dim(seqtab.nochim))

# Chimera로 제거된 ASV의 수 계산
print(ncol(seqtab) - ncol(seqtab.nochim))

# Chimera로 제거된 read의 수 계산
print(sum(seqtab) - sum(seqtab.nochim))

# Chimera 제거 후 유지된 read 비율
print(sum(seqtab.nochim) / sum(seqtab))

# read 수 계산
getN <- function(x) sum(getUniques(x))

# 각 step에서의 read 수 계산
track <- cbind(out, sapply(dadaFs, getN),
               sapply(dadaRs, getN),
               sapply(mergers, getN),
               rowSums(seqtab.nochim))
colnames(track) <- c("input", "filtered", "denoisedF",
                     "denoisedR", "merged", "nonchim")
rownames(track) <- sample.names
print(head(track))

# sam1과 sam2의 합도 추가
track.total <- rbind(track, Total = colSums(track))

# 최종 ASV table 표시
print(track.total)
# 각 step에서의 read 수를 정리한 table을 CSV 파일로 저장
write.csv(track.total, file.path(output_dir, "read_tracking.csv"), row.names = TRUE)
# Chimera 제거 후 최종 ASV table을 CSV 파일로 저장
write.csv(seqtab.nochim, file.path(output_dir, "ASV_table.csv"), row.names = TRUE)

# ASV의 총 abundance 계산
asv.abundance <- colSums(seqtab.nochim)

# decreasing=true를 이용하여 내림차순으로 ASV 정렬
asv.abundance <- sort(asv.abundance, decreasing = TRUE)

# 최고 abundance 5개의 ASV만 선별
top5 <- head(asv.abundance, 5)

# abundance 높은 순서대로 차례로 5개 이름 지정
top5.table <- data.frame(
  ASV = paste0("ASV", seq_along(top5)),
  Abundance = as.numeric(top5)
)

# 결과 확인
print(top5.table)
write.csv(top5.table, file.path(output_dir, "top5_ASV_abundance.csv"), row.names = FALSE)

# Load packages
library(DECIPHER)
library(Biostrings)

# 상위 5개 ASV에서 DNA 추출
stopifnot(length(top5) == 5)
top5.seqs <- DNAStringSet(names(top5))

# 서열을 ASV1에서 ASV5로 이름 지정
names(top5.seqs) <- paste0("ASV", 1:5)

# DECIPHER로 5개 ASV 서열을 alignment
alignment <- AlignSeqs(top5.seqs, anchor = NA)

# alignment 결과 표시
print(alignment)

# Load package
library(phangorn)

# 서열을 phyDat으로 바꿈
phang.align <- phyDat(as(alignment, "matrix"), type = "DNA")

# genetic distances 계산
dm <- dist.ml(phang.align)

# Neighbor-Joining tree 만들기
treeNJ <- NJ(dm)

# tree를 Newick format으로 저장
ape::write.tree(treeNJ, file = file.path(output_dir, "top5_ASV_NJ_tree.nwk"))

# PNG image로 저장
png(file.path(output_dir, "top5_ASV_NJ_tree.png"), width = 1200, height = 900, res = 150)
plot(treeNJ, main = "Tree of Top 5 ASVs")
dev.off()
