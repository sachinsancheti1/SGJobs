mtr = readRDS("extracted.rds")
mtr1 = as.data.frame(apply(mtr,2,function(x) as.character(x)))
mtr2 = as.data.frame(apply(mtr1,2,function(x) gsub('\t|\n', ' ',x)))
class(mtr[,1])
write.csv(mtr2,file = "extracted.csv")

