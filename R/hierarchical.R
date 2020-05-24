# read data
playerShotProfiles19_2M <- retrieveShots('Bundesliga', 2019)

# set seed
set.seed(823)

# convert heights of dendograms to a common scale
fixClustHeight <- function(v_dist, v_hclust, listClust){
  for(j in v_dist) for(k in v_hclust) listClust[[j]][[k]]$height <- rank(listClust[[j]][[k]]$height)
  return (listClust)
}

# plot all hierarchical clusters
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

# get cluster coefficients
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

# plot specific cluster
plotSpecificClust <- function(M_coef, functional){
  outlier_algo <- rownames(M_coef)[which(M_coef == get(functional)(M_coef), arr.ind = TRUE)[1]]
  outlier_dist <- colnames(M_coef)[which(M_coef == get(functional)(M_coef), arr.ind = TRUE)[2]]
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

# MAIN
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
plotSpecificClust(M_coef, 'min')
plotSpecificClust(M_coef, 'max')

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
plotSpecificClust(M_coef, 'min')
plotSpecificClust(M_coef, 'max')
