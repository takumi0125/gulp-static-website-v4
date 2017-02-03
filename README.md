gulp-static-website-v4
===============================

静的サイト制作用の汎用gulpタスクテンプレートです。

node.js v6.9.1で動作確認済み

gulp v3.9.1で動作確認済み

## インストール
```bash
mkdir yourProject
cd yourProject
git clone --recursive git@github.com:takumi0125/gulp-static-website-v4.git .
cd dev
npm install
```


## 概要

`gulp` コマンドで `dev/src/` の中身がタスクで処理され、ディレクトリ構造を保ちつつ `htdocs/` に展開されます。ただし、「 _ (アンダースコア) 」で始まるファイルやディレクトリはコンパイル・コピーの対象外です。スプライト用のソース画像を格納するディレクトリや、Sassで@import するファイルは「 _ (アンダースコア) 」をつけておけば、 `htdocs/` に展開されることはありません。

`gulp watch` コマンドでローカルサーバが立ち上がります。実行中は
```
http://localhost:50000/
```
で展開後のページが確認できます。

`dev/pubData.json` は pug (jade) タスクを実行する際に読み込まれます。


gulp の各タスクは `dev/gulp/tasks/` に格納してあります。このファイルはあまり変更することはないと思われます。

gulp の各種設定は `dev/gulp/config.coffee` に定義してあります。プロジェクトごとに適宜変更してお使いください。

## 主要タスク

```
gulp
```
`dev/src/` の中身を各種タスクで処理し `htdocs/` に展開します。
`--rerealse` オプションを指定すると、 ソースマップを生成しません。

```
gulp watch
```
ディレクトリを監視し、変更があった場合適宜タスクを実行します。また、ローカルサーバを立ち上げます。
SSI インクルードに対応しています。



## cleanタスクについて
デフォルトタスクを実行、または、

```
gulp clean
```

でクリーンタスクが実行されます。
クリーンタスクの対象ディレクトリは `dev/gulp/config.coffee` の

```coffeescript
# clean対象のディレクトリ (除外したいパスがある場合にnode-globのシンタックスで指定)
clearDir: [ "/**/*" ]
```

このように指定してあります。対象は publishDir 以下となります。
除外したいディレクトリやファイルがある場合は、こちらに設定を追加してください。


## カスタムタスク生成関数

スプライト画像、webpack, jsのconcat, coffee scriptのconcatを使用する場合は、
`dev/gulp/utils.coffee` に定義されている以下の関数を使用し、タスクを定義してください。
以下の関数を実行すると、watchタスクも同時に定義されます。

カスタムタスクは `dev/gulp/customTasks.coffee` に記述してください


### utils.createSpritesTask

spritesmith のタスクを生成する関数です。

※ スプライト生成には <a href="https://github.com/twolfson/gulp.spritesmith" target="_blank"> gulp.spritesmith</a> を使用しています。<br>
※ 画像の圧縮には <a href="https://github.com/imagemin/imagemin-pngquant" target="_blank">imagemin-pngquant</a> を使用しています。

**Params**

 - `taskName` **{Object}**: タスクを識別するための名前 すべてのタスク名と異なるものにする
 - `cssDir` **{String}**: ソース画像ディレクトリへのパス ( `config.srcDir` からの相対パス)
 - `imgDir` **{String}**: ソース CSS ディレクトリへのパス ( `config.srcDir` からの相対パス)
 - `outputImgName` **{String}**: CSS に記述される画像パス (相対パスの際に指定する)
 - `outputImgPath` **{String}**: 指定しなければ #{taskName}.png になる
 - `compressImg` **{Boolean}**: 画像を圧縮するかどうか

```coffeescript
"#{config.srcDir}#{imgDir}/_#{taskName}/"
```
以下にソース画像を格納しておくと
```coffeescript
"#{config.srcDir}#{cssDir}/_#{taskName}.scss"
```
と
```coffeescript
"#{config.srcDir}#{imgDir}/#{outputImgName or taskName}.png"
```
が生成されます。

### utils.createCoffeeExtractTask

coffee script で concat する場合のタスクを生成する関数です。

**Params**

 - `taskName` **{Object}**: タスクを識別するための名前 すべてのタスク名と異なるものにする
 - `src` **{Array|String}**: ソースパス node-glob のシンタックスで指定
 - `outputDir` **{String}**: 最終的に出力される js が格納されるディレクトリ
 - `outputFileName` **{String}**: 最終的に出力される js ファイル名(拡張子なし)


### utils.createWebpackJsTask
webpack のタスクを生成する関数です。coffee script, babel (es2015), glsl と bowerを使用できます。

**Params**

 - `taskName` **{Object}**: タスクを識別するための名前 すべてのタスク名と異なるものにする
 - `entries` **{Array|String}**: webpack の entriesオプションに渡す node-glob のシンタックスで指定
 - `src` **{Array|String}**: entries を除いた全ソースファイル ( watch タスクで監視するため) node-glob のシンタックスで指定
 - `outputDir` **{String}**: 最終的に出力されるjsが格納されるディレクトリ
 - `outputFileName` **{String}**: 最終的に出力される js ファイル名(拡張子なし)


### utils.createJsConcatTask

javascriptのconcatタスクを生成する関数です。ソースは minify されます。

**Params**

 - `taskName` **{Object}**: タスクを識別するための名前 すべてのタスク名と異なるものにする
 - `src` **{Array|String}**: ソースパス node-glob のシンタックスで指定
 - `outputDir` **{String}**: 最終的に出力される js が格納されるディレクトリ
 - `outputFileName` **{String}**: 最終的に出力される js ファイル名(拡張子なし)
