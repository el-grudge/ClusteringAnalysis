# read data
playerShotProfiles19_M <- read.csv('data/playerShotProfiles19_M.csv', stringsAsFactors = FALSE)

# create clustering dataset
M <- playerShotProfiles19_M %>%
  select(-player, -penalty, -directFK, -totalGoalsScored)
rownames(M) <- playerShotProfiles19_M$player
M <- scale(M)

# set seed
set.seed(823)

# find best k
partition_algo <- c('kmeans', 'clara', 'fanny', 'pam')

# elbowplts
plotOptimalK(partition_algo, 'wss', M)

# silhoutte
#partition_algo <- c('kmeans', 'clara', 'pam')
plotOptimalK(partition_algo, 'silhouette', M)

# gap statistic
plotOptimalK(partition_algo, 'gap_stat', M)

# partition according to best n
kList <- c(2,3,4,7)
partitionings <- c()

for (i in c(1:length(kList))){
  k <- kList[i]
  clusters <- c()
  for (j in c(1:length(partition_algo))){
  clusters[[j]] <- get(partition_algo[j])(M, k)
  if (partition_algo[j] == 'kmeans') names(clusters[[j]])[1] <- 'clustering'
  }
  partitionings[[i]] <- clusters
  names(partitionings)[i] <- as.character(k)
}

# clusplot analysis
# 1- clusplot
par(mfrow=c(2, 2))
for (i in c(1:length(partitionings))){
  for (j in c(1:length(partitionings[[i]]))){
    clusplot(
      M,
      main=partition_algo[j],
      partitionings[[i]][[j]]$clustering,
      color=TRUE,
      shade=TRUE,
      lines=0,
      cex=0
    )
  }
}

# 2- plotcluster
par(mfrow=c(2, 2))
for (i in c(1:length(partitionings))){
  for (j in c(1:length(partitionings[[i]]))){
    plotcluster(
      x = M,
      clvecd = partitionings[[i]][[j]]$clustering,
      main = partition_algo[j]
    )
  }
}

# 3- fviz_cluster
for (i in c(1:length(partitionings))){
  plotList <- c()
  for (j in c(1:length(partitionings[[i]]))){
    plotList[[j]] <- 
    fviz_cluster(
      object = partitionings[[i]][[j]],
      data = M,
      geom = 'point'
    ) + 
      ggtitle(partition_algo[j]) +
      theme(legend.position='none')
  }
  n <- length(plotList)
  nCol <- floor(sqrt(n))
  do.call("grid.arrange", c(plotList, ncol=nCol))
}
