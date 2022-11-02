function pct_encode {
  local length="${#1}"
  for ((i = 0; i < length; i++)); do
    local c="${1:$i:1}"
    case $c in
    [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
    *) printf '%%%02X' "'$c" ;;
    esac
  done
}

function generate_nonce {
  fold -b -w 32 < /dev/urandom | head -n 1 | base64
}

function generate_timestamp {
  date +%s
}

export -f pct_encode
export -f generate_nonce
export -f generate_timestamp
