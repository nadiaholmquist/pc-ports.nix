function _copyROM() {
  if [[ "$curSrc" =~ \.z64 ]]; then
    cp "$curSrc" rom.z64
  else
    return false
  fi
}

unpackCmdHooks+=(_copyROM)
