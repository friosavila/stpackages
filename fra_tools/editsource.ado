 *! v0.1 Edit source like view source
program editsource
   if ("`2'"!="") error 198
   quietly findfile `"`1'"'
   doedit `"`r(fn)'"'
end
