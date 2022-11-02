#!/bin/bash

. func.sh

###
# Step1 - リクエストトークンの取得
###
http_method="POST"
base_url="https://api.twitter.com/oauth/request_token"
oauth_nonce="$(generate_nonce)"
oauth_timestamp="$(generate_timestamp)"
oauth_callback="oob"

# 署名の作成
oauth_signature="$(./mksignature.sh      \
  --oauth_nonce     "${oauth_nonce}"     \
  --oauth_timestamp "${oauth_timestamp}" \
  --oauth_callback  "${oauth_callback}"  \
  --http_method     "${http_method}"     \
  --base_url        "${base_url}"        \
)"

# リクエストの認証
authorization_header="$(./mkauthorization.sh \
  --oauth_nonce     "${oauth_nonce}"         \
  --oauth_timestamp "${oauth_timestamp}"     \
  --oauth_signature "${oauth_signature}"     \
)"

request_token="$(curl -s                                                   \
  --request "${http_method}"                                               \
  --url     "${base_url}?oauth_callback=$(pct_encode "${oauth_callback}")" \
  --header  "Authorization: ${authorization_header}" |  sed -r 's/^oauth_token=([^&]*).*$/\1/g')"

###
# Step2 - pinコードの取得
###
lynx "https://api.twitter.com/oauth/authenticate?oauth_token=${request_token}"
read -r -p "Input the pin code : " pincode

###
# Step3 - アクセストークンの取得
###
http_method="POST"
base_url="https://api.twitter.com/oauth/access_token"
oauth_nonce="$(generate_nonce)"
oauth_timestamp="$(generate_timestamp)"

# 署名の作成
oauth_signature="$(./mksignature.sh      \
  --oauth_nonce     "${oauth_nonce}"     \
  --oauth_timestamp "${oauth_timestamp}" \
  --oauth_token     "${request_token}"   \
  --oauth_verifier  "${pincode}"         \
  --http_method     "${http_method}"     \
  --base_url        "${base_url}"        \
)"

# リクエストの認証
authorization_header="$(./mkauthorization.sh \
  --oauth_nonce     "${oauth_nonce}"         \
  --oauth_timestamp "${oauth_timestamp}"     \
  --oauth_signature "${oauth_signature}"     \
)"

res="$(curl -s                                                                                                   \
  --request "${http_method}"                                                                                     \
  --url     "${base_url}?oauth_token=$(pct_encode "${request_token}")&oauth_verifier=$(pct_encode "${pincode}")" \
  --header  "Authorization: ${authorization_header}")"

oauth_token="$(echo "${res}" | cut -d "&" -f 1 | cut -d "=" -f 2)"
oauth_token_secret="$(echo "${res}" | cut -d "&" -f 2 | cut -d "=" -f 2)"

###
# 結果表示
###
echo "oauth_token        : ${oauth_token}"
echo "oauth_token_secret : ${oauth_token_secret}"