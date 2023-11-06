library(httr)
library(here)

# get list of files in data folder on the wetlands-eval repo
req <- GET("https://api.github.com/repos/tbep-tech/wetlands-eval/git/trees/main?recursive=1")
stop_for_status(req)
filelist <- unlist(lapply(content(req)$tree, "[", "path"), use.names = F)
fls <- grep("data/", filelist, value = TRUE, fixed = TRUE)

for(fl in fls){

  cat(fl, '\n')

  # object name
  obj <- gsub('data/|\\.RData$', '', fl)

  # download file
  tmpfl <- paste(tempdir(), basename(fl), sep = '\\')
  dlurl <- paste0('https://github.com/tbep-tech/wetlands-eval/raw/main/', fl)
  download.file(dlurl, destfile = tmpfl)

  # load rdata and save to csv
  load(file = tmpfl)
  dat <- get(obj)
  write.csv(dat, paste0(obj, '.csv'), row.names = F)

  # zip csv
  zip::zip(paste0('data/', obj, '.zip'), paste0(obj, '.csv'))

  # clean up files
  file.remove(paste0(obj, '.csv'))
  unlink(tmpfl)
  torm <- ls()[!ls() %in% c('fls', 'fl')]
  rm(list = torm)

}
