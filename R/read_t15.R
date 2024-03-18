#' Read xls files of table number 15
#'
#' @param files xls file's path vector
#' @return data.frame
#' @export
dalocon_read_t15_xls <- function(files){
  ans <- NULL
  for (i in seq_along(files)){
    ans <- ans  %>%
      dplyr::bind_rows(sub_read_t15_xls(files[i]))
  }
  return(ans)
}


sub_read_t15_xls <- function(file){

  ###########################################################
  # 生のエクセルファイルを読む
  # フォーマットチェックと日付確認
  ###########################################################
  check <- sub_check_meta(file,"第１５表")

  if (check$valid){
    day <- check$date
    cycle <- check$cycle
  }else{
    return(NULL)
  }

  ###########################################################
  # エクセルファイルを読み込んで
  # 整形
  ###########################################################

  ans <- sub_read_t15_sheet(file,1) %>%
    dplyr::bind_rows(sub_read_t15_sheet(file,2)) %>%
    dplyr::select(!space) %>%

    # 加工
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

  ###########################################################
  # 大阪地域のエリアIDを確認して、欠けているものがあれば
  # データをNAで補完
  # 確認用のIDはこのパッケージで管理
  ###########################################################
  luck_id <- setdiff(osaka_area_id, ans$area_id)
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

  return(ans)
}

# シートの処理を一括定義
sub_read_t15_sheet <- function(file, sheet){
  ans <-
    # 読み込み時の
    # 数値じゃない部分の大量のウォーニングを抑制
    suppressWarnings({
      readxl::read_excel(file,
                         sheet = sheet,
                         col_names = t15_colname,
                         col_types = t15_type,
                         skip = 7)
    }) %>%
    # 必ず人口数のある3列目がNAなら除外
    .[!is.na(.[[3]]),]

  return(ans)
}


#################################################################
# colname & coltype definition
#################################################################

# 列の型を指定
t15_type <-
  c("text",
    "text",
    rep("numeric",22))

# 列の名前を指定
t15_colname <-
  c("area",
    "space",
    "t_t_num",
    "t_t_size",
    "new_t_num",
    "new_t_size",
    "new_own_num",
    "new_own_size",
    "new_rent_num",
    "new_rent_size",
    "new_com_num",
    "new_com_size",
    "new_fam_num",
    "new_fam_size",
    "other_t_num",
    "other_t_size",
    "other_own_num",
    "other_own_size",
    "other_rent_num",
    "other_rent_size",
    "other_com_num",
    "other_com_size",
    "other_fam_num",
    "other_fam_size")
