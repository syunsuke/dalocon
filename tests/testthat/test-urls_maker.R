test_that("get metadata 120 test", {

  # 100以上の返り値を持つ場合の処理
  data_length <- 120

  mock_estat_getDataCatalog <- function(startPosition,...){

    if(startPosition <= data_length){
      a <- data_length - startPosition + 1
    }else{
      stop("out of range")
    }

    if (a > 100) {
      a <- 100
    }
    # 100行
    df <- data.frame(dummy=rep(1,a))
    return(df)
  }

  testthat::with_mocked_bindings(
    code = {

      #####################################################
      # test code
      #####################################################
      ans <- sub_get_metadata("","15")
      expect_equal(nrow(ans),120)

      # 知らない表番号
      expect_error(sub_get_metadata("","16"))

      # 数字でも良い
      expect_no_error(sub_get_metadata("",15))

    },
    estat_getDataCatalog = mock_estat_getDataCatalog
  )

})

test_that("get table url test", {

  ansURL_m <- c("http://dummy.com/ma",
                "http://dummy.com/mb",
                "http://dummy.com/mc",
                "http://dummy.com/md",
                "http://dummy.com/me")
  ansURL_y <- c("http://dummy.com/ya",
                "http://dummy.com/yb",
                "http://dummy.com/yc")

  mock_estat_getDataCatalog <- function(...){
    df <- NULL
    df <- data.frame(CYCLE = c(rep("月次",5),rep("年次",3)),
                     URL = c(ansURL_m,ansURL_y))
    return(df)
  }

  testthat::with_mocked_bindings(
    code = {

      #####################################################
      # test code
      #####################################################
      ans <- NULL
      ans <- dalocon_get_table15_urls("")
      expect_equal(length(ans),8)
      expect_identical(ans,c(ansURL_m,ansURL_y))

      # 表７は７−１と７−２で内部問い合わせが２回呼ばれる
      ans <- NULL
      ans <- dalocon_get_table07_urls("")
      expect_equal(length(ans),16)
      expect_identical(ans,rep(c(ansURL_m,ansURL_y),2))

    },
    estat_getDataCatalog = mock_estat_getDataCatalog
  )

})
