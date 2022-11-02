#!/bin/bash

# shellcheck disable=SC2214
# shellcheck disable=SC2034

############
# 署名の作成
############

###
# リクエストメソッドとURLの収集, パラメーターの収集
###
declare -A signature_params=(
  ["oauth_consumer_key"]="${CONSUMER_KEY:?CONSUMER_KEY not found}"
  ["oauth_signature_method"]="HMAC-SHA1"
  ["oauth_version"]="1.0"
)

while getopts :-: opt; do
  optarg="${!OPTIND}"
  [[ "$opt" = - ]] && opt="-$OPTARG"

  case "-$opt" in
  --http_method)
    http_method="$optarg"
    shift
    ;;
  --base_url)
    base_url="$optarg"
    shift
    ;;
  --*)
    signature_params["${opt##-}"]="$optarg"
    shift
    ;;
  esac
done

# 署名されるすべてのキーと値をパーセントエンコードします。
declare -A encoded_signature_params
for key in "${!signature_params[@]}"; do
  encoded_signature_params[$(pct_encode "${key}")]=$(pct_encode "${signature_params[${key}]}")
done

# パラメーターのリストをエンコードされたキーでアルファベット順に並べ替えます。
# (bashの連想配列はソートできないため、ソートされたキー順にアクセスすることで代替します)
orig_ifs=${IFS}
IFS=$'\n'
mapfile -t sorted_encoded_keys < <(echo "${!encoded_signature_params[*]}" | sort)
IFS=${orig_ifs}

# それぞれのキーと値のペアに対して:
parameter_string=""
for encoded_key in "${sorted_encoded_keys[@]}"; do
  # 出力文字列にエンコードされたキーを追加します。
  parameter_string="${parameter_string}${encoded_key}"
  # 出力文字列に「=」を追加します。
  parameter_string="${parameter_string}="
  # 出力文字列にエンコードされた値を追加します。
  parameter_string="${parameter_string}${encoded_signature_params[${encoded_key}]}"
  # キーと値のペアがまだ残っている場合は、出力文字列に「&」を追加します。
  parameter_string="${parameter_string}&"
done
parameter_string=${parameter_string%&} #末尾の不要な"&"を取り除く

###
# 署名ベース文字列の作成
###
signature_base_string=""
# HTTPメソッドを大文字に変換し、出力文字列をこの値に設定します。
signature_base_string="${signature_base_string}${http_method^^}"
# 出力文字列に「&」を追加します。
signature_base_string="${signature_base_string}&"
# URLをパーセントエンコードし、出力文字列に追加します。
signature_base_string="${signature_base_string}$(pct_encode "${base_url}")"
# 出力文字列に「&」を追加します。
signature_base_string="${signature_base_string}&"
# パラメーター文字列をパーセントエンコードし、出力文字列に追加します。
signature_base_string="${signature_base_string}$(pct_encode "${parameter_string}")"

###
# 署名キーの取得
###
signature_key="$(pct_encode "${CONSUMER_SECRET_KEY:?CONSUMER_SECRET_KEY not found}")&$(pct_encode "${OAUTH_TOKEN_SECRET}")"

###
# 署名の計算
###
signature="$(echo -n "${signature_base_string}" | openssl sha1 -hmac "${signature_key}" -binary | base64 | tr -d '\n')"

echo "${signature}" #作成した署名を返す
