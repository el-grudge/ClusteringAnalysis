# 3 deliverables: 1- match_shots.csv; 2- all_team_stats.csv; 3- match_ids.csv

# Setup:
# 1- get all match shots
# 2- get all team league stats
# 3- get match_ids by joining 1 & 2
# 4- get notMatchIds
# 5- repeat steps 1-4 non notMatchIds

# get all match shots
getMatchShots <- function(numberOfMatches){
  # get_match_id function with tryCatch wrapper to handle http:404 errors
  get_all_shots <- function(x) {
    tryCatch(return (get_match_shots(match_id = x)),
             error = function(e) {})
  }
  # loop to get all match shots - this takes a lot of time
  match_shots <- data.frame(stringsAsFactors=FALSE)
  for (i in numberOfMatches){
    print(i)
    match_shots <- data.frame(rbind(match_shots, get_all_shots(i)))
  }
  match_shots$date <- as.Date(match_shots$date)
  return (match_shots)
}

# get all teams and seasons
getAllTeamStats <- function(leagues, leagues_meta){
  all_team_stats <- data.frame(stringsAsFactors = FALSE)
  for (i in leagues){
    all_team_stats <- data.frame(rbind(all_team_stats, (get_league_teams_stats(league_name = leagues_meta[i,'league_name'], year = leagues_meta[i,'year']))))
  }
  return (all_team_stats)
}

# get all match_ids - always needs validation
getMatchIds <- function(matchShots, allTeamStats, joinCondition){
  match_ids <- left_join(
    unique(matchShots),
    unique(allTeamStats),
    by=joinCondition
  )
  match_ids <- match_ids[order(match_ids$year, match_ids$league_name),]
  write.csv(match_ids, file='match_ids.csv')
  return(match_ids)
}

# get data using previously defined functions
getData <- function(updateFile=FALSE, missingMatchIds=c()){
  # get meta seasons
  leagues_meta <- get_leagues_meta()
  leagues_meta <- as.data.frame(leagues_meta)
  
  # declarations
  numberOfMatches <- c(1:(nrow(leagues_meta)*380))
  leagueSeason <- c(1:nrow(leagues_meta))
  
  matchShots <- data.frame()
  allTeamStats <- data.frame()
  matchIds <- data.frame()
  
  # 1- get all teams and seasons
  # input for getAllTeamStats function in step two call getAllTeamStats 
  allTeamStats <- getAllTeamStats(leagueSeason, leagues_meta)
  
  matchShotsColumns <- c('match_id', 'h_team', 'a_team', 'date')
  allTeamStatsColumns <- c('team_name', 'league_name', 'year', 'date')
  joinCondition <- c('h_team'='team_name', 'date')
  
  if (updateFile){
    # read from files
    matchShots <- unique(read.csv('data/matchShots.csv', stringsAsFactors=FALSE, colClasses=c('date'='Date')))
    matchIds <- unique(read.csv('data/matchIds.csv', stringsAsFactors=FALSE, colClasses=c('date'='Date')))
    
    # get notMatchIds
    if (length(missingMatchIds) > 0){
      notMatchIds <- missingMatchIds
    } else {
      notMatchIds <- numberOfMatches[!(numberOfMatches %in% matchIds$match_id)]
    }
    
    # repeat 1-4 with notMatchIds
    missingShots <- getMatchShots(notMatchIds)
    before <- nrow(matchIds)
    # combine old and new
    matchShots <- unique(rbind(matchShots, missingShots))
    matchIds <- unique(getMatchIds(
      matchShots[,matchShotsColumns], 
      allTeamStats[,allTeamStatsColumns], 
      joinCondition
    ))
    after <- nrow(matchIds)
    print(paste('before:', before, sep=' '))
    print(paste('after:', after, sep=' '))
    
  } else {
    
    # 2- get all match shots
    # input for getMatchShots function in step one call getMatchShots 
    matchShots <- unique(getMatchShots(numberOfMatches))
    
    # 3- get all match_ids - always needs validation
    matchIds <- unique(getMatchIds(
      matchShots[,matchShotsColumns], 
      allTeamStats[,allTeamStatsColumns], 
      joinCondition
    ))
    
  }
  
  write.csv(matchShots, file='data/matchShots.csv', row.names=FALSE)
  write.csv(allTeamStats, file='data/allTeamStats.csv', row.names=FALSE)
  write.csv(matchIds, file='data/matchIds.csv', row.names=FALSE)

}