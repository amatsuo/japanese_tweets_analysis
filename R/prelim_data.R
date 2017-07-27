library(data.table)
library(dplyr)
library(tidyjson)

file_names <- list.files("~/Desktop/temp/ja_kr_tweets", full.names = TRUE)
length(file_names)
#temp <- read.delim(file_names[1], as.is = TRUE, header = FALSE)[, 1]
#temp[1, ]


data_list <- list()
for(file_name in file_names){
  time_stamp <- sub(".+_(\\d+).+", "\\1", file_name)
  cat(Sys.time() %>% as.character(), ":", time_stamp, "\n")
  
  file_contents <- readLines(con = file_name)
  cat("Num Record:", length(file_contents), "\n")
  tmp_data <- file_contents %>% as.tbl_json() %>%  
    spread_values(id = jstring('id_str'),
                  text = jstring("text"),
                  created_at = jstring("created_at"),
                  user_id = jstring("user", "id_str"),
                  user_screen_name = jstring("user", "screen_name"),
                  retweeted_status_id = jstring("retweeted_status", "id_str"),
                  retweeted_status_user_id = jstring("retweeted_status", "user", "id_str"),
                  retweeted_status_user_screen_name = jstring("retweeted_status", "user", "screen_name"),
                  in_reply_to_status_id = jstring("in_reply_to_status_id")) %>% setDT
  attr(tmp_data, 'JSON') <- NULL
  data_list[[time_stamp]] <- tmp_data
}
all_data <- rbindlist(data_list, fill = TRUE)
library(stringi)
all_data[, text_clean := text %>% stri_replace_all_regex("\\n", " ")]
all_data[, text_clean] %>% write(file = "~/Desktop/temp/ja_kr_tweets/texts.txt")
# 
# save(all_data, file = "~/Desktop/temp/candidate_tweets.Rdata")
# tmp <- all_data[!is.na(retweeted_status_id), .(.N, user_screen_name[1]), by = user_id][order(-N)]
# head(tmp, 20)
# 
# ## some preliminary checking
# lines <- readLines(con = 'Downloader/account_lists/user_ids.py')
# cand_ids <- lapply(as.list(lines), function(x) { strsplit(x, "[^0-9]") %>% unlist }) %>% unlist %>% unique
# tmp <- tmp[user_id %in%cand_ids]
# 
# library(quanteda)
# library(stringi)
# cand_tweets_dfm <- tokens(all_data[user_id %in%cand_ids][, text]) %>% 
#   tokens_select(selection = "keep", features = "^#", valuetype = "regex" ) %>% dfm
# cand_tweets_dfm <- dfm_group(cand_tweets_dfm, group = all_data[user_id %in%cand_ids][, user_screen_name])
# cand_tweets_dfm[cand_tweets_dfm>0] <- 1
# hashtag_count <- colSums(cand_tweets_dfm) %>% sort(decreasing = T) %>% data.frame
# hashtag_count$tag <- row.names(hashtag_count)
# names(hashtag_count)[1] <- "N"
# setDT(hashtag_count)
# hashtag_count[stri_detect_regex(tag, "vote|17|#snp|#labour|#ukip|election|voting|#$|#libdem|conservative|corbyn", negate = TRUE)][1:30]
