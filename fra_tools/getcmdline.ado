program define getcmdline, properties(prefix) rclass
    set prefix getcmdline
    gettoken first 0 : 0, parse(": ")
    `0'
    return add
    return local cmdline `0'
end