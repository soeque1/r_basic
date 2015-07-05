rm(list=ls())

ifelse(Sys.info()["sysname"][[1]] == "Windows", 
       setwd("C:/Users/snudormcomp/Dropbox/repo/r_basic"), 
       setwd("~/Dropbox/repo/r_basic"))

par(family="NanumGothic")

### Data Load
df <- read.csv("sales.csv")
colnames(df)
head(df)

### 성별 평균 비교
man <- subset(df, 성별 == "남")
woman <- subset(df, 성별 == "여")

man.mean <- mean(man$구매건수)
woman.mean <- mean(woman$구매건수)

barplot(c(man.mean, woman.mean), col = c("red", "blue"), legend = c("남", "여"), density = 30)
title(main = "남녀 구매건수 비교")

### 월별 & 성별 (5월만)
man.5 <- subset(df, 매출월 == 5 & 성별 == "남")
man.5.mean <- mean(man.5$구매건수)

woman.5 <- subset(df, 매출월 == 5 & 성별 == "여")
woman.5.mean <- mean(woman.5$구매건수)

barplot(c(man.5.mean, woman.5.mean), col = c("red", "blue"), legend = c("남", "여"), density = 30)
title(main = "5월 남녀 구매건수 비교")

#################### 직접 해보기 시작 ########################

### Task 요일별 구매건수 평균 그래프 그리기 
### ??? 를 채우세요

월 <- subset(df, ??? == ?)
화 <- subset(df, ??? == ?)
수 <- subset(df, ??? == ?)
목 <- subset(df, ??? == ?)
금 <- subset(df, ??? == ?)
토 <- subset(df, ??? == ?)
일 <- subset(df, ??? == ?)

월mean <- ???
화mean <- ???
수mean <- ???
목mean <- ???
금mean <- ???
토mean <- ???
일mean <- ???

barplot(???, col = rainbow(7), legend = c("월", "화", "수", "목", "금", "토", "일"), density = 30)
title(main = "요일별 구매건수 비교")

### Task 평일 vs 주말 구매건수 평균 그래프 그리기 
### ??? 를 채우세요

평일 <- subset(df, ??? == ?)  ### "==" 사용? "%in%" 사용?
주말 <- subset(df, ??? == ?)

평일mean <- ???
주말mean <- ???

barplot(???, col = ???, legend = ???, density = ???)
title(main = ???)

#################### 직접 해보기 끝 ########################

### 월별 & 성별 (5월 ~ 9월)

for (i in 5:9)
{
    man <- subset(df, 매출월 == i & 성별 == "남")
    man.mean <- mean(man$구매건수)
    
    woman <- subset(df, 매출월 == i & 성별 == "여")
    woman.mean <- mean(woman$구매건수)
    
    png(filename = sprintf("%d%s", i, ".png"))
    barplot(c(man.mean, woman.mean), col = c("red", "blue"), legend = c("남", "여"), density = 30)
    title(main = paste(i, "월 남녀 구매건수 비교"))
    dev.off()
}