# fjord_sinatra_practice
フィヨルドブートキャンプのsinatraプラクティスの提出物です。

## インストール
以下を実行します。
`git clone https://github.com/Yuukago/sinatra_practice.git`

## 使用法
1, データベースとテーブルを作成します。
`psql -d memos -f schema.sql`

2, 以下のコマンドを実行しサーバーを起動します。
`bundle exec ruby app.rb`
http://localhost:4567/ にアクセスすると制作物のSimple Memoが使えます。

※ PostgreSQL がインストールされている前提です。
※ schema.sql は初回セットアップ時のみ実行してください。
