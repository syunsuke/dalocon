#' Read xls files of table number 6
#'
#' @param files xls file's path vector
#' @return data.frame
#' @export
dalocon_read_t06_xls <- function(files){
  ans <- NULL
  for (i in seq_along(files)){
    ans <- ans  %>%
      dplyr::bind_rows(sub_read_t07_xls(files[i]))
  }
  return(ans)
}

sub_read_t06_xls <- function(file){

  ###########################
  # validation check
  ##########################
  check <- sub_check_meta(file,c("第６表－１","第６表－２"))

  if (check$valid){
    day <- check$date
    cycle <- check$cycle
    mytable <- check$tname
  }else{
    message("wrong data. so skipped.")
    return(NULL)
  }

  ###########################
  # read data
  ###########################

  tmp <- NULL
  flag_62 <- FALSE

  # 6-1と6-2で分岐して処理
  if (mytable == "第６表－１"){
    tmp <- sub_read_t61(file)
  }else if(mytable == "第６表－２" && cycle == "月次"){
    tmp <- sub_read_t62(file)
    flag_62 <- TRUE
  }else{
    tmp <- sub_read_t61(file)
    flag_62 <- TRUE
  }

  ans <- tmp %>%
    # 地域名を加工
    dplyr::mutate(cycle = cycle,
                  area_id = stringr::str_extract(area,"\\d+"),
                  area_name = osaka_area_name[area_id],
                  date  = day) %>%
    dplyr::select(!area) %>%

    # 大阪のみ
    dplyr::filter(stringr::str_detect(area_id,"^27")) %>%
    dplyr::relocate(area_name,
                    area_id,
                    date,
                    cycle)

  if(flag_62){
    ###########################################################
    # 大阪地域のエリアIDを確認して、欠けているものがあれば
    # データをNAで補完
    # 確認用のIDはこのパッケージで管理
    ###########################################################
    luck_id <- setdiff(osaka_area_id[2:length(osaka_area_id)], ans$area_id)

    # debug
    if (length(luck_id)>1){
      message(sprintf("date:%s file:%s",as.character(day),basename(file)))
      print(osaka_area_name[luck_id])
      message("")
    }

    comp_df <- NULL
    for(i in seq_along(luck_id)){
      tmp <- data.frame(area_id = luck_id[i],
                        area_name = osaka_area_name[luck_id[i]],
                        date = day,
                        cycle = cycle)
      comp_df <- dplyr::bind_rows(comp_df,tmp)
    }

    ans <- ans %>%
      dplyr::bind_rows(comp_df) %>%
      dplyr::arrange(area_id)

  }

  return(ans)
}

sub_read_t61 <- function(file){
  ans <-
    # 読み込み時の
    # 数値じゃない部分の大量のウォーニングを抑制
    suppressWarnings({
      readxl::read_excel(file,
                         col_names = t61_colname,
                         col_types = t61_type,
                         skip = 6)
    }) %>%
    # 必ず人口数のある3列目がNAなら除外
    .[!is.na(.[[3]]),] %>%
    dplyr::select(!space)

  return(ans)

}


sub_read_t62 <- function(file){
  ans <-
    # 読み込み時の
    # 数値じゃない部分の大量のウォーニングを抑制
    suppressWarnings({
      readxl::read_excel(file,
                         col_names = t62_colname,
                         col_types = t62_type,
                         skip = 6)
    }) %>%
    # 必ず人口数のある3列目がNAなら除外
    .[!is.na(.[[3]]),] %>%
    dplyr::select(!space)

  return(ans)

}


#################################################################
# colname & coltype definition
#################################################################

#/////////////
# 6-1
#/////////////

# 6-1の列の型を指定
t61_type <-
  c("text",
    "text",
    rep("numeric",21))

# 6-1の列の名前を指定
t61_colname <-
  c("area",
    "space",
    "t_num", "t_size", "t_yen",
    "w_num", "w_size", "w_yen",
    "src_num", "src_size", "src_yen",
    "rc_num", "rc_size", "rc_yen",
    "s_num", "s_size", "s_yen",
    "cb_num", "cb_size", "cb_yen",
    "other_num", "other_size", "other_yen")

#/////////////
# 6-2
#/////////////

# 列の型を指定
t62_type <-
  c("text",
    "text",
    rep("numeric",7))

# 列の名前を指定
t62_colname <-
  c("area",
    "space",
    "t_size",
    "w_size",
    "src_size",
    "rc_size",
    "s_size",
    "cb_size",
    "other_size")
