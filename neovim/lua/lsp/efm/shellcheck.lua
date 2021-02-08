return {
    lintCommand = "shellcheck -f diff -x -",
    lintSource = "shellcheck",
    -- lintStdin = true,
    lintFormats = {"%f:%l:%c: %trror: %m", "%f:%l:%c: %tarning: %m", "%f:%l:%c: %tote: %m"},
    lintIgnoreExitCode = true,
}
