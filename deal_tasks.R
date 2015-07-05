daysHash <- new.env(hash = T)

for (i in 1:7)
{
    assign(as.character(i), c("월", "화", "수", "목", "금", "토", "일")[i], envir = daysHash)
}

set.seed(12345)
days <- unlist(mget(as.character(ceiling(runif(500*5, 0, 7))), envir = daysHash))

sexHash <- new.env(hash = T)
for (i in 1:2)
{
    assign(as.character(i), c("남", "여")[i], envir = sexHash)
}

set.seed(12345)
sex <- unlist(mget(as.character(ceiling(runif(500*5, 0, 2))), envir = sexHash))

set.seed(12345)
salesNum <- ceiling(runif(500*5, 0, 50000))

###########




