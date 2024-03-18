#' Download excel files easily
#'
#' @param appID e-Stat API's application id
#' @param urls excel files urls
#' @param dest_dir directory which you want to put files
#' @param check if True, duplicate file is not download.
#' @param make_dir if True, force to create directory, if not exist
#'
#' @export
dalocon_download_xls <- function(appID,
                          urls,
                          dest_dir = "./",
                          check = TRUE,
                          make_dir = FALSE){

  # 一括して最初に調べる
  # dest_dirの確認
  # dest_dirが存在しない場合エラーで終了
  if(!dir.exists(paths = dest_dir)){
    if(make_dir){
      dir.create(dest_dir, recursive = TRUE)
      #message((sprintf("%s has been created.", dest_dir)))
    }else{
      stop("dest_dir does not exist.")
    }
  }

  # URLのベクトルを取得
  target_urls <- urls

  for(i in seq_along(target_urls)){

    # ファイル名を得られなければ終了
    tmp_filename <- sub_get_excel_filename(target_urls[i])

    # 個別にダウンロード
    dalo::dalo_dl_by_url_with_name(target_urls[i],
                                   dest_dir = dest_dir,
                                   filename = tmp_filename,
                                   check = check)

    # 連続の際に休みを設ける
    Sys.sleep(0.5)

  }
}

##############################################
# ヘッダデータからファイル名を得る
##############################################
sub_get_excel_filename <- function(url){
  tmp_head <- httr::HEAD(url) %>%
    .$headers %>%
    .$`content-disposition`

  # ヘッダがおかしい場合は終了
  if(is.null(tmp_head)){
    stop("Can not get needed header.")
  }

  # 予期されるヘッダ内容
  # "attachment; filename*=UTF-8''2502b015.xls"
  # 後ろのファイル名部分を抜き出す
  ptn <- "attachment; filename\\*=UTF-8''([0-9a-zA-z]+\\.xls)"
  ans <-
    tmp_head %>%
    stringr::str_match(ptn) %>%
    .[,2]

  # ファイル名がおかしい場合は終了
  if(is.na(ans)){
    stop("Can not get needed filename.")
  }
  return(ans)
}
