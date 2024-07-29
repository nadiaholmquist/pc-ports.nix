function _tryUncompressZ64() {
  [[ "$curSrc" =~ \.z64$ ]] || return 1
  destFile="$(stripHash "$curSrc" | sed 's/\.z64/.rom_uncompressed.z64/')"
  z64decompress "$curSrc" "$destFile"
}
unpackCmdHooks+=(_tryUncompressZ64)
