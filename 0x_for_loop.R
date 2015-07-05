fruits <- c("사과", "복숭아", "포도", "바나나")

## IF 문

ex <- c("사과", "키위")

ex %in% fruits

if (ex[1] %in% fruits) { ex[1] }

if (ex[2] %in% fruits) { ex[2] }


## FOR 문

for (i in fruits)
{
    i
}

for (i in fruits)
{
    print(i)
}

for (i in fruits)
{
    cat(i)
}

for (i in 1:length(fruits))
{
    print(i)
    print(fruits[i])
}

for (i in 1:length(fruits))
{
    print(paste(fruits[i], "맛있다"))
}

for (i in 1:length(fruits))
{
    if(i == 1 | i == 3)
    {
        print(paste(fruits[i], "맛있다"))
    } else {
        print(paste(fruits[i], "맛없다"))
    }
}

for (i in 1:length(fruits))
{
    if(i %in% c(1,3))
    {
        print(paste(fruits[i], "맛있다"))
    } else {
        print(paste(fruits[i], "맛없다"))
    }
}

for (i in 1:length(fruits))
{
    if(i %in% c(1,3))
    {
        print(paste(fruits[i], "맛있다"))
    } else {
        print(paste(fruits[i], "맛없다"))
    }
    break
}

###

fruitsN <- c(2, 3, 5, 4)

for (i in 1:length(fruits))
{
    print(paste(fruits[i], fruitsN[i], "맛있다"))
}

for (i in 1:length(fruits))
{
    print(paste(fruits[i], fruitsN[i], "개", "맛있다"))
}

for (i in 1:length(fruits))
{
    print(paste(fruits[i]," ", fruitsN[i], "개", " 맛있다", sep=""))
}


for (i in 1:length(fruits))
{
    print(sprintf("%s %03d개 맛있다", fruits[i], fruitsN[i]))
}




## While

i=0
while (i < 3)
{
    i = i+1
    print(i)
}
    
i=0
repeat
{
    i = i + 1
    print(i)
    if (i == 3) break
}


