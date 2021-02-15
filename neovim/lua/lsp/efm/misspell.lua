return {
    -- go get -u github.com/client9/misspell/cmd/misspell
    lintCommand = "misspell",
    lintIgnoreExitCode = true,
    lintStdin = true,
    lintFormats = {"%f:%l:%c: %m"}
}
