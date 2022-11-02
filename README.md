# twitter-pincode-login

TwitterのPINコードログインをBashで行うサンプルです。

## 前提
テキストブラウザとしてLynxを使用しているため、事前にインストールが必要です。

## 使用方法
```
$ export CONSUMER_KEY="(コンシューマーキー)"
$ export CONSUMER_SECRET_KEY="(コンシューマーシークレットキー)"
$ ./get_access_token

(Lynxが開くのでログインを行いPINコードを取得してください)

Input the pin code : 取得したPINコード
oauth_token        : (取得したトークンが表示されます)
oauth_token_secret : (取得したシークレットトークンが表示されます)
```