library(understatr) # > main

# get_match_id function, with tryCatch wrapper to handle http:404 errors
get_match_ids <- function(x) {
  tryCatch(return (unique(dplyr::select(get_match_shots(match_id = x), match_id, h_team, a_team))),
           error = function(e) {})
}

# loop to get all match ids - this takes a lot of time
match_ids <- data.frame(match_id=numeric(0), h_team=character(0), a_team=character(0), stringsAsFactors=FALSE)
for (i in c(1:20000)){
  match_ids <- rbind(match_ids, get_match_ids(i))
}

# add league_name & season to match_ids
# A- Add league name
# 1- loop over leageus_meta
# 2- get all get_league_teams_stats
# 3- simplify get_league_teams_stats to get team, league, year
# 4- join on h_team
# 5- assign league name
leagues_teams <- data.frame()
for (i in c(1:nrow(leagues_meta))) {
  print(as.data.frame(leagues_meta[i,c("league_name", "year")]))
  league_teams_x <- unique(get_league_teams_stats(as.character(leagues_meta[i,"league_name"]), 
                                                  as.numeric(leagues_meta[i,"year"]))[,c('team_name', 'league_name')])
  leagues_teams <- data.frame(unique(rbind(leagues_teams, league_teams_x)), stringsAsFactors = FALSE)
}

match_ids <- dplyr::left_join(match_ids, leagues_teams, by = c('h_team' = 'team_name'))

# B- Add season
# 1- create date column
# 2- loop over match_ids
# 3- get match date using get_match_shots
# 4- assign date to dataframe
# 5- from date get season
match_ids$date <- as.character(0)
class(match_ids$date) <- "Date"
for (i in c(6996:nrow(match_ids))){
  print(i)
  date_x <- data.frame(get_match_shots(match_id = match_ids[i,]$match_id)[1,'date'])
  match_ids[i,]$date <- as.Date(date_x$date)
}

match_ids$season <- vapply(
  X = match_ids$date,
  FUN = function(matchdate){
    if((matchdate > as.Date('2014-07-01')) & (matchdate < as.Date('2015-06-01'))){
      return ('2014/15')
    } else if ((matchdate > as.Date('2015-07-01')) & (matchdate < as.Date('2016-06-01'))) {
      return ('2015/16')
    } else if ((matchdate > as.Date('2016-07-01')) & (matchdate < as.Date('2017-06-01'))) {
      return ('2016/17')
    } else if ((matchdate > as.Date('2017-07-01')) & (matchdate < as.Date('2018-06-01'))) {
      return ('2017/18')
    } else if ((matchdate > as.Date('2018-07-01')) & (matchdate < as.Date('2019-06-01'))) {
      return ('2018/19')
    } else if ((matchdate > as.Date('2019-07-01')) & (matchdate < as.Date('2020-06-01'))) {
      return ('2019/20')
    } else {
      return ('NA')
    }
  },
  FUN.VALUE = character(1)
)

# save for-loop results
write.csv(match_ids, file='match_ids.csv')


