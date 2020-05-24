# LOADING LIBRARIES
source('R/libraries.R')
source('R/utils.R')

# LOADING DATA
source('R/loading_data.R')
#data_M <- getData(updateFile=FALSE)
missingMatchIds <- c(12637, 12639, 12640, 12643, 12638, 12644, 12642, 12645, 12641)
data_M <- getData(updateFile=TRUE)

matchShots <- read.csv('data/matchShots.csv', stringsAsFactors=FALSE, colClasses=c('date'='Date'))
allTeamStats <- read.csv('data/allTeamStats.csv', stringsAsFactors=FALSE, colClasses=c('date'='Date'))
matchIds <- read.csv('data/matchIds.csv', stringsAsFactors=FALSE, colClasses=c('date'='Date'))

# CLUSTERING
# A- PARTITIONING
source('R/partitioning.R')
# B- HIERARCHICAL
source('R/hierarchical.R')

