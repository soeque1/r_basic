# rm(list = ls())
# setwd("/Users/kimhyungjun/Dropbox/repo/r_basic/sentiment_analysis/data/AmazonReviews/mobilephone/")
# 
# fileList <- list.files(getwd())
# library(jsonlite)
# data <- fromJSON(txt=fileList[1])[[1]]
# 
# for (i in 2:length(fileList))
# {
#     temp <- fromJSON(txt=fileList[i])[[1]]
#     data <- rbind(data, temp)
#     rm(temp)
#     if(i%%1000 == 0)
#         print(i)
# }
# table(data$Date)
# write.csv(data, "/Users/kimhyungjun/Dropbox/repo/r_basic/sentiment_analysis/data/mobile.csv")

data <- read.csv("/Users/kimhyungjun/Dropbox/repo/r_basic/sentiment_analysis/data/mobile.csv")

library(dplyr)
library(stringr)
data$Year <- str_extract(data$Date, "[0-9][0-9][0-9]+") %>% as.numeric()
data2014 <- data[data$Year == "2014", ]
data2014 <- data2014[!is.na(data2014[,1]),]

#galaxyNum <- sapply(data2014$Content, function(x) grep("s3|galaxy", tolower(x)), USE.NAMES = F)
#data2014 <- data2014[which(galaxyNum > 0),]
#data2014 <- data2014[data2014$Overall != 3,]
data2014$Month <- str_extract(data2014[,"Date"], "[A-Za-z]+")
sampleNumMonths <- sapply(c("January", "February", "March", "April", "May"), function(x) which(data2014$Month == x))

set.seed(12345)

hist(data2014$Overall)
set.seed(12345)

sampleTotalNum <- c()

for (i in 1:length(sampleNumMonths))
{
    sampleNum <- sample(sampleNumMonths[[i]], 400, replace = F)
    sampleTotalNum <- c(sampleTotalNum , sampleNum)     
    rm(sampleNum)
}
length(sampleTotalNum)
length(unique(sampleTotalNum))

dataSample2000 <- data2014[sampleTotalNum, ]
dataSample2000$Sentiment <- ifelse(dataSample2000$Overall > 3, 1, 0)
Y <- sprintf("%02d", as.numeric(str_extract(dataSample2000$Date, '([0-9][0-9][0-9]+)')))
M <- sprintf("%02d", as.numeric(factor(dataSample2000$Month, levels = c("January", "February", "March", "April", "May"))))
D <- sprintf("%02d", as.numeric(str_extract(dataSample2000$Date, '([0-9]+)')))
dataSample2000$YMD <- paste(Y, M, D, sep ="-")

table(dataSample2000$Month)
table(dataSample2000$Overall)

colnames(dataSample2000)[5] <- "Points"
colnames(dataSample2000)[6] <- "Texts"

write.csv(dataSample2000, "/Users/kimhyungjun/Dropbox/repo/r_basic/sentiment_analysis/data/mobile2014.csv")

### Binary
data <- read.csv("/Users/kimhyungjun/Dropbox/repo/r_basic/sentiment_analysis/data/mobile.csv")

## 태블릿
data <- read.csv("/Users/kimhyungjun/Dropbox/repo/r_basic/sentiment_analysis/data/tablets.csv")

library(dplyr)
library(stringr)
data$Year <- str_extract(data$Date, "[0-9][0-9][0-9]+") %>% as.numeric()
data2014 <- data[data$Year == "2014", ]
data2014 <- data2014[!is.na(data2014[,1]),]

table(data2014$Overall)

data2014$Month <- str_extract(data2014[,"Date"], "[A-Za-z]+")
numMonths <- sapply(c("January", "February", "March", "April", "May"), function(x) which(data2014$Month == x))
numSentiment <- sapply(c(1,5), function(x) which(as.integer(data2014$Overall) == x))

set.seed(12345)

sampleTrainTotalNum <- c()
sampleTestTotalNum <- c()

for (j_sen in 1:2)  ## 1 = Neg, 5 = Pos
{
    for (i_mon in 1:length(numMonths))
    {
        sampleNum <- sample(numMonths[[i_mon]][numMonths[[i_mon]] %in% numSentiment[[j_sen]]], 300, replace = F)    
        sampleTrainNum <- sample(sampleNum, 200, replace = F)
        sampleTestNum <- setdiff(sampleNum, sampleTrainNum)
        
        sampleTrainTotalNum <- c(sampleTrainTotalNum, sampleTrainNum)
        sampleTestTotalNum <- c(sampleTestTotalNum, sampleTestNum)
        
        rm(sampleNum); rm(sampleTrainNum); rm(sampleTestNum)
    }
}

length(sampleTrainTotalNum);length(sampleTestTotalNum)
length(unique(sampleTrainTotalNum));length(unique(sampleTestTotalNum))

dataSample2000 <- data2014[c(sampleTrainTotalNum, sampleTestTotalNum), ]
Y <- sprintf("%02d", as.numeric(str_extract(dataSample2000$Date, '([0-9][0-9][0-9]+)')))
M <- sprintf("%02d", as.numeric(factor(dataSample2000$Month, levels = c("January", "February", "March", "April", "May"))))
D <- sprintf("%02d", as.numeric(str_extract(dataSample2000$Date, '([0-9]+)')))
dataSample2000$YMD <- paste(Y, M, D, sep ="-")

dataSample2000$Sentiment <- ifelse(dataSample2000$Overall > 3, 1, 0)

table(dataSample2000$Month)
table(dataSample2000$Overall)
table(dataSample2000$Sentiment)

dataSample2000 <- dataSample2000[, c(2,3,4,6,10,11)]
colnames(dataSample2000)[4] <- "Texts"

write.csv(dataSample2000[1:2000, ], "/Users/kimhyungjun/Dropbox/repo/r_basic/sentiment_analysis/data/mobile2014.csv")
write.csv(dataSample2000[2001:3000, ], "/Users/kimhyungjun/Dropbox/repo/r_basic/sentiment_analysis/data/mobile2014_test.csv")
#write.csv(dataSample2000[2001:3000, ], "/Users/kimhyungjun/Dropbox/repo/r_basic/sentiment_analysis/data/tablet2014_test.csv")


books <- read.csv("books.csv")
set.seed(12345)
pos.num <- sample(which(books$Sentiment == 1), 500, replace = F)
neg.num <- sample(which(books$Sentiment == 0), 500, replace = F)

books.test <- books[c(neg.num, pos.num), ]
books.test <- books.test[,c(2,3,5)]
write.csv(books.test, "/Users/kimhyungjun/Dropbox/repo/r_basic/sentiment_analysis/data/books_test.csv")

