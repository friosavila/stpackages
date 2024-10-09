program show_file
        local 0 `"using `0'"'
        syntax using/

        tempname fh
        file open `fh' using `"`using'"', read
        file read `fh' line
        while r(eof)==0 {
                display `"{p}`macval(line)'{p_end}"'
                file read `fh' line
        }
        file close `fh'
end
