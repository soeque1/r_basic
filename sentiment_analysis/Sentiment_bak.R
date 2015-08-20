## 퀀트랩 소개

<center><img src="assets/img/quantlab_intro.jpg" height=450px width=800px></center>
    
    --- .new-background

## 워크숍 관련 온라인 사이트

http://course.mindscale.kr/course/text-analysis

<left><img src="assets/img/courses.png" height=450px width=600px></left>
    
    --- .new-background

--- &twocol .modal

## 둘 중 무엇이 상관이 더 클까요?

*** =left

```{r, echo = F}
set.seed(1)
heights = rnorm(30,180,5)
heights = sort(heights, decreasing = F)
weights =  -10 + heights*.5 + rnorm(30,0,2)
```

```{r, echo=F,warning=F, fig.width=6, fig.height=6}
plot(heights, weights, pch = 16, ylim = c(70,90), cex.lab = 2)
#cor(weights, heights)
```

*** =right

```{r, echo = F}
set.seed(1)
heights = rnorm(30,180,5)
heights = sort(heights, decreasing = F)
weights =  -10 + heights*.5 + rnorm(30,0,2)
weights = weights / 10 + 70
```

```{r, echo=F,warning=F, fig.width=6, fig.height=6}
plot(heights, weights, pch = 16, ylim = c(70,90), cex.lab = 2)
#cor(weights, heights)
```
--- .newbackground

## Traing Set 과 Test Set 분할

```{r}
totalNum <- 1:nrow(data)
set.seed(12345)
shuffledNum <- sample(totalNum, nrow(data), replace = F)
trainingNum <- shuffledNum[1:1400]
testNum <- shuffledNum[1401:2000]
data.train <- data[trainingNum, ]
data.test <- data[testNum, ]
```

--- .newbackground

## LASSO Regression
```{r}
plot(cv.lasso)
log(cv.lasso$lambda.min)
```

--- .newbackground

## LASSO Regression
```{r}
plot(cv.lasso$glmnet.fit, "lambda", label=TRUE)
```

--- .newbackground

## Ridge Regression

```{r}
alpha <- 0
cv.ridge <- cv.glmnet(as.matrix(t(tdm.train)), data.train$sentiment, 
                      type.measure = "class", 
                      nfolds = 4,
                      family = "binomial", 
                      alpha = alpha)
```

--- .newbackground

## RIDGE Regression

```{r}
plot(cv.ridge)
log(cv.ridge$lambda.min)
```

--- .newbackground

## RIDGE Regression

```{r}
plot(cv.ridge$glmnet.fit, "lambda", label=TRUE)
```

--- .newbackground

## ElasticNet Regression

```{r}
alpha <- .3
cv.elastic <- cv.glmnet(as.matrix(t(tdm.train)), data.train$sentiment, 
                        type.measure = "class", 
                        nfolds = 4,
                        family = "binomial", 
                        alpha = alpha)
```

--- .newbackground

## ElasticNet Regression

```{r}
plot(cv.elastic)
log(cv.elastic$lambda.min)
```

--- .newbackground

## ElasticNet Regression

```{r}
plot(cv.elastic$glmnet.fit, "lambda", label=TRUE)
```

--- .newbackground

## 감정 단어 추출

```{r}
coef.lasso <- coef(cv.lasso, s = "lambda.min")[,1]
coef.ridge <- coef(cv.ridge, s = "lambda.min")[,1]
coef.elastic <- coef(cv.elastic, s = "lambda.min")[,1]
```

--- .newbackground

## 감정 단어 추출

```{r}

pos.lasso <- sort(coef.lasso[coef.lasso > 0])
neg.lasso <- sort(coef.lasso[coef.lasso < 0])

length(pos.lasso)
length(neg.lasso)

```

--- .newbackground

## 감정 단어 추출

```{r, cache=F}

pos.lasso[1:5]
neg.lasso[1:5]
```


--- .newbackground

## 감정 단어 추출

```{r}

pos.ridge <- sort(coef.ridge[coef.ridge > 0])
neg.ridge <- sort(coef.ridge[coef.ridge < 0])

length(pos.ridge)
length(neg.ridge)

```

--- .newbackground

## 감정 단어 추출

```{r, cache=F}

pos.ridge[1:5]
neg.ridge[1:5]

```

--- .newbackground

## 감정 단어 추출

```{r}

pos.elastic <- sort(coef.elastic[coef.elastic > 0])
neg.elastic <- sort(coef.elastic[coef.elastic < 0])

length(pos.elastic)
length(neg.elastic)

```

--- .newbackground

## 감정 단어 추출

```{r, cache=F}

pos.elastic[1:5]
neg.elastic[1:5]

```


--- .newbackground

## 감정 단어 점수화

```{r, warning=F, message=F}
library(tm.plugin.sentiment)
```

```{r}
score.lasso <- polarity(tdm.train, names(pos.lasso), names(neg.lasso))
score.ridge <- polarity(tdm.train, names(pos.elastic), names(neg.elastic))
score.elastic <- polarity(tdm.train, names(pos.elastic), names(neg.elastic))
```

--- .newbackground

## CUT-POINT

```{r, warning=F, message=F, echo = F}
library(ROCR)
```

```{r, echo = F}
findCutpoint <- function(dataSentiment, predSentiment)
{
    pred <- prediction(predSentiment, dataSentiment)
    perf <- performance(pred,"tpr", "fpr")
    auc <- performance(pred,"auc")
    auc <- unlist(slot(auc, "y.values"))
    acc <- performance(pred,"acc")
    cutpoint <- as.numeric(unlist(slot(acc, "x.values"))[which.max(unlist(slot(acc, "y.values")))])
    return(cutpoint)
}
```


```{r}
findCutpoint(data.train$sentiment, score.lasso)
findCutpoint(data.train$sentiment, score.ridge)
findCutpoint(data.train$sentiment, score.elastic)
```

--- .newbackground

## CUT-POINT

```{r, message=F}
library(pROC)
```

```{r, message=F, fig.width=6, fig.height=5}
plot.roc(data.train$sentiment, score.lasso, print.thres = T)
```

--- .newbackground

## CUT-POINT


```{r}
cut.lasso <- findCutpoint(data.train$sentiment, score.lasso)
cut.ridge <- findCutpoint(data.train$sentiment, score.ridge)
cut.elastic <- findCutpoint(data.train$sentiment, score.elastic)
```

--- .newbackground

## Test Set

```{r}
corpus <- Corpus(VectorSource(data.test$review))

tdm.test <- TermDocumentMatrix(corpus, 
                               control=list(dictionary = Terms(tdm.train), 
                                            tolower = T,
                                            removePunctuation = T,
                                            removeNumbers = T,
                                            stopwords=stopwords("SMART")))
```

--- .newbackground

## Test Set


```{r}
score.lasso <- polarity(tdm.test, names(pos.lasso), names(neg.lasso))
score.ridge <- polarity(tdm.test, names(pos.elastic), names(neg.elastic))
score.elastic <- polarity(tdm.test, names(pos.elastic), names(neg.elastic))
```

--- .newbackground

## Test Set

```{r, message=F}
library(caret)
```

```{r}
score.lasso.b <- rep(0, length(score.lasso))
score.lasso.b[score.lasso >= cut.lasso] <- 1
confusionMatrix(score.lasso.b, data.test$sentiment)
```

--- .newbackground

## Test Set

```{r}
score.ridge.b <- rep(0, length(score.ridge))
score.ridge.b[score.ridge >= cut.ridge] <- 1
confusionMatrix(score.ridge.b, data.test$sentiment)
```

--- .newbackground

## Test Set

```{r}
score.elastic.b <- rep(0, length(score.elastic))
score.elastic.b[score.elastic >= cut.elastic] <- 1
confusionMatrix(score.elastic.b, data.test$sentiment)
```

--- .newbackground

## glmnet 활용

```{r}
score.lasso <- predict(cv.lasso, as.matrix(t(tdm.train)), s = "lambda.min")
score.ridge <- predict(cv.ridge, as.matrix(t(tdm.train)), s = "lambda.min")
score.elastic <- predict(cv.elastic, as.matrix(t(tdm.train)), s = "lambda.min")
```

--- .newbackground

## glmnet 활용

```{r}
findCutpoint(data.train$sentiment, score.lasso)
findCutpoint(data.train$sentiment, score.ridge)
findCutpoint(data.train$sentiment, score.elastic)
```

```{r}
cut.lasso <- findCutpoint(data.train$sentiment, score.lasso)
cut.ridge <- findCutpoint(data.train$sentiment, score.ridge)
cut.elastic <- findCutpoint(data.train$sentiment, score.elastic)
```

--- .newbackground

## glmnet 활용

```{r}
score.lasso <- predict(cv.lasso, as.matrix(t(tdm.test)), s = "lambda.min")
score.ridge <- predict(cv.ridge, as.matrix(t(tdm.test)), s = "lambda.min")
score.elastic <- predict(cv.elastic, as.matrix(t(tdm.test)), s = "lambda.min")
```

--- .newbackground

## Test Set

```{r}
score.lasso.b <- rep(0, length(score.lasso))
score.lasso.b[score.lasso >= cut.lasso] <- 1
confusionMatrix(score.lasso.b, data.test$sentiment)
```

--- .newbackground

## Test Set

```{r}
score.ridge.b <- rep(0, length(score.ridge))
score.ridge.b[score.ridge >= cut.ridge] <- 1
confusionMatrix(score.ridge.b, data.test$sentiment)
```

--- .newbackground

## Test Set

```{r}
score.elastic.b <- rep(0, length(score.elastic))
score.elastic.b[score.elastic >= cut.elastic] <- 1
confusionMatrix(score.elastic.b, data.test$sentiment)
```

--- .newbackground

## 다른 데이터에 적용

<h3b> Data </h3b>  
    <h3b> Amazon Books Reviews 중에서 2,000개</h3b>  
    
    --- .newbackground

## Test Set

```{r}
books.review <- read.csv("data/Amazon_books.csv", stringsAsFactors = F)
```

--- .newbackground

## Test Set

```{r}
corpus <- Corpus(VectorSource(books.review$texts))

tdm.test <- TermDocumentMatrix(corpus, 
                               control=list(dictionary = Terms(tdm.train), 
                                            tolower = T,
                                            removePunctuation = T,
                                            removeNumbers = T,
                                            stopwords=stopwords("SMART")))
```

--- .newbackground

## Test Set

```{r}
score.elastic <- polarity(tdm.test, names(pos.elastic), names(neg.elastic))
```

--- .newbackground

## Test Set

```{r}
score.elastic.b <- rep(0, length(score.elastic))
score.elastic.b[score.elastic >= cut.elastic] <- 1
confusionMatrix(score.elastic.b, books.review$sentiment)
```

