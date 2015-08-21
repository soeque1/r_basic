## S26
mobile <- read.csv('mobile2014.csv', stringsAsFactors = F)
dim(mobile)
names(mobile)
table(mobile$Sentiment)

## S27
library(tm)
corpus <- Corpus(VectorSource(mobile$Texts))
stopwords()
stopwords('SMART')

## S28
dtm <- DocumentTermMatrix(corpus,
                          control = list(tolower = T,
                                         removePunctuation = T,
                                         removeNumbers = T,
                                         stopwords = stopwords("SMART"),
                                         weighting = weightTfIdf))

dtm

## S29
library(glmnet)
X <- as.matrix(dtm)
Y <- mobile$Sentiment
res.lm <- glmnet(X, Y, family = "binomial", lambda = 0) 

## S30
coef.lm <- coef(res.lm)[,1]
pos.lm <- coef.lm[coef.lm > 0]
neg.lm <- coef.lm[coef.lm < 0]
pos.lm <- sort(pos.lm, decreasing = T)
neg.lm <- sort(neg.lm, decreasing = F)

## S31
pos.lm[1:10]

## S32
neg.lm[1:10]

## S33
set.seed(12345)
res.lasso <- cv.glmnet(X, Y, family = "binomial", alpha = 1,
                       nfolds = 4, type.measure = "class")

## S34
plot(res.lasso)

## S35
plot(res.lasso$glmnet.fit, xvar = "lambda")

## S36
options(scipen = 100)
coef.lasso <- coef(res.lasso, s = "lambda.min")[,1]
pos.lasso <- coef.lasso[coef.lasso > 0]
neg.lasso <- coef.lasso[coef.lasso < 0]
pos.lasso <- sort(pos.lasso, decreasing = T)
neg.lasso <- sort(neg.lasso, decreasing = F)

## S37
pos.lasso[1:20]

## S38
neg.lasso[1:20]

## S39
set.seed(12345)
res.ridge <- cv.glmnet(X, Y, family = "binomial", alpha = 0,
                       nfolds = 4, type.measure = "class")

## S40
plot(res.ridge)

## S41
plot(res.ridge$glmnet.fit, xvar = "lambda")

## S42
coef.ridge <- coef(res.ridge, s = "lambda.min")[,1]
pos.ridge <- coef.ridge[coef.ridge > 0]
neg.ridge <- coef.ridge[coef.ridge < 0]
pos.ridge <- sort(pos.ridge, decreasing = T)
neg.ridge <- sort(neg.ridge, decreasing = F)

## S43
pos.ridge[1:20]

## S44
neg.ridge[1:20]

## S45
set.seed(12345)
res.elastic <- cv.glmnet(X, Y, family = "binomial", alpha = .5,
                         nfolds = 4, type.measure="class")

## S46
plot(res.elastic)

## S47
plot(res.elastic$glmnet.fit, xvar = "lambda")

## S48
coef.elastic <- coef(res.elastic, s = "lambda.min")[,1]
pos.elastic <- coef.elastic[coef.elastic > 0]
neg.elastic <- coef.elastic[coef.elastic < 0]
pos.elastic <- sort(pos.elastic, decreasing = T)
neg.elastic <- sort(neg.elastic, decreasing = F)

## S49
pos.elastic[1:20]

## S50
neg.elastic[1:20]

## S51
library(tm.plugin.sentiment)
senti.lm <- polarity(dtm, names(pos.lm), names(neg.lm))
senti.lasso <- polarity(dtm, names(pos.lasso), names(neg.lasso))
senti.ridge <- polarity(dtm, names(pos.ridge), names(neg.ridge))
senti.elastic <- polarity(dtm, names(pos.elastic), names(neg.elastic))

## S52
senti.lm <- polarity(dtm, names(pos.lm), names(neg.lm))
senti.lasso <- polarity(dtm, names(pos.lasso), names(neg.lasso))
senti.ridge <- polarity(dtm, names(pos.ridge), names(neg.ridge))
senti.elastic <- polarity(dtm, names(pos.elastic), names(neg.elastic))

## S53
senti.lm.b <- ifelse(senti.lm > 0, 1, 0)
senti.lasso.b <- ifelse(senti.lasso > 0, 1, 0)
senti.ridge.b <- ifelse(senti.ridge > 0, 1, 0)
senti.elastic.b <- ifelse(senti.elastic > 0, 1, 0)

## S54
library(caret)

## S55
confusionMatrix(senti.lm.b, mobile$Sentiment)

## S56
confusionMatrix(senti.lasso.b, mobile$Sentiment)

## S57
confusionMatrix(senti.ridge.b, mobile$Sentiment)

## S58
confusionMatrix(senti.elastic.b, mobile$Sentiment)

## S59
mobile.test <- read.csv("mobile2014_test.csv", stringsAsFactors = F)
dim(mobile.test)
names(mobile.test)
table(mobile.test$Sentiment)

## S60
corpus <- Corpus(VectorSource(mobile.test$Texts))
dtm.test <- DocumentTermMatrix(corpus,
                               control = list(tolower = T,
                                              removePunctuation = T,
                                              removeNumbers = T,
                                              stopwords = stopwords("SMART"),
                                              weighting = weightTfIdf,
                                              dictionary = Terms(dtm)))

## S61
senti.lm.test <- polarity(dtm.test, names(pos.lm), names(neg.lm))
senti.lasso.test <- polarity(dtm.test, names(pos.lasso), names(neg.lasso))
senti.ridge.test <- polarity(dtm.test, names(pos.ridge), names(neg.ridge))
senti.elastic.test <- polarity(dtm.test, names(pos.elastic), names(neg.elastic))

## S62
senti.lm.b.test <- ifelse(senti.lm.test > 0, 1, 0)
senti.lasso.b.test <- ifelse(senti.lasso.test > 0, 1, 0)
senti.ridge.b.test <- ifelse(senti.ridge.test > 0, 1, 0)
senti.elastic.b.test <- ifelse(senti.elastic.test > 0, 1, 0)

## S63
confusionMatrix(senti.lm.b.test, mobile.test$Sentiment)

## S64
confusionMatrix(senti.lasso.b.test, mobile.test$Sentiment)

## S65
confusionMatrix(senti.ridge.b.test, mobile.test$Sentiment)

## S66
confusionMatrix(senti.elastic.b.test, mobile.test$Sentiment)

## S67
X.test <- as.matrix(dtm.test)
senti.lm.test.coef <- predict(res.lm , newx = X.test)
senti.lasso.test.coef <- predict(res.lasso, newx = X.test, s = "lambda.min")
senti.ridge.test.coef <- predict(res.ridge, newx = X.test, s = "lambda.min")
senti.elastic.test.coef <- predict(res.elastic, newx = X.test, s = "lambda.min")

## S68
senti.lm.b.test.coef <- ifelse(senti.lm.test.coef > 0, 1, 0)
senti.lasso.b.test.coef <- ifelse(senti.lasso.test.coef > 0, 1, 0)
senti.ridge.b.test.coef <- ifelse(senti.ridge.test.coef > 0, 1, 0)
senti.elastic.b.test.coef <- ifelse(senti.elastic.test.coef > 0, 1, 0)

## S69
confusionMatrix(senti.lm.b.test.coef, mobile.test$Sentiment)

## S70
confusionMatrix(senti.lasso.b.test.coef, mobile.test$Sentiment)

## S71
confusionMatrix(senti.ridge.b.test.coef, mobile.test$Sentiment)

## S72
confusionMatrix(senti.elastic.b.test.coef, mobile.test$Sentiment)

## S73
confusionMatrix(senti.lm.b, mobile$Sentiment)$overall[1]
confusionMatrix(senti.lm.b.test, mobile.test$Sentiment)$overall[1]
confusionMatrix(senti.lm.b.test.coef, mobile.test$Sentiment)$overall[1]

## S74
confusionMatrix(senti.lasso.b, mobile$Sentiment)$overall[1]
confusionMatrix(senti.lasso.b.test, mobile.test$Sentiment)$overall[1]
confusionMatrix(senti.lasso.b.test.coef, mobile.test$Sentiment)$overall[1]

## S75
confusionMatrix(senti.ridge.b, mobile$Sentiment)$overall[1]
confusionMatrix(senti.ridge.b.test, mobile.test$Sentiment)$overall[1]
confusionMatrix(senti.ridge.b.test.coef, mobile.test$Sentiment)$overall[1]

## S76
confusionMatrix(senti.elastic.b, mobile$Sentiment)$overall[1]
confusionMatrix(senti.elastic.b.test, mobile.test$Sentiment)$overall[1]
confusionMatrix(senti.elastic.b.test.coef, mobile.test$Sentiment)$overall[1]
