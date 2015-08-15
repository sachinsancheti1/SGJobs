library(XML)
suppressPackageStartupMessages(library(dplyr))
library(tidyr)
library(stringr)
library(shiny)
library(bitops)
library(RCurl)
library(httr)
library(WriteXLS)
i = 1
parseIt <- function(x){
  x <- GET(x)
  cat("Status: ",x$status_code,'\n')
  htmlTreeParse(x, useInternalNodes = TRUE,isURL = TRUE)
}

testit <- function(x)
{
  p1 <- proc.time()
  Sys.sleep(x)
  proc.time() - p1 # The cpu usage should be negligible
}

mr1 = "http://job-search.jobstreet.com.sg/singapore/job-opening.php?area=1&option=1&specialization=185%2C186%2C187%2C188%2C189%2C190%2C195%2C200&job-source=1%2C64&classified=1&job-posted=0&sort=1&order=0&res-search=1&pg="
mr2 = "&src=16&srcr=12"
murl = paste0(mr1,"2",mr2)
ts <- tryCatch(parseIt(murl),
               error = function(e) NULL)
masterdata = data.frame(title=character())
while(!is.null(ts) && i <=300){
  ids1 = xpathApply(ts,"//div/div/div/div[@class='panel ']",fun = function(x) xmlChildren(x))
  title=lapply(ids1,FUN = function(x) xmlValue(x$div[["h4"]]))
  link=lapply(ids1,FUN = function(x) xmlAttrs(x$div[["h4"]][["a"]])["href"])
  company=lapply(ids1,FUN = function(x) xmlValue(x$div[["p"]][["a"]]))
  summary=lapply(ids1,FUN = function(x) xmlValue(x$div[["span"]]))
  dataset = cbind(title,link,company,summary,i) %>% as.data.frame
  masterdata = rbind(masterdata,dataset)
  i = i+1
  newlink = paste0(mr1,i,mr2)
  cat(paste0("Working on ",newlink,'\t'))
  ts <- tryCatch(parseIt(newlink),
                 error = function(e) NULL)
  cat('\n')
  testit(runif(1,3,10))
}
View(masterdata)
saveRDS(masterdata,"extracted.rds")


