*! v0.02 Problems with _ files
*! v0.01 Own Installer 
program fra
        syntax [anything], [all replace force]
        local from "https://raw.githubusercontent.com/friosavila/stpackages/main"
        tokenize `anything'
        if "`1'`2'"==""  net from `from' 
        else if !inlist("`1'","describe", "install", "get") display as error "`1' invalid subcommand"
        else net `1' `2', `all' `replace' from(`from')
        qui:net from http://www.stata.com/
end
