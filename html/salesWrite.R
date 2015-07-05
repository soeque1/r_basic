rm(list=ls())

ifelse(Sys.info()["sysname"][[1]] == "Windows", 
       setwd("C:/Users/snudormcomp/Dropbox/repo/r_basic"), 
       setwd("~/Dropbox/repo/r_basic"))

monthNum <- 12
dayNum <- 7
sexNum <- 2
marketNum <- 15
totalRow <- monthNum * dayNum * sexNum * marketNum  # 월 * 요일 * 성별 * 점포

market <- rep(letters[1:marketNum], totalRow / marketNum)

month <- unlist(lapply(1:12, function(x) rep(x, totalRow / monthNum)))

sex <- rep(c("남자", "여"),  totalRow / sexNum)

days <- rep( c("월", "화", "수", "목", "금", "토", "일"), totalRow / dayNum)

set.seed(54321)

salesNum <- ceiling(runif(totalRow, 0, 50000))

df <- data.frame(매출월 = month, 요일 = days, 점포 = market, 성별 = sex, 구매건수 = salesNum,
                 stringsAsFactors = F)

df[df$sex == "남", "sex"] <- "남자"

dfList <- list()

for (i in 1:monthNum)
{
  dfList[[i]] <- rbind(c(sprintf("%d%s", i, "월"), rep(NA, ncol(df)-1)), rep(NA, ncol(df)), split(df, df$매출월)[[i]])
}

library(data.table)
dfSave <- rbindlist(dfList)

write.table(dfSave, "sales.csv", row.names = F, sep=",", na = "")

