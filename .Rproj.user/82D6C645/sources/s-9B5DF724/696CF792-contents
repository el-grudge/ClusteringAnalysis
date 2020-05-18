# HCLUSTERING

# create distance matrix
#dist_M <- dist(M)

# build hierarchical clusters
# hclust_M <- hclust(dist_M)
# plot(hclust_M)

# cut dendogram
cutree_M <- cutree(
  tree = hclust_M,
  k = 4
)

# # plot clusters
# prcomp_M <- data.frame(
#   prcomp(
#     x = M,
#     center = FALSE,
#     scale. = FALSE
#   )$x[,1:2],
#   Name = filter(playerShotProfiles19_M, totalGoalsScored > 4)$player,
#   Goals = filter(playerShotProfiles19_M, totalGoalsScored > 4)$totalGoalsScored,
#   Cluster = as.character(cutree_M),
#   stringsAsFactors = FALSE
# )
# 
# require(ggplot2)
# ggplot(prcomp_M) + 
#   aes(x = PC1,y = PC2,size = Goals,color = Cluster,fill = Cluster,label = Name,group = Cluster) + 
#   geom_point() + 
#   ggrepel::geom_text_repel(color = "black",size = 3) + 
#   ggtitle("Scatter plot of decathlon principal components","Color corresponds to k-means cluster") + 
#   theme_bw() + 
#   theme(legend.position = "none")

# silhouette
silhouette_M <- cluster::silhouette(
  x = cutree_M,
  dist = dist_M
)
par(mfrow=c(1, 1))
plot(silhouette_M)


#######################################


# diana
list_diana <- list()
for(j in v_dist) list_diana[[j]] <- diana(
  M,
  metric = j
)
#coef.hclust(list_diana[[1]])
# list_diana <- fixClustHeight(v_dist, NULL, list_diana)
# plotHClust(v_dist, v_hclust, list_diana)
# M_coef <- getClustCoeffs(v_dist, NULL, list_agnes)
# plotOutlierClust(M_coef)
# plotEvenClust(M_coef)

# mona
# binary_M <- M
# for(j in 1:ncol(binary_M)) binary_M[,j] <- as.numeric(
#   binary_M[,j] > median(binary_M[,j])
# )
# list_mona <- mona(binary_M)
# #coef(list_mona)
