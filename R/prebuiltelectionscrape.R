# # script pre built to download and store the data for 2CP in house elections
#
# # full fed House elections...
#
# house_elections<-rjson::fromJSON(file=url)|>dplyr::bind_rows()|>
#   dplyr::filter(is.na(Division)& Reps==T)|>dplyr::select(-`$id`)
#
# house_elections_list<- list()
# url<-paste0("https://handbookapi.aph.gov.au/api/Elections/Divisions?year=", house_elections$Year)
#
# for (i in 1:nrow(house_elections)){
#   house_elections_list[[i]]<- rjson::fromJSON(file=url[i])|>dplyr::bind_rows()
# }
#
# try_url <- function(url){
#   out<-tryCatch(
#     {
#       rjson::fromJSON(file=url)
#     },
#     error = function(cond){
#       message(paste0('server error. Electorate: ', house_elections_list[[i]]$Name[j],
#                      ". Election: ",house_elections$Year[i]))
#       return(character(0))
#     }
#   )
#   return(out)
# }
#
# list_2cp<-list()
# count<-1
# for(i in 1:38){
#
#   print(paste0("Election Year = ",house_elections$Year[i]))
#   for(j in 1:nrow(house_elections_list[[i]])){
#
#     url<- paste0("https://handbookapi.aph.gov.au/api/Elections/TwoCandidatePreferred?divisionName=",house_elections_list[[i]]$Name[j], "&year=",house_elections$Year[i],"&electionId=undefined")
#     url<- gsub(" ", "%20", url)
#     dat<-try_url(url)
#
#     if(length(dat)>0){
#       dat<- dat|>dplyr::bind_rows()|>dplyr::select( -`$id`, -Id)
#
#       division<-house_elections_list[[i]][j,]|>dplyr::select(Id, Name, State)
#
#       line<-dplyr::bind_cols(division, Year=house_elections$Year[i], ElectionID=house_elections$Id[i], dat)|>
#         dplyr::rename("votes_2cp"=Votes, "margin_2cp"=Margin,
#                       "margin_percentage_2cp"=ThisElectionPercentage,
#                       'swing_2cp'=Swing)
#
#       list_2cp[[count]]<- line
#       count<-count+1
#
#     }else(print(paste0("Missing division: ",
#                  house_elections_list[[i]]$Name[j],
#                  ". Election: ",house_elections$Year[i])))
#
#   }
# }
#
# main_elections_2cp<-dplyr::bind_rows(list_2cp)
#
#
#
# readr::write_csv(main_elections_2cp,file="inst/extdata/main_elections_2cp.csv")
#
# # fed byelections
#
# list_by<-list()
#
# url<- "https://handbookapi.aph.gov.au/api/Elections/Elections"
#
# byelections <-rjson::fromJSON(file=url)|>dplyr::bind_rows()|>
#   dplyr::filter(!is.na(Division))|>dplyr::select(-`$id`)
#
# for(i in 1:nrow(byelections)){
#   url<- paste0("https://handbookapi.aph.gov.au/api/Elections/TwoCandidatePreferred?divisionName=",byelections$Division[i], "&year=",byelections$Year[i],"&electionId=undefined")
#   url<- gsub(" ", "%20", url)
#   dat<-try_url(url)
#
#   if(length(dat)>0){
#     dat<- dat|>dplyr::bind_rows()|>dplyr::select( -`$id`, -Id)
#
#     division<-byelections[i,]|>dplyr::select(Division, Year)|>
#       dplyr::rename("Name"=Division)
#
#     line<-dplyr::bind_cols(division, State=NA,ElectionID=byelections$Id[i], dat, source=NA)|>
#       dplyr::rename("votes_2cp"=Votes, "margin_2cp"=Margin,
#                     "margin_percentage_2cp"=ThisElectionPercentage,
#                     'swing_2cp'=Swing )
#
#
#     list_by[[i]]<- line
#
#   }else(print(paste0("Missing division: ",
#                      byelections$Division[i],
#                      ". Election: ",byelections$Year[i])))
# }
#
# dplyr::bind_rows(list_by)
#
#
# byelections_merge<- byelections |>dplyr::select(Id, Division, Year) |>
#   dplyr::rename("Name"=Division)|>
#   dplyr::left_join(dplyr::bind_rows(list_by)) |>
#   dplyr::mutate(Note=dplyr::case_when(is.na(Party)~"Missing 2cp from by-election"))
#
#
#
# byelections_merge<- byelections_merge|>
#   dplyr::select("Id","Name", "State","Year","ElectionID",
#                 "Candidate","Party",  "votes_2cp", "margin_2cp",
#                 "margin_percentage_2cp", "swing_2cp" ,"Status", "source", "Note" )
#
# readr::write_csv(byelections_merge,file="inst/extdata/by_elections_2cp.csv")
#
