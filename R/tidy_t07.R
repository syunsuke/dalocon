#' Make table number 07 data tidy
#'
#' @param df data.frame
#'
#' @return data.frame
#' @export
dalocon_make_t07_tidy <- function(df){
  ans <- df %>%
    tidyr::pivot_longer(
      cols = !(area_name:cycle),
      names_to = c("cat01","tab"),
      names_sep = "_",
      values_to = "value"
    ) %>%
    dplyr::mutate(
      `用途` = t07_cat01_value[.$cat01])

  return(ans)
}

#############################
# 利用関係 cat01
#############################
t07_cat01_name <-
  c("t",
    "a","b","c","d","e","f","g","h","i",
    "j","k","l","m","n","o","p","q","r")

t07_cat01_value <-
  c("計",
    "Ａ居住専用住宅",
    "Ｂ居住専用準住宅",
    "Ｃ居住産業併用建築物",
    "Ｄ農林水産業用建築物",
    "Ｅ鉱業，採石業，砂利採取業，建設業用建築物",
    "Ｆ製造業用建築物",
    "Ｇ電気・ガス・熱供給・水道業用建築物",
    "Ｈ情報通信業用建築物",
    "Ｉ運輸業用建築物",
    "Ｊ卸売業，小売業用建築物",
    "Ｋ金融業，保険業用建築物",
    "Ｌ不動産業用建築物",
    "Ｍ宿泊業，飲食サービス業用建築物",
    "Ｎ教育，学習支援業用建築物",
    "Ｏ医療，福祉用建築物",
    "Ｐその他のサービス業用建築物",
    "Ｑ公務用建築物",
    "Ｒ他に分類されない建築物")

names(t07_cat01_value) <- t07_cat01_name

