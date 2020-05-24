# Cluster Analysis

## Part 1 – Partitioning

In this assignment, we will analyze the shots data for Bundesliga (German soccer league) season 2019/20. We will be using the understatr package to get the data, specifically the get_match_shots(match_id=) function. The function retrieves all the shots in a given match, and it specifies a number of attributes (such as: player who took the shot, the X & Y coordinates of the position where the shot was taken, the body part used to take the shot) for each shot.

We retrieve all the shots of all matches of the seasons, then apply some aggregate functions to have a 'per player' dataset. The final data set looks like this:

![alt text](./images/playerstable.png)

The numbers shown in the table are 'per match' averages, except for the 'totalGoalsScored' column. For example, Robert Lewandowski who has scored 25 goals, takes 469 shots per match, with an average expected goal value of 1.02, from an average distance of 12.90 meters, etc.

The final dataset is available in the data/playerShotProfiles19_M.csv file. However, if you can retrieve them using the understatr package by running steps 1 & 2 in main.R, which are currently hashed, just note that this process takes a very long time. 

### Step 1: Decide Best K

*I- Elbow Plots*

![alt text](./images/elbowplot.png)

According to these plots we can say the following about the best k for each algorithm:

* k-means → 3
* clara → 3
* fanny → 4
* pam → 4

*II- Silhouette*

![alt text](./images/silhouette.png)

According to these plots we can say the following about the best k for each algorithm:

* k-means → 3
* clara → 2
* fanny → 7
* pam → 2

*III- Gap Stat*

![alt text](./images/gap_stat.png)

According to these plots we can say the following about the best k for each algorithm:

* k-means → 4
* clara → 4
* fanny → 3
* pam → 4

According to these figures, we'll try k= 2,3,4,7.

### Step 2: Diagnostics

I- Using clusplot

*k = 2*

![alt text](./images/clusplot_2.png)

*k = 3*

![alt text](./images/clusplot_3.png)

*k = 4*

![alt text](./images/clusplot_4.png)

*k = 7*

![alt text](./images/clusplot_7.png)


According to these plots, we can say that pam with k=3 is the best clustering algorithm, as it has the least overlap.

II- Using plotcluster

*k = 2*

![alt text](./images/plotcluster_2.png)

*k = 3*

![alt text](./images/plotcluster_3.png)

*k = 4*

![alt text](./images/plotcluster_4.png)

*k = 7*

![alt text](./images/plotcluster_7.png)

According to these plots, we can say that k-means with k=3 has the least overlap, and clara with k=3 has the least amount of outliers.

III- Using fviz_cluster

*k = 2*

![alt text](./images/fviz_cluster_2.png)

*k = 3*

![alt text](./images/fviz_cluster_3.png)

*k = 4*

![alt text](./images/fviz_cluster_4.png)

*k = 7*

![alt text](./images/fviz_cluster_7.png)

According to these plots, we can say that k-means with k=3 is the best clustering algorithm, as it has the least overlap.

**Based on this analysis, we decide that k-means with k=3 is the best algorithm for our dataset.**


## Part 2 – Hierarchical Clusteringi

We will be using the hclust and agnes algorithms in this analysis.

Also, we will be using the complete, average and single methods, as the other methods do not apply to agnes.

Finally, we will be using the canberra, manhattan, euclidean, maximum, and minimum distance metrics.

I- hclust

*All dendograms*

![alt text](./images/hclust_all.png)

*Outlier dendogram*

![alt text](./images/hclust_outlier.png)

*Even dendogram*

![alt text](./images/hclust_even.png)

*II- agnes*

*All dendograms*

![alt text](./images/agnes_all.png)

*Outlier dendogram*

![alt text](./images/agnes_outlier.png)

*Even dendogram*

![alt text](./images/agnes_even.png)

**Based on these plots, we decide that:**

**The best algorithm for outlier detection is: hclust, with canberra distance metric, and using the single method.**

**The best algorithm for even clustring is: agnes, with manhattan distance metric, and using the complete method.**


## Appendix 1: Code
```
# LOADING LIBRARIES
# data source
#install.packages('remotes')
#remotes::install_github('ewenme/understatr')
library(understatr)

# data manipulation
library(dplyr)

# data visualization
library(ggplot2)
library(ggforce)
library(viridis)
library(qgraph)
library(ggrepel)
library(gridExtra)

# clustering
library(cluster)

# diagnostics
library(factoextra)
library(useful)
library(fpc)


# utility functions
plotOptimalK <- function(algoList, plotMethod, M){
  diagnosticPlots <- c()
  diagnosticPlots <- lapply(
    X = algoList,
    FUN = function(algo) fviz_nbclust(
      x = M,
      FUNcluster = get(algo),
      method = plotMethod,
      verbose = F
    ) + 
      labs(title=algo)
  )
  n <- length(diagnosticPlots)
  nCol <- floor(sqrt(n))
  return (do.call("grid.arrange", c(diagnosticPlots, ncol=nCol)))
}

fixClustHeight <- function(v_dist, v_hclust, listClust){
  for(j in v_dist) for(k in v_hclust) listClust[[j]][[k]]$height <- rank(listClust[[j]][[k]]$height)
  return (listClust)
}

plotHClust <- function(v_dist, v_hclust, listClust){
  par(
    mfrow = c(length(v_dist),length(v_hclust)),
    mar = c(0,0,0,0),
    mai = c(0,0,0,0),
    oma = c(0,0,0,0)
  )
  for(j in v_dist) for(k in v_hclust) {
    plot(
      x = listClust[[j]][[k]],
      labels = FALSE,
      axes = TRUE,
      main=''
    )
    title(main=paste(j,k,coef(listClust[[j]][[k]]), sep=' '), line=-0.7)
  }
}

getClustCoeffs <- function(v_dist, v_hclust, listClust) {
  M_coef <- matrix(
    data = NA,
    nrow = length(v_dist),
    ncol = length(v_hclust)
  )
  rownames(M_coef) <- v_dist
  colnames(M_coef) <- v_hclust
  for(j in v_dist) for(k in v_hclust) try({
    M_coef[j,k] <- coef(
      object = listClust[[j]][[k]]
    )
  })
  return (M_coef)
}

plotOutlierClust <- function(M_coef){
  outlier_algo <- rownames(M_coef)[which(M_coef == min(M_coef), arr.ind = TRUE)[1]]
  outlier_dist <- colnames(M_coef)[which(M_coef == min(M_coef), arr.ind = TRUE)[2]]
  par(mfrow=c(1,1))
  plot(
    x = list_hclust[[outlier_algo]][[outlier_dist]],
    labels = FALSE,
    axes=TRUE,
    sub = "",
    main=""
  )
  title(paste(outlier_algo, outlier_dist, min(M_coef), sep=' '), line=-1)
}

plotEvenClust <- function(M_coef){
  even_algo <- rownames(M_coef)[which(M_coef == max(M_coef), arr.ind = TRUE)[1]]
  even_dist <- colnames(M_coef)[which(M_coef == max(M_coef), arr.ind = TRUE)[2]]
  par(mfrow=c(1,1))
  plot(
    x = list_hclust[[even_algo]][[even_dist]],
    labels = FALSE,
    axes=TRUE,
    sub = "",
    main=""
  )
  title(paste(even_algo, even_dist, max(M_coef), sep=' '), line=-1)
}

# Data loading
# To load data from original source unhash the following line (note: it takes a long time)
#source('loading_data.R')

# Otherwise, you can read the data directly from a saved file
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

# B- HIERARCHICAL
# set seed
set.seed(823)

# create dist vector
v_dist <- c("canberra","manhattan","euclidean","maximum","minkowski")
list_dist <- lapply(
  X = v_dist,
  FUN = function(distance_method) dist(
    x = M,
    method = distance_method
  )
)
names(list_dist) <- v_dist

# hclust
v_hclust <- c('complete', 'average', 'single')
list_hclust <- list()
for(j in v_dist) for(k in v_hclust) list_hclust[[j]][[k]] <- hclust(
  d = list_dist[[j]],
  method = k
)
list_hclust <- fixClustHeight(v_dist, v_hclust, list_hclust)
plotHClust(v_dist, v_hclust, list_hclust)
M_coef <- getClustCoeffs(v_dist, v_hclust, list_hclust)
plotOutlierClust(M_coef)
plotEvenClust(M_coef)


# agnes
v_hclust <- c('complete', 'average', 'single')
list_agnes <- list()
for(j in v_dist) for(k in v_hclust) list_agnes[[j]][[k]] <- agnes(
  M,
  metric = j,
  method = k
)
list_agnes <- fixClustHeight(v_dist, v_hclust, list_agnes)
plotHClust(v_dist, v_hclust, list_agnes)
M_coef <- getClustCoeffs(v_dist, v_hclust, list_agnes)
plotOutlierClust(M_coef)
plotEvenClust(M_coef)

```

