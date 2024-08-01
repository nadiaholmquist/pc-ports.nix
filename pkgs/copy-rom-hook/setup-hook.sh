function _copyROM() {
  local fname="$(basename -- "$curSrc")"
  local ext="${fname##*.}"

  case "$ext" in
    sfc | z64) cp "$curSrc" rom."$ext" ;;
    *) return false
  esac
}

unpackCmdHooks+=(_copyROM)
