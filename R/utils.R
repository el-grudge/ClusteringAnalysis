# get shots for specific league and season
retrieveShots <- function(leagueName, seasonYear){
  return (matchShots[matchShots$match_id %in% matchIds[(matchIds$league_name==leagueName) & 
                                                         (matchIds$year==seasonYear),'match_id'],] %>%
            mutate(team=ifelse(h_a=='h', h_team, a_team),
                   X=X*100,
                   Y=Y*100,
                   dist=sqrt(((X-100) * 1.05)^2 + ((Y-50) * 0.68)^2)) %>%
            filter(result!='OwnGoal') %>%
            group_by(player) %>%
            summarise(matchCount=length(unique(match_id)),
                      shotCount=n()/matchCount,
                      goalsScored=n_distinct(id[result=='Goal']),
                      xG=mean(sum(xG))/matchCount,
                      avgShotDist=mean(dist),
                      openPlay=n_distinct(id[situation=='OpenPlay'])/matchCount,
                      setPiece=n_distinct(id[situation=='SetPiece'])/matchCount,
                      penalty=n_distinct(id[situation=='Penalty'])/matchCount,
                      fromCorner=n_distinct(id[situation=='FromCorner'])/matchCount,
                      directFK=n_distinct(id[situation=='DirectFreekick'])/matchCount,
                      rightFoot=n_distinct(id[shotType=='RightFoot'])/matchCount,
                      leftFoot=n_distinct(id[shotType=='LeftFoot'])/matchCount,
                      head=n_distinct(id[shotType=='Head'])/matchCount
            ))
}
