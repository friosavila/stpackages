** sum for generated variables
capture program drop fgsum 
program fgsum, rclass
syntax anything [if] [in] [aw fw iw], [Detail]
	tempname sumr
	marksample touse
	
	if "`detail'"=="" {
		foreach i of local anything  {
			local cnt=`cnt'+1
			tempvar aux`cnt'
			qui:gen `aux`cnt''=`i'
			qui:sum `aux`cnt'' if `touse' [`weight'`exp']
			matrix `sumr'=nullmat(`sumr')\[r(N),r(mean),r(sd),r(min),r(max)]
			local nm `nm' `i'
		}
		matrix colname `sumr'=  Obs Mean "Std. Dev." Min Max
		matrix rowname `sumr'=`nm'
		matrix list `sumr',noheader format(%15.7g)
		return matrix stats=`sumr'
		}
	else {
			foreach i of local anything  {
				local cnt=`cnt'+1
				tempvar aux`cnt'
				qui:gen `aux`cnt''=`i'
				qui:sum `aux`cnt'' if `touse' [`weight'`exp'],d
				matrix `sumr'=nullmat(`sumr')\[r(N),r(mean),r(sd),r(skewness),r(kurtosis),r(min),r(p1),r(p5),r(p10), ///
							r(p25),r(p50),r(p75), r(p90), r(p95), r(p99),r(max)]
				
 
				local nm `nm' `i'
			}
			matrix colname `sumr'=  Obs Mean "Std. Dev." Skewness Kurtosis Min p1 p5 p10 p25 Median p75 p90 p95 p99 Max
			matrix rowname `sumr'=`nm'
			matrix `sumr'=`sumr''
            matrix list `sumr',noheader format(%15.7g)
			matrix `sumr'=`sumr''
			return matrix stats=`sumr'
		}
	

end

                