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
