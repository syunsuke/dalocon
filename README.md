
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dalocon

<!-- badges: start -->
<!-- badges: end -->

DAta downLOad helper tool for collecting CONstruction stat data.

daloconは、国道交通省が調査する建築着工統計調査のうち、
以下のデータをe-Stat（政府統計の総合窓口）を通じて収集するツールです。

- [建築物着工統計](https://www.e-stat.go.jp/stat-search/files?page=1&toukei=00600120&tstat=000001016965)
  ６−１表、６−２表　構造別の建築物の数等
- [建築物着工統計](https://www.e-stat.go.jp/stat-search/files?page=1&toukei=00600120&tstat=000001016965)
  ７−１表、７−２表　用途別の建築物の数等
- [住宅着工統計](https://www.e-stat.go.jp/stat-search/files?page=1&toukei=00600120&tstat=000001016966)
  １５表　利用関係別等の建築物の数等

### e-Stat APIのアプリケーションIDが必要

daloconは、e-StatのAPIを利用しているので、 利用には、e-Stat
APIのアプリケーションIDが必要です。

詳しくは「[e-stat API機能](https://www.e-stat.go.jp/api/)」及び
「[よくあるご質問（FAQ）](https://www.e-stat.go.jp/api/api-dev/faq)」を参照しましょう。

## インストール

daloconは、GitHubで公開している他のライブラリ、`rabbit`と`dalo`に依存しています。

- [rabbit](https://github.com/syunsuke/rabbit) 文字列ユティリティ
- [dalo](https://github.com/syunsuke/dalo) ダウンロードヘルパー

以下の順でインストールしてください。

``` r
# install.packages("devtools")
devtools::install_github("syunsuke/rabbit")
devtools::install_github("syunsuke/dalo")
devtools::install_github("syunsuke/dalocon")
```

## 使い方

住宅着工統計の第１５表
（都道府県別、工事別、利用関係別／戸数・件数、床面積）のデータを
取得する例を以下に示します。

データを取得するには３つのプロセスが必要です。

- エクセルファイルがダウンロード出来るURLを得る
- エクセルファイルをダウンロードする
- ダウンロードしたエクセルファイルをRに読み込む

### URLを得る

エクセルファイルがダウンロードできるURLをを得るには以下の関数を
実行して、そのURLを文字列のベクトルとして受け取ります。

関数の引数`appID`にはe-statAPIのアプリケーションIDを文字列として渡します。
（下の例でxxxxxxx…となっている部分）

``` r
library(dalocon)

urls <- dalocon_get_table15_urls(appID = "xxxxxxxxxxxxxxxxxxxx")
```

### ファイルをダウンロードする

以下の関数でエクセルファイルをダウンロードします。
この関数には主に３つの引数を渡します。
まず、`appID`として、e-statAPIのアプリケーションIDを文字列として渡します。
次に、`urls`にダウンロードファイルのあるURLの文字列のベクトルを渡します。
これは通常、先に実行した`dalocon_get_table15_urls()`関数の戻り値になります。
最後に、ダウンロードしたエクセルファイルを保存するディレクトリを指定します。

``` r
dalocon_download_xls(appID = "xxxxxxxxxxxxxxxxxxxx", 
                     urls = urls, 
                     dest_dir = "t15data/")
```

ここで、`dest_dir`で指定するディレクトリが存在しない場合、エラーで終了しますが、指定したディレクトリが存在しない場合に、自動的にディレクトリを作成したい場合は、`make_dir`引数にTRUEを渡します。

また、ダウンロードしようとしているファイルのファイル名が
`dest_dir`に既に存在する場合、
通常、そのファイルはダウンロードしません。
つまり、このダウンロード関数はデフォルトで持っていないデータのみを
ダウンロードするようになっています。
しかし、`check`引数にFALSEを渡すことで、ディレクトリ内のファイルのあるなしに関わらず、全てダウンロードすることが出来ます（同名のファイルがある場合は上書きします。）

上記の２つのオプションはデフォルトで次のような値になっています。

``` r
dalocon_download_xls(appID = "xxxxxxxxxxxxxxxxxxxx", 
                     urls = urls, 
                     dest_dir = "t15data/",
                     make_dir = FALSE,
                     check = TURE)
```

### ファイルを読み込む

以下の関数でエクセルファイルを読み込んでRの`data.frame`にします。

関数には、各エクセルファイルのパス（ファイルがある場所）のベクトルを渡します。
これは、`dir()`関数にエクセルファイルを保存したディレクトリを渡すことで得ることが出来ます。相対パスを正確に得るために`full.names`引数にTRUEを渡しておきます。

``` r
files <- dir("t15data", full.names = TRUE)
t15_data <- dalocon_read_t15_xls(files)
```

各列は、エクセルファイルの列に連動しています。
詳細はWikiを参照してください。

### 整然データにする

地域毎等で整理して新たにエクセルファイルとして出力する場合、
もとのエクセルファイルのままの列の構成で構いませんが、
Rのtidyverseで処理する場合に便利なように、
列名の一部を列の内容とししたデータに変換できるようにしてあります。

その場合は、以下の関数を実行してください。

``` r
t15__tidy_data <- t15_data %>% dalocon_make_t15_tidy()
```
