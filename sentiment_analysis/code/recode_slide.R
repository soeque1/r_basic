rm(list = ls())
setwd("/Users/kimhyungjun/Dropbox/repo/r_basic/sentiment_analysis/data/")
## 데이터 불러오기 & TDM
mobile <- read.csv('mobile2014.csv', stringsAsFactors = F)
dim(mobile)
names(mobile)
mobile[1,]
mobile[2,]

table(mobile$Points)
table(mobile$Sentiment)

library(tm)
corpus <- Corpus(VectorSource(mobile$Texts))
stopwords()
stopwords("SMART")

dtm <- DocumentTermMatrix(corpus,
                          control = list(tolower = T,
                                         removePunctuation = T,
                                         removeNumbers = T,
                                         stopwords = stopwords("SMART"),
                                         weighting = weightTfIdf))
dtm

## 선형회귀분석

library(glmnet)
X <- as.matrix(dtm)
Y <- mobile$Points
res.lm <- glmnet(X, Y, family = "gaussian", lambda = 0)

coef.lm <- coef(res.lm)[,1]
pos.lm <- sort(coef.lm[coef.lm > 0], decreasing = T)
neg.lm <- sort(coef.lm[coef.lm < 0], decreasing = F)
pos.lm[1:5]
neg.lm[1:5]

res.lasso <- glmnet(X, Y, family = "gaussian", alpha = 1)

res.lasso
plot(res.lasso, xvar = "lambda")

res.lasso <- cv.glmnet(X, Y, family = "gaussian", alpha = 1,
                       nfolds = 4)
res.lasso
?cv.glmnet
plot(res.lasso)
plot(res.lasso$glmnet.fit, xvar = "lambda")

#getAnywhere("plot.cv.glmnet")

coef.lasso <- coef(res.lasso, s = "lambda.min")[,1]
pos.lasso <- sort(coef.lasso[coef.lasso > 0], decreasing = T)
neg.lasso <- sort(coef.lasso[coef.lasso < 0], decreasing = F)
pos.lasso[1:5]
neg.lasso[1:5]

res.ridge <- cv.glmnet(X, Y, family = "gaussian", alpha = 0,
                       nfolds = 4)

coef.ridge <- coef(res.ridge, s = "lambda.min")[,1]
pos.ridge <- sort(coef.ridge[coef.ridge > 0], decreasing = T)
neg.ridge <- sort(coef.ridge[coef.ridge < 0], decreasing = F)
pos.ridge[1:5]
neg.ridge[1:5]

res.elastic <- cv.glmnet(X, Y, family = "gaussian", alpha = .5,
                         nfolds = 4)

coef.elastic <- coef(res.elastic, s = "lambda.min")[,1]
pos.elastic <- sort(coef.elastic[coef.elastic > 0], decreasing = T)
neg.elastic <- sort(coef.elastic[coef.elastic < 0], decreasing = F)
pos.elastic[1:5]
neg.elastic[1:5]

### 점수 예측
library(tm.plugin.sentiment)

senti.lm <- polarity(dtm, names(pos.lm), names(neg.lm))
boxplot(senti.lm)
senti.lasso <- polarity(dtm, names(pos.lasso), names(neg.lasso))
boxplot(senti.lasso)
senti.ridge <- polarity(dtm, names(pos.ridge), names(neg.ridge))
boxplot(senti.ridge)
senti.elastic <- polarity(dtm, names(pos.elastic), names(neg.elastic))
boxplot(senti.elastic)

cor(cbind(Points = mobile$Points, senti.lm, senti.lasso, senti.ridge, senti.elastic),
    use = "pairwise.complete.obs")

### CV
total.num <- 1:nrow(mobile)
set.seed(54321)
shuffled.num <- sample(total.num, nrow(mobile), replace = F)
training.num <- shuffled.num[1:1400]
test.num <- shuffled.num[1401:2000]

train.mobile <- mobile[training.num, ]
test.mobile <- mobile[test.num, ]

### TDM
library(tm)
corpus <- Corpus(VectorSource(train.mobile$Texts))

train.dtm <- DocumentTermMatrix(corpus,
                                control = list(tolower = T,
                                               removePunctuation = T,
                                               removeNumbers = T,
                                               stopwords = stopwords("SMART"),
                                               weighting = weightTfIdf))
train.dtm

library(glmnet)
X <- as.matrix(train.dtm)
Y <- train.mobile$Points
res.lm <- glmnet(X, Y, family = "gaussian", lambda = 0)

coef.lm <- coef(res.lm)[,1]
pos.lm <- sort(coef.lm[coef.lm > 0], decreasing = T)
neg.lm <- sort(coef.lm[coef.lm < 0], decreasing = F)

res.lasso <- cv.glmnet(X, Y, family = "gaussian", alpha = 1,
                       nfolds = 4)

coef.lasso <- coef(res.lasso, s = "lambda.min")[,1]
pos.lasso <- sort(coef.lasso[coef.lasso > 0], decreasing = T)
neg.lasso <- sort(coef.lasso[coef.lasso < 0], decreasing = F)

res.ridge <- cv.glmnet(X, Y, family = "gaussian", alpha = 0,
                       nfolds = 4)

coef.ridge <- coef(res.ridge, s = "lambda.min")[,1]
pos.ridge <- sort(coef.ridge[coef.ridge > 0], decreasing = T)
neg.ridge <- sort(coef.ridge[coef.ridge < 0], decreasing = F)

res.elastic <- cv.glmnet(X, Y, family = "gaussian", alpha = .5,
                         nfolds = 4)

coef.elastic <- coef(res.elastic, s = "lambda.min")[,1]
pos.elastic <- sort(coef.elastic[coef.elastic > 0], decreasing = T)
neg.elastic <- sort(coef.elastic[coef.elastic < 0], decreasing = F)

### TEST

corpus <- Corpus(VectorSource(test.mobile$Texts))
test.dtm <- DocumentTermMatrix(corpus, 
                               control = list(tolower = T,
                                              removePunctuation = T,
                                              removeNumbers = T,
                                              stopwords = stopwords("SMART"),
                                              weighting = weightTfIdf,
                                              dictionary = Terms(train.dtm)))


### 점수 예측
library(tm.plugin.sentiment)

senti.lm <- polarity(test.dtm, names(pos.lm), names(neg.lm))
boxplot(senti.lm)
senti.lasso <- polarity(test.dtm, names(pos.lasso), names(neg.lasso))
boxplot(senti.lasso)
senti.ridge <- polarity(test.dtm, names(pos.ridge), names(neg.ridge))
boxplot(senti.ridge)
senti.elastic <- polarity(test.dtm, names(pos.elastic), names(neg.elastic))
boxplot(senti.elastic)

cor(cbind(Points = test.mobile$Points, senti.lm, senti.lasso, senti.ridge, senti.elastic),
    use = "pairwise.complete.obs")

##

