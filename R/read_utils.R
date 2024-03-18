# cycle(月次、年次、年度次)の判定
# 日付を紐付け
# 表名の取得
guess_table <- function(file){

  tmp_data <-
    suppressMessages({
      readxl::read_excel(file,
                         range = "A1:B4",
                         col_names = FALSE)
    })

  table_string <- tmp_data[[2]][2]
  date_string <- tmp_data[[2]][4]

  # データ周期の判定
  cycle <- NA

  # 月次
  getuji <- date_string %>%  stringr::str_match(".*年\\d+月分")

  # 年次
  nenji <- date_string %>%  stringr::str_match("(.*年)計分")

  # 年度次
  nendo <- date_string %>%  stringr::str_match("(.*年)度計分")

  if (!is.na(getuji[[1]][1])){
    cycle <- "月次"
    day <- rabbit::fetch_date_from_string(getuji[[1]][1])
  }else if (!is.na(nenji[[1]][1])){
    cycle <- "年次"
    day <- rabbit::fetch_date_from_string(paste0(nenji[[2]][1],"1月1日"))
  }else if (!is.na(nendo[[1]][1])){
    cycle <- "年度次"
    day <- rabbit::fetch_date_from_string(paste0(nendo[[2]][1],"4月1日"))
  }

  ans <- list(tname=table_string,
       cycle = cycle,
       date  = day)

  return(ans)
}

# check_strは複数値をもつベクトルでもOK
sub_check_meta <- function(file, check_str){
  flag <- TRUE

  # fileの表の情報を調べる
  tmp_check <- guess_table(file)

  # 表名
  table_name <- tmp_check$tname

  # 期待する表名と異なる場合の処理
  if(!(table_name %in% check_str)){
    message(
      sprintf("%s does not have %s, but \"%s\". So it's skipped.",
              basename(file),
              ifelse(length(check_str)>1, paste0(check_str[1],"等"), check_str),
              table_name))
    flag <- FALSE
  }

  # 日付のチェック
  day <- tmp_check$date
  if (!lubridate::is.Date(day)){
    message(sprintf("%s has not date cell",
                    basename(file)))
    day <- NA
    flag <- FALSE
  }

  ans <- list(
    valid = flag,
    tname = table_name,
    date  = day,
    cycle = tmp_check$cycle
  )

  return(ans)
}

