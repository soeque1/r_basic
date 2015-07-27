rm(list=ls())
library(tm)

#strsplit_space_tokenizer <- function(x)
#    unlist(strsplit(as.character(x), "[[:space:]]+")) ## windows에서 한글 때문에 
#unlist(strsplit(as.character(x), "([[:punct:]]|[0-9]|[[:space:]])+"))

preprocess_text <- function(texts) #, sparse.rate)
{
    corpus <- Corpus(VectorSource(texts))
    
    tdm <- TermDocumentMatrix(corpus, 
                              control=list(#tokenize = strsplit_space_tokenizer,
                                  stemming = T,
                                  tolower = T,
                                  removePunctuation = T,
                                  removeNumbers = T,
                                  stopwords=stopwords("SMART")))
    
    
    #    tdm <- removeSparseTerms(tdm, sparse.rate)
    
    return(tdm)
}

preprocess_text_test <- function(texts) #, sparse.rate)
{
    corpus <- Corpus(VectorSource(texts))
    
    test.tdm <- TermDocumentMatrix(corpus, 
                                   control=list(#tokenize = strsplit_space_tokenizer,
                                       dictionary = Terms(tdm.train), 
                                       stemming = T,
                                       tolower = T,
                                       removePunctuation = T,
                                       removeNumbers = T,
                                       stopwords=stopwords("SMART")))
    
    test.dtm <- as.DocumentTermMatrix(test.tdm)
    
    #   test.dtm <- removeSparseTerms(test.dtm, sparse.rate)
    
    return(test.dtm)
}

setwd("~/Dropbox/repo/r_basic/sentiment_analysis/")

### 영화 
fileName <- "data/IMDBmovie/labeledTrainData.tsv"
data <- read.csv(fileName, header=T, sep="\t", quote="")
data <- data[1:10000, ] ## 테스트 위해서는 10000개만 

totalNum <- 1:nrow(data)
set.seed(12345)
shuffledNum <- sample(totalNum, nrow(data), replace = F)
trainingNum <- shuffledNum[1:7000]
testNum <- shuffledNum[7001:10000]

train.data <- data[trainingNum, ]
test.data <- data[testNum, ]

#sparse.rate <- .9999
tdm.train <- preprocess_text(train.data$review) #, sparse.rate)

# NOTE: 여기서 상위 10000단어만 자를거면 removeSparseTerms를 쓸 필요가 있나? -> removeSparseTerms 삭제
library(slam)
word.count = as.array(rollup(tdm.train, 2))
word.order = order(word.count, decreasing = T)
freq.word = word.order[1 : 10000]
tdm.train <- tdm.train[freq.word, ]

library(glmnet)

#cv.cvm.min <- c() ## Validation set의 mse 최소값 저장
# alphas <- seq(from = 0, to = 1, by = .2) ## 그냥 alpha를 고정할까..
# cv.res <- list()
# 
# for (i in 1:length(alphas))
# {
#     cv.res[[i]] <- cv.glmnet(as.matrix(t(tdm.train)), train.data$sentiment, 
#                         type.measure="auc", 
#                         nfolds = 4,
#                         family="binomial", 
#                         alpha = alphas[i]) ## alpha를 어떻게 할 것인가
#     
#     cv.cvm.min[i] <- cv.res[[i]]$cvm[which.min(cv.res[[i]]$cvm)]
# }

#alphas[which.min(cv.cvm.min)]
#res.coef <- coef(cv.res[[which.min(cv.cvm.min)]], s = "lambda.min")

alpha <- .2 # 그냥 알파 고정
cv.res <- cv.glmnet(as.matrix(t(tdm.train)), train.data$sentiment, 
                    type.measure = "auc", 
                    nfolds = 4,
                    family = "binomial", 
                    alpha = alpha)

res.coef <- coef(cv.res, s = "lambda.min") # res.coef[1:6,1]
res.coef.num <- res.coef[,1]

posword <- sort(res.coef.num[res.coef.num > 0], decreasing = T)
head(posword, 10)

negword <- sort(res.coef.num[res.coef.num < 0], decreasing = T)
head(negword, 10)

library(tm.plugin.sentiment)
train.sentiScore <- polarity(tdm.train, names(posword), names(negword))

cor(train.sentiScore, data$sentiment[trainingNum], use = "complete")

#library(ROCR)

 findCutpoint <- function(predSentiment, dataSentiment)
 {
     pred <- prediction(predSentiment, dataSentiment)
     perf <- performance(pred,"tpr", "fpr")
     auc <- performance(pred,"auc")
     auc <- unlist(slot(auc, "y.values"))
     acc <- performance(pred,"acc")
     cutpoint <- unlist(slot(acc, "x.values"))[which.max(unlist(slot(acc, "y.values")))]
     return(cutpoint)
 }
 
# cutpoint <- findCutpoint(sentiScore, data$sentiment[trainingNum])

library(pROC)
train.roc <- roc(data$sentiment[trainingNum], train.sentiScore)

plot(train.roc, print.auc=TRUE, auc.polygon=TRUE, grid=c(0.1, 0.2),
     grid.col=c("green", "red"), max.auc.polygon=TRUE,
     auc.polygon.col="blue", print.thres=TRUE)

test.dtm <- preprocess_text_test(data$review[testNum]) #, sparse.rate)

test.sentiScore <- polarity(test.dtm, names(posword), names(negword))

cor(test.sentiScore, data$sentiment[testNum], use = "complete")

# pred <- prediction(sentiScore, data$sentiment[testNum])
# #pred <- prediction(result, data$sentiment[testNum])
# perf <- performance(pred,"tpr", "fpr")
# auc <- performance(pred,"auc")
# auc <- unlist(slot(auc, "y.values"))
# acc <-performance(pred,"acc")
# 
# plot(perf, col="red", lty=1)
# curve(x+0, add=T)
# auc.name = round(auc, 3)
# legend(.7, .5, auc.name,lty=1,col=c("red"),cex=.7)    

test.roc <- roc(data$sentiment[testNum], test.sentiScore)
plot(test.roc, print.auc=TRUE, auc.polygon=TRUE, grid=c(0.1, 0.2),
     grid.col=c("green", "red"), max.auc.polygon=TRUE,
     auc.polygon.col="blue", print.thres=TRUE)

test.sentiScore.b <- rep(0, length(test.sentiScore))
test.sentiScore.b[test.sentiScore >= cutpoint] <- 1

library(caret)
confusionMatrix(test.sentiScore.b, data$sentiment[testNum])


################# 다른 곳에 적용
library(XML)
library(rvest)

posfileName <- sprintf("%s%s", getwd(), "/data/books/positive.review")
data.pos <- htmlParse(posfileName)
titles <- data.pos %>% html_nodes("title") %>% html_text()
texts <- data.pos %>% html_nodes("review_text") %>% html_text()
points <- data.pos %>% html_nodes("rating") %>% html_text()
bpoints <- rep(1, length(points))
dt.pos <- data.frame(titles, texts, points, bpoints)

negfileName <- sprintf("%s%s", getwd(), "/data/books/negative.review")
data.neg <- htmlParse(negfileName)
titles <- data.neg %>% html_nodes("title") %>% html_text()
texts <- data.neg %>% html_nodes("review_text") %>% html_text()
points <- data.neg %>% html_nodes("rating") %>% html_text()
bpoints <- rep(0, length(points))

dt.neg <- data.frame(titles, texts, points, bpoints)
dt <- rbind(dt.pos, dt.neg)

library(stringr)
dt$titles <- str_replace_all(dt$titles, "\n", "")
dt$texts <- str_replace_all(dt$texts, "\n", "")
dt$points <- str_replace_all(dt.pos$points, "\n", "") %>% as.numeric()

#sparse.rate <- .9999

library(tm)

test.dtm <- preprocess_text_test(dt$texts)# , sparse.rate)

test.sentiScore <- polarity(test.dtm, names(posword), names(negword))
# pred <- prediction(sentiScore, dt$bpoints)
# perf <- performance(pred,"tpr", "fpr")
# auc <- performance(pred,"auc")
# auc <- unlist(slot(auc, "y.values"))
# acc <-performance(pred,"acc")
# 
# plot(perf, col="red", lty=1)
# curve(x+0, add=T)
# auc.name = round(auc, 3)
# legend(.7, .5, auc.name,lty=1,col=c("red"),cex=.7)    

test.roc <- roc(dt$points, test.sentiScore)
plot(test.roc, print.auc=TRUE, auc.polygon=TRUE, grid=c(0.1, 0.2),
     grid.col=c("green", "red"), max.auc.polygon=TRUE,
     auc.polygon.col="blue", print.thres=TRUE)

test.sentiScore.b <- rep(0, length(test.sentiScore))
test.sentiScore.b[test.sentiScore >= 0] <- 1

library(caret)
confusionMatrix(test.sentiScore.b, dt$bpoints)


# dataset2 <- as.data.frame(data$review[testNum])
# sent_dict_data <- data.frame(word = c(names(posword), names(negword)), polarity = c(rep(1, length(posword)), rep(-1, length(negword))))
# 
# library(hash)
# negation_word <- c("not","nor", "no")
# result <- c()
# sent_dict <- hash()
# sent_dict <- hash(sent_dict_data$word, sent_dict_data$polarity)
# 
# library(stringr)
# #  compute sentiment score for each document
# for (m in 1:nrow(dataset2)){
#     polarity_ratio <- 0
#     polarity_total <- 0
#     not <- 0
#     sentence <- tolower(dataset2[m,1])
#     if (nchar(sentence) > 0){
#         token_array <- scan_tokenizer(sentence)
#         for (j in 1:length(token_array)){
#             word = str_replace_all(token_array[j], "[^[:alnum:]]", "")
#             for (k in 1:length(negation_word)){
#                 if (word == negation_word[k]){
#                     not <- (not+1) %% 2
#                     
#                 }
#             }
#             if (word != ""){
#                 if (!is.null(sent_dict[[word]])){
#                     polarity_ratio <- polarity_ratio + (-2*not+1)*sent_dict[[word]]
#                     polarity_total <- polarity_total + abs(sent_dict[[word]])
#                 }
#             }
#             
#         }
#     }
#     if (polarity_total > 0){
#         result <- c(result, polarity_ratio/polarity_total)
#     }else{
#         result<- c(result,0)
#     }
# }