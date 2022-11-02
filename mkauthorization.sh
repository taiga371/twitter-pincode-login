#!/bin/bash

# shellcheck disable=SC2034

################
# リクエストの認証
################

###
# パラメーターの収集
###
declare -A auth_params=(
  ["oauth_consumer_key"]="${CONSUMER_KEY:?CONSUMER_KEY not found}"
  ["oauth_signature_method"]="HMAC-SHA1"
  ["oauth_version"]="1.0"
)

while getopts :-: opt; do
  optarg="${!OPTIND}"
  [[ "$opt" = - ]] && opt="-$OPTARG"

  case "-$opt" in
  --*)
    auth_params["${opt##-}"]="$optarg"
    shift
    ;;
  esac
done

###
# ヘッダー文字列の構築
###

dst=""
# 文字列「OAuth 」（最後のスペースを含む）をDSTに追加します。
dst="${dst}OAuth "
# 上述の7つのパラメーターの各キー/値のペアについて:
for key in ${!auth_params[*]}; do
  # キーをパーセントエンコードしてDSTに追加します。
  dst="${dst}$(pct_encode "${key}")"
  # 等号文字「=」をDSTに追加します。
  dst="${dst}="
  # 二重引用符「”」をDSTに追加します。
  dst="${dst}\""
  # 値をパーセントエンコードしてDSTに追加します。
  dst="${dst}$(pct_encode "${auth_params[${key}]}")"
  # 二重引用符「”」をDSTに追加します。
  dst="${dst}\""
  # キーと値のペアが残っている場合は、コンマ「,」とスペース「 」をDSTに追加します。
  dst="${dst}, "
done
dst=${dst%, } #末尾の不要な", "を取り除く

echo "${dst}" #作成したヘッダー文字列を返す
