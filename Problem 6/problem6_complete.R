# Given values
score <- c(0.20, 0.60)
OR <- c(estimate = 0.47, lower = 0.22, upper = 0.97)
CASI <- c(estimate = -0.92, lower = -1.51, upper = -0.33)
p0 <- 0.40

# microbiome score 차이(delta)
delta_score <- score[2] - score[1]

# delta_score의 Odds ratio and 95% CI
new_OR <- OR ^ delta_score

# CASI 변화량 CI
new_CASI <- CASI * delta_score

# 초기 확률 p0을 odds로 변환
odds0 <- p0 / (1 - p0)

# 바뀐 odds(odds1), probability(p1) 계산
odds1 <- odds0 * new_OR["estimate"]
p1 <- odds1 / (1 + odds1)

# results
cat("Score difference:", delta_score, "\n")

# 실수 소수점 이하 3자리까지 포함해서 OR 표시
cat("OR =", round(new_OR["estimate"], 3),
    "(95% CI:", round(new_OR["lower"], 3),
    "-", round(new_OR["upper"], 3), ")\n")
# 마찬가지로 CASI 변화량 표시
cat("CASI difference =", round(new_CASI["estimate"], 3),
    "(95% CI:", round(new_CASI["lower"], 3),
    "-", round(new_CASI["upper"], 3), ")\n")

# p0와 새로운 p1 표시
cat("Initial probability:", p0, "\n")
cat("New probability:", round(unname(p1), 3), "\n")
