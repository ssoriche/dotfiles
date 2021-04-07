-- In order to function lua-format command must be installed via:
-- luarocks install --server=https://luarocks.org/dev luaformatter
return {
    formatCommand = "lua-format --chop-down-kv-table --chop-down-table --extra-sep-at-table-end",
    formatStdin = true,
}
