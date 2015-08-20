options()$scipen
options(scipen = 0)

### scientific notation
0.1
.1
.01
.001
.0001
1e-04

options()$scipen
options(scipen = 1)
.0001
.00001

options(scipen = 999)
.00000000001

options(scipen = 0)
.0001


rm(list = ls())
setwd("/Users/kimhyungjun/Dropbox/repo/r_basic/sentiment_analysis/data/")
## 데이터 불러오기 & TDM
mobile <- read.csv('mobile2014.csv', stringsAsFactors = F)
dim(mobile)
names(mobile)

mobile[2,]
mobile[1035, ]

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

## 로지스틱회귀분석

library(glmnet)
X <- as.matrix(dtm)
Y <- mobile$Sentiment
res.lm <- glmnet(X, Y, family = "binomial", lambda = 0)

coef.lm <- coef(res.lm)
coef.lm

coef.lm <- coef.lm[,1]
coef.lm

coef.lm > 0
pos.lm <- coef.lm[coef.lm > 0]
pos.lm


pos.lm

pos.lm <- sort(pos.lm, decreasing = T)
pos.lm

coef.lm < 0
neg.lm <- coef.lm[coef.lm < 0]
    
neg.lm <- sort(neg.lm, decreasing = F)

pos.lm[1:5]
neg.lm[1:5]

## 라쏘

res.lasso <- glmnet(X, Y, family = "binomial", alpha = 1)

res.lasso
plot(res.lasso, xvar = "lambda")

set.seed(12345)
res.lasso <- cv.glmnet(X, Y, family = "binomial", alpha = 1,
                       nfolds = 4, type.measure="class")
res.lasso

plot(res.lasso)
plot(res.lasso$glmnet.fit, xvar = "lambda")

coef.lasso <- coef(res.lasso, s = "lambda.min")[,1]
coef.lasso

options(scipen = 100)
pos.lasso <- coef.lasso[coef.lasso > 0]
neg.lasso <- coef.lasso[coef.lasso < 0]

pos.lasso <- sort(pos.lasso, decreasing = T)
neg.lasso <- sort(neg.lasso, decreasing = F)
pos.lasso[1:5]
neg.lasso[1:5]

## 릿찌

set.seed(12345)
res.ridge <- cv.glmnet(X, Y, family = "binomial", alpha = 0,
                       nfolds = 4, type.measure="class")

plot(res.ridge)
plot(res.ridge$glmnet.fit, xvar = "lambda")

coef.ridge <- coef(res.ridge, s = "lambda.min")[,1]

pos.ridge <- coef.ridge[coef.ridge > 0]
neg.ridge <- coef.ridge[coef.ridge < 0]
    
pos.ridge <- sort(pos.ridge, decreasing = T)
neg.ridge <- sort(neg.ridge, decreasing = F)
pos.ridge[1:5]
neg.ridge[1:5]

## 엘라스틱넷
set.seed(12345)
res.elastic <- cv.glmnet(X, Y, family = "binomial", alpha = .5,
                         nfolds = 4, type.measure="class")

plot(res.elastic)
plot(res.elastic$glmnet.fit, xvar = "lambda")

coef.elastic <- coef(res.elastic, s = "lambda.min")[,1]

pos.elastic <- coef.elastic[coef.elastic > 0]
neg.elastic <- coef.elastic[coef.elastic < 0]
pos.elastic <- sort(pos.elastic, decreasing = T)
neg.elastic <- sort(neg.elastic, decreasing = F)
pos.elastic[1:5]
neg.elastic[1:5]

## 파일로 저장
length(pos.lm)
length(neg.lm)
length(pos.lm) + length(neg.lm) - 1

length(pos.lasso)
length(neg.lasso)
length(pos.lasso) + length(neg.lasso) - 1

length(pos.ridge)
length(neg.ridge)
length(pos.ridge) + length(neg.ridge) -1

length(pos.elastic)
length(neg.elastic)
length(pos.elastic) + length(neg.elastic) -1


write.csv(pos.lm, "pos.lm.csv")
read.csv('pos.lm.csv')[1,]

write.csv(neg.lm, "neg.lm.csv")
read.csv('neg.lm.csv')[1,]

write.csv(pos.lasso, "pos.lasso.csv")
read.csv('pos.lm.csv')[1,]

write.csv(neg.lasso, "neg.lasso.csv")
read.csv('neg.lasso.csv')[1,]

write.csv(neg.ridge, "neg.ridge.csv")
read.csv('neg.ridge.csv')[1,]

write.csv(neg.elastic, "neg.elastic.csv")
read.csv('neg.elastic.csv')[1,]



## 점수 예측
library(tm.plugin.sentiment)

senti.lm <- polarity(dtm, names(pos.lm), names(neg.lm))
boxplot(senti.lm)
senti.lasso <- polarity(dtm, names(pos.lasso), names(neg.lasso))
boxplot(senti.lasso)
senti.ridge <- polarity(dtm, names(pos.ridge), names(neg.ridge))
boxplot(senti.ridge)
senti.elastic <- polarity(dtm, names(pos.elastic), names(neg.elastic))
boxplot(senti.elastic)

pos.lm.csv <- read.csv('pos.lm.csv')
pos.lm.csv[,1]
neg.lm.csv <- read.csv('neg.lm.csv')
pos.lasso.csv <- read.csv('pos.lasso.csv')
neg.lasso.csv <- read.csv('neg.lasso.csv')

senti.lm <- polarity(dtm, pos.lm[,1], neg.lm[,1])
senti.lasso <- polarity(dtm, pos.lasso[,1], neg.lasso[,1])





#### 정확도 
senti.lasso.b <- ifelse(senti.lasso > 0, 1, 0)

library(caret)
confusionMatrix(senti.lasso.b, mobile$Sentiment)

### CV

mobile.test <- read.csv("mobile2014_test.csv", stringsAsFactors = F)

corpus <- Corpus(VectorSource(mobile.test$Texts))
dtm.test <- DocumentTermMatrix(corpus, 
                               control = list(tolower = T,
                                              removePunctuation = T,
                                              removeNumbers = T,
                                              stopwords = stopwords("SMART"),
                                              weighting = weightTfIdf,
                                              dictionary = Terms(dtm)))

dtm.test
dtm

#### 
senti.lm.test <- polarity(dtm.test, names(pos.lm), names(neg.lm))
boxplot(senti.lm.test)
senti.lasso.test <- polarity(dtm.test, names(pos.lasso), names(neg.lasso))
boxplot(senti.lasso.test)
senti.ridge.test <- polarity(dtm.test, names(pos.ridge), names(neg.ridge))
boxplot(senti.ridge.test)
senti.elastic.test <- polarity(dtm.test, names(pos.elastic), names(neg.elastic))
boxplot(senti.elastic.test)

#### 정확도 
senti.lm.b.test <- ifelse(senti.lm.test > 0, 1, 0)
senti.lasso.b.test <- ifelse(senti.lasso.test > 0, 1, 0)
senti.ridge.b.test <- ifelse(senti.ridge.test > 0, 1, 0)
senti.elastic.b.test <- ifelse(senti.elastic.test > 0, 1, 0)

library(caret)
confusionMatrix(senti.lm.b.test, mobile.test$Sentiment)
confusionMatrix(senti.lasso.b.test, mobile.test$Sentiment)
confusionMatrix(senti.ridge.b.test, mobile.test$Sentiment)
confusionMatrix(senti.elastic.b.test, mobile.test$Sentiment)


#### 추가 동영상

data.test <- read.csv('mobile2014_test.csv', stringsAsFactors = F)
corpus <- Corpus(VectorSource(data.test$Texts))
dtm.test <- DocumentTermMatrix(corpus,
                               control = list(tolower = T,
                                              removePunctuation = T,
                                              removeNumbers = T,
                                              stopwords = stopwords("SMART"),
                                              weighting = weightTfIdf,
                                              dictionary = Terms(dtm)))

library(tm.plugin.sentiment)
senti.lm.test <- polarity(dtm.test, names(pos.lm), names(neg.lm))
senti.lasso.test <- polarity(dtm.test, names(pos.lasso), names(neg.lasso))
senti.ridge.test <- polarity(dtm.test, names(pos.ridge), names(neg.ridge))
senti.elastic.test <- polarity(dtm.test, names(pos.elastic), names(neg.elastic))

senti.lm.b.test <- ifelse(senti.lm.test > 0, 1, 0)
senti.lasso.b.test <- ifelse(senti.lasso.test > 0, 1, 0)
senti.ridge.b.test <- ifelse(senti.ridge.test > 0, 1, 0)
senti.elastic.b.test <- ifelse(senti.elastic.test > 0, 1, 0)


X.test <- as.matrix(dtm.test)
senti.elastic.test.coef <- predict(res.elastic, newx = X.test, s = "lambda.min")
senti.elastic.b.test.coef <- ifelse(senti.elastic.test.coef > 0, 1, 0)

confusionMatrix(senti.elastic.b.test.coef, data.test$Sentiment)

## 사례 연구

## 복습 및 총정리

mobile <- read.csv('mobile2014.csv', stringsAsFactors = F)

library(tm)
corpus <- Corpus(VectorSource(mobile$Texts))

stopwords("SMART")

dtm <- DocumentTermMatrix(corpus,
                          control = list(tolower = T,
                                         removePunctuation = T,
                                         removeNumbers = T,
                                         stopwords = stopwords("SMART"),
                                         weighting = weightTfIdf))

library(glmnet)
X <- as.matrix(dtm)
Y <- mobile$Sentiment

res.lm <- glmnet(X, Y, family = "binomial", lambda = 0) 
coef.lm <- coef(res.lm)[,1]

pos.lm <- coef.lm[coef.lm > 0]
neg.lm <- coef.lm[coef.lm < 0]

pos.lm <- sort(pos.lm, decreasing = T)
neg.lm <- sort(neg.lm, decreasing = F)

res.lasso <- glmnet(X, Y, family = "binomial", alpha = 1)
res.lasso <- cv.glmnet(X, Y, family = "binomial", alpha = 1,
                       nfolds = 4, type.measure = "class")

coef.lasso <- coef(res.lasso, s = "lambda.min")[,1]
pos.lasso <- coef.lasso[coef.lasso > 0]
neg.lasso <- coef.lasso[coef.lasso < 0]
pos.lasso <- sort(pos.lasso, decreasing = T)
neg.lasso <- sort(neg.lasso, decreasing = F)

set.seed(12345)
res.ridge <- cv.glmnet(X, Y, family = "binomial", alpha = 0,
                       nfolds = 4, type.measure = "class")

coef.ridge <- coef(res.ridge, s = "lambda.min")[,1]
pos.ridge <- coef.ridge[coef.ridge > 0]
neg.ridge <- coef.ridge[coef.ridge < 0]
pos.ridge <- sort(pos.ridge, decreasing = T)
neg.ridge <- sort(neg.ridge, decreasing = F)    

set.seed(12345)
res.elastic <- cv.glmnet(X, Y, family = 'binomial', alpha = .5,
                         nfolds = 4, type.measure = 'class')
coef.elastic <- coef(res.elastic, s = "lambda.min")[,1]
pos.elastic <- coef.elastic[coef.elastic > 0]
neg.elastic <- coef.elastic[coef.elastic < 0]
pos.elastic <- sort(pos.elastic, decreasing = T)
neg.elastic <- sort(neg.elastic, decreasing = F)

# data.test <- read.csv("books_test.csv", stringsAsFactors = F)
data.test <- read.csv("tablet2014_test.csv", stringsAsFactors = F)

corpus <- Corpus(VectorSource(data.test$Texts))
dtm.test <- DocumentTermMatrix(corpus, 
                               control = list(tolower = T,
                                              removePunctuation = T,
                                              removeNumbers = T,
                                              stopwords = stopwords("SMART"),
                                              weighting = weightTfIdf,
                                              dictionary = Terms(dtm)))

#### 
senti.lm.test <- polarity(dtm.test, names(pos.lm), names(neg.lm))
boxplot(senti.lm.test)
senti.lasso.test <- polarity(dtm.test, names(pos.lasso), names(neg.lasso))
boxplot(senti.lasso.test)
senti.ridge.test <- polarity(dtm.test, names(pos.ridge), names(neg.ridge))
boxplot(senti.ridge.test)
senti.elastic.test <- polarity(dtm.test, names(pos.elastic), names(neg.elastic))
boxplot(senti.elastic.test)

#### 정확도 
senti.lm.b.test <- ifelse(senti.lm.test > 0, 1, 0)
senti.lasso.b.test <- ifelse(senti.lasso.test > 0, 1, 0)
senti.ridge.b.test <- ifelse(senti.ridge.test > 0, 1, 0)
senti.elastic.b.test <- ifelse(senti.elastic.test > 0, 1, 0)

library(caret)
confusionMatrix(senti.lm.b.test, data.test$Sentiment)
confusionMatrix(senti.lasso.b.test, data.test$Sentiment)
confusionMatrix(senti.ridge.b.test, data.test$Sentiment)
confusionMatrix(senti.elastic.b.test, data.test$Sentiment)

### ACC 비교

lm.acc <- confusionMatrix(senti.lm.b.test, data.test$Sentiment)$overall[1]
lasso.acc <- confusionMatrix(senti.lasso.b.test, data.test$Sentiment)$overall[1]
ridge.acc <- confusionMatrix(senti.ridge.b.test, data.test$Sentiment)$overall[1]
elastic.acc <- confusionMatrix(senti.elastic.b.test, data.test$Sentiment)$overall[1]

acc <- c(lm.acc, lasso.acc, ridge.acc, elastic.acc)
names(acc) <- c('lm', 'lasso', 'ridge', 'elastic')
mobile.acc <- acc

######
mobile.acc
tablet.acc
books.acc

### 함수화

calACC <- function(data.test, 
                   dtm,
                   pos.lm, neg.lm,
                   pos.lasso, neg.lasso,
                   pos.ridge, neg.ridge,
                   pos.elastic, neg.elastic)
{   
    corpus <- Corpus(VectorSource(data.test$Texts))
    dtm.test <- DocumentTermMatrix(corpus,
                                   control = list(tolower = T,
                                                  removePunctuation = T,
                                                  removeNumbers = T,
                                                  stopwords = stopwords("SMART"),
                                                  weighting = weightTfIdf,
                                                  dictionary = Terms(dtm)))
    
    library(tm.plugin.sentiment)
    senti.lm.test <- polarity(dtm.test, names(pos.lm), names(neg.lm))
    senti.lasso.test <- polarity(dtm.test, names(pos.lasso), names(neg.lasso))
    senti.ridge.test <- polarity(dtm.test, names(pos.ridge), names(neg.ridge))
    senti.elastic.test <- polarity(dtm.test, names(pos.elastic), names(neg.elastic))
    
    senti.lm.b.test <- ifelse(senti.lm.test > 0, 1, 0)
    senti.lasso.b.test <- ifelse(senti.lasso.test > 0, 1, 0)
    senti.ridge.b.test <- ifelse(senti.ridge.test > 0, 1, 0)
    senti.elastic.b.test <- ifelse(senti.elastic.test > 0, 1, 0)
    
    library(caret)
    lm.acc <- confusionMatrix(senti.lm.b.test, data.test$Sentiment)$overall[1]
    lasso.acc <- confusionMatrix(senti.lasso.b.test, data.test$Sentiment)$overall[1]
    ridge.acc <- confusionMatrix(senti.ridge.b.test, data.test$Sentiment)$overall[1]
    elastic.acc <- confusionMatrix(senti.elastic.b.test, data.test$Sentiment)$overall[1]
    acc <- c(lm.acc, lasso.acc, ridge.acc, elastic.acc)
    names(acc) <- c('lm', 'lasso', 'ridge', 'elastic')
    acc
}

data.test <- read.csv('books_test.csv', stringsAsFactors = F)


calACC(data.test,
       dtm,
       pos.lm, neg.lm,
       pos.lasso, neg.lasso,
       pos.ridge, neg.ridge,
       pos.elastic, neg.elastic)