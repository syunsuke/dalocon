#' Read xls files of table number 7
#'
#' @param files xls file's path vector
#' @return data.frame
#' @export
dalocon_read_t07_xls <- function(files){
  ans <- NULL
  for (i in seq_along(files)){
    ans <- ans  %>%
      dplyr::bind_rows(sub_read_t07_xls(files[i]))
  }
  return(ans)
}

sub_read_t07_xls <- function(file){

  ###########################
  # validation check
  ##########################
  check <- sub_check_meta(file,c("第７表－１","第７表－２"))

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
  flag_72 <- FALSE

  # 7-1と7-2で分岐して処理
  if (mytable == "第７表－１"){
    tmp <- sub_read_t71(file)
  }else if(mytable == "第７表－２" && cycle == "月次"){
    tmp <- sub_read_t72(file)
    flag_72 <- TRUE
  }else{
    tmp <- sub_read_t71(file)
    flag_72 <- TRUE
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

  if(flag_72){
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

sub_read_t71 <- function(file){
  ans <-
    # 読み込み時の
    # 数値じゃない部分の大量のウォーニングを抑制
    suppressWarnings({
      readxl::read_excel(file,
                         col_names = t71_colname,
                         col_types = t71_type,
                         skip = 6)
    }) %>%
    # 必ず人口数のある3列目がNAなら除外
    .[!is.na(.[[3]]),] %>%
    dplyr::select(!space)

  return(ans)

}


sub_read_t72 <- function(file){
  ans <-
    # 読み込み時の
    # 数値じゃない部分の大量のウォーニングを抑制
    suppressWarnings({
      readxl::read_excel(file,
                         col_names = t72_colname,
                         col_types = t72_type,
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
# 7-1
#/////////////

# 7-1の列の型を指定
t71_type <-
  c("text",
    "text",
    rep("numeric",57))

# 7-1の列の名前を指定
t71_colname <-
  c("area",
    "space",
    "t_num", "t_size", "t_yen",
    "a_num", "a_size", "a_yen",
    "b_num", "b_size", "b_yen",
    "c_num", "c_size", "c_yen",
    "d_num", "d_size", "d_yen",
    "e_num", "e_size", "e_yen",
    "f_num", "f_size", "f_yen",
    "g_num", "g_size", "g_yen",
    "h_num", "h_size", "h_yen",
    "i_num", "i_size", "i_yen",
    "j_num", "j_size", "j_yen",
    "k_num", "k_size", "k_yen",
    "l_num", "l_size", "l_yen",
    "m_num", "m_size", "m_yen",
    "n_num", "n_size", "n_yen",
    "o_num", "o_size", "o_yen",
    "p_num", "p_size", "p_yen",
    "q_num", "q_size", "q_yen",
    "r_num", "r_size", "r_yen")

#/////////////
# 7-2
#/////////////

# 列の型を指定
t72_type <-
  c("text",
    "text",
    rep("numeric",19))

# 列の名前を指定
t72_colname <-
  c("area",
    "space",
    "t_size",
    "a_size",
    "b_size",
    "c_size",
    "d_size",
    "e_size",
    "f_size",
    "g_size",
    "h_size",
    "i_size",
    "j_size",
    "k_size",
    "l_size",
    "m_size",
    "n_size",
    "o_size",
    "p_size",
    "q_size",
    "r_size")
