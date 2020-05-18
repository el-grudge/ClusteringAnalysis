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
      axes = FALSE,
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
    sub = "",
    main=""
  )
  title(paste(even_algo, even_dist, max(M_coef), sep=' '), line=-1)
}