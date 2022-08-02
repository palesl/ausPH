# # script to complete 2cp and election
#
# files<- list.files("inst/inputs/Election_2001", full.names = T)
#
# count<-1
# list2001_2cp<-list()
#
# for(s in 1:8){
#   dat<- readxl::read_excel(files[s])
#   div<- 'none'
#   state<- gsub(".xls","" ,list.files("inst/inputs/Election_2001")[s])
#
#   for (i in 1:nrow(dat)){
#
#     #division
#     if(length(grep("[A-z ]+\\([0-9]+\\)",dat[i,1], value=T))>0){
#       div<- grep("[A-z ]+\\([0-9]+\\)",dat[i,1], value=T)
#     }
#     div_id<- stringr::str_extract(div,"[0-9]+" )
#     div_electorate<- stringr::str_extract(div,"[A-z ]+" )|>trimws()
#
#     # 2cp results
#     twoCPblock<-character(0)
#     if(grepl("Full Distribution of Preferences",dat[i,1])){
#       twoCPblock<- dat[(i+1):(i+2),2:6]
#     }
#     if(length(twoCPblock)>0){
#       block<-dplyr::bind_cols(Id= div_id,
#                               Name = div_electorate,
#                               State = state,
#                               Year=2001,
#                               ElectionID=NA,
#                               twoCPblock[,1],
#                               twoCPblock[,2],
#                               twoCPblock[,3],
#                               margin_2cp = NA,
#                               twoCPblock[,4],
#                               twoCPblock[,5],
#                               Status = NA )|>
#         dplyr::rename("Candidate"=`...6`,
#                       "Party"=`...7`,
#                       "votes_2cp"=`...8`,
#                       "margin_percentage_2cp"=`...10`,
#                       "swing_2cp"=`...11`)
#       list2001_2cp[[count]]<- block
#       count<-1+count
#     }
#   }
# }
#
# out<- dplyr::bind_rows(list2001_2cp)
#
# readr::write_csv(out,file="inst/extdata/two_candidate_preferred/results_2001_2cp.csv")
#
