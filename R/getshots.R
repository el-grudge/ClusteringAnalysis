# 1- Collect shot data for all teams throughout season
# read match_ids from saved file
match_ids <- read.csv('data/match_ids.csv', stringsAsFactors = FALSE)
bundesliga19_ids_M <- match_ids[match_ids$league_name=='Bundesliga' & substring(match_ids$season,1,4)=='2019',]
bundesliga19_shots_M <- data.frame()
for (i in c(1:nrow(bundesliga19_ids_M))){
  bundesliga19_shots_M <- rbind(bundesliga19_shots_M,data.frame(get_match_shots(match_id = bundesliga19_ids_M$match_id[i])))
}
bundesliga19_shots_M <- data.frame(bundesliga19_shots_M, stringsAsFactors = FALSE)

# verify
View(bundesliga19_shots_M)
length(unique(bundesliga19_shots_M$match_id))
write.csv(bundesliga19_shots_M, file='bundesliga19_shots_M.csv', row.names = FALSE)

# Dataframe construction
# final dataframe will have the following shape: team_name, "a list of shot attributes"
# list of shot attributes: shot count per 90, goals scored per 90, xG per 90, avg shot dist, "situational list", "last action list"
# shot count per 90 = avg(shotcountpermatch)
# goals scored per 90 = avg(goalsscoredpermatch)
# xG per 90 = avg(xGpermatch)
# avg shot dist = avg(avgshotdistancepermatch) * shot dist needs to be calculated first using X, Y coord
# situations (groupby) = avg(count per situation type)

# create new column 'team', which corresponds to h_team when h and a_team when a
bundesliga19_shots_M <- read.csv('data/bundesliga19_shots_M.csv', stringsAsFactors = FALSE)
bundesliga19_shots_M <- mutate(bundesliga19_shots_M,
                               team=ifelse(h_a=='h', h_team, a_team),
                               X=X*100,
                               Y=Y*100,
                               dist=sqrt(((X-100) * 1.05)^2 + ((Y-50) * 0.68)^2))

# player shot profiles
playerShotProfiles19_M <- data.frame(bundesliga19_shots_M %>%
                                       filter(result!='OwnGoal') %>%
                                       group_by(match_id, player) %>%
                                       summarise(shotCount=n(),
                                                 goalsScored=n_distinct(id[result=='Goal']),
                                                 xG=sum(xG),
                                                 avgShotDist=mean(dist),
                                                 openPlay=n_distinct(id[situation=='OpenPlay']),
                                                 setPiece=n_distinct(id[situation=='SetPiece']),
                                                 penalty=n_distinct(id[situation=='Penalty']),
                                                 fromCorner=n_distinct(id[situation=='FromCorner']),
                                                 directFK=n_distinct(id[situation=='DirectFreekick']),
                                                 rightFoot=n_distinct(id[shotType=='RightFoot']),
                                                 leftFoot=n_distinct(id[shotType=='LeftFoot']),
                                                 head=n_distinct(id[shotType=='Head'])
                                       ) %>%
                                       group_by(player) %>%
                                       summarise(
                                         shotCount=mean(shotCount),
                                         totalGoalsScored=sum(goalsScored),
                                         xG=mean(xG),
                                         avgShotDist=mean(avgShotDist),
                                         openPlay=mean(openPlay),
                                         setPiece=mean(setPiece),
                                         penalty=mean(penalty),
                                         fromCorner=mean(fromCorner),
                                         directFK=mean(directFK),
                                         rightFoot=mean(rightFoot),
                                         leftFoot=mean(leftFoot),
                                         head=mean(head)
                                       ) %>%
                                       arrange(desc(totalGoalsScored)))

write.csv(playerShotProfiles19_M, file='data/playerShotProfiles19_M.csv', row.names = FALSE)
