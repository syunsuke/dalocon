#' Get metadata
#'
#' @param appID estat apprication id
#' @param tablenum table number
#' @import estatapi
#'
#' @return df data.frame
sub_get_metadata <- function(appID, tablenum = "15"){

  ## 収集する表番号と検索ワードの連想記憶配列
  ## 増やす場合はこれを増やす
  table2key <-
    c("15" = "都道府県別、工事別、利用関係別／戸数・件数、床面積",
      "6-1" = "都道府県別、構造別／建築物の数、床面積、工事費予定額",
      "6-2" = "市区町村別、構造別／床面積",
      "7-1" = "都道府県別、用途別（大分類）／建築物の数、床面積、工事費予定額",
      "7-2" = "市区町村別、用途別（大分類）／床面積")

  if(is.numeric(tablenum)){
    tablenum <- as.character(tablenum)
  }

  ## 知らない番号はエラーにする
  if (tablenum %in% names(table2key)){
    keyword <- table2key[tablenum]
  }else{
    stop("table number is not found")
  }

  ## 検索結果は１００件までなので
  ## １００件を超える場合に、処理を繰り返すようにする
  ans <- NULL
  sp <- 1
  while(TRUE){
    tmp_data <-
      estat_getDataCatalog(appID,
                           searchWord = keyword,
                           startPosition = sp,
                           dataType = "XLS")

    ans <- dplyr::bind_rows(ans, tmp_data)

    # 取得したデータが１００未満になったら終わり
    if (nrow(tmp_data) < 100){
      break
    }

    sp <- sp + 100

  }

  return(ans)
}

##########################################################
# 各表のURLを得る個別の関数

#' get urls for table nunber 15
#'
#' @param appID e-Stat API's application id
#'
#' @return urls vector
#' @export
dalocon_get_table15_urls <- function(appID){

  # 表１５のメタデータを得る
  ans <- sub_get_metadata(appID,"15") %>%
    #dplyr::filter(CYCLE == "月次") %>%
    dplyr::pull(URL)

  return(ans)

}

#' get urls for table nunber 7-1 and 7-2
#'
#' @param appID e-Stat API's application id
#'
#' @return urls vector
#' @export
dalocon_get_table07_urls <- function(appID){

  # 表7-1のメタデータを得る
  ans71 <- sub_get_metadata(appID,"7-1") %>%
    #dplyr::filter(CYCLE == "月次") %>%
    dplyr::pull(URL)

  # 表7-2のメタデータを得る
  ans72 <- sub_get_metadata(appID,"7-2") %>%
    #dplyr::filter(CYCLE == "月次") %>%
    dplyr::pull(URL)

  return(c(ans71,ans72))

}


#' get urls for table nunber 6-1 and 6-2
#'
#' @param appID e-Stat API's application id
#'
#' @return urls vector
#' @export
dalocon_get_table06_urls <- function(appID){

  # 表6-1のメタデータを得る
  ans61 <- sub_get_metadata(appID,"6-1") %>%
    #dplyr::filter(CYCLE == "月次") %>%
    dplyr::pull(URL)

  # 表6-2のメタデータを得る
  ans62 <- sub_get_metadata(appID,"6-2") %>%
    #dplyr::filter(CYCLE == "月次") %>%
    dplyr::pull(URL)

  return(c(ans61,ans62))

}
