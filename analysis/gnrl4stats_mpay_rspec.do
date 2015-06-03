// This do-file runs preliminary analyses on the gnrl4stats.dta file

use gnrl4stats, clear

// subset data

keep if regexm(rspec, "Allopathic & Osteopathic Physicians")
//outsheet using temp/gnrl4stats_docsOnly.csv, replace c


/*
forval i = 1/4 {
	
	// count by speciality
	// rown is not an interesting variable
	foreach v in prodind payform paynat /*rown*/ {
		preserve
		
		bysort rspec`i': egen c`v'_rspec`i' = count(`v') if insample == 1
		egen tag`i' = tag(c`v'_rspec`i')
		sort c`v'_rspec`i'
		
		loc cnt2 = `i' + 1
		loc cnt3 = `cnt2' + 1
		loc cnt4 = `cnt3' + 1
		
		keep if tag`i' == 1
		keep rspec* c`v'_rspec`i'
		drop if mi(rspec`i')
		
		cap drop rspec`cnt2'
		cap drop rspec`cnt3'
		cap drop rspec`cnt4'
		
		export excel using temp/c`v'_rspec`i'.xls, replace first(var)
		export excel using temp/c`v'_rspec.xls, first(var) sh("c`v'_rspec`i'") sheetrep
		
		restore
	}	
}

exit
*/



forval i = 1/4 {
	
	// calculate mean by each rspec and rspec speciality (i.e., rspec1, rspec2, rspec3, rspec4)
	quietly {
		bysort rspec`i': egen mpay_rspec`i' = mean(pay) if insample == 1
		egen tag`i' = tag(mpay_rspec`i')
		sort mpay_rspec`i'
	}
	
	preserve
	
	// put the average pay for each speciality in a workbook
	keep if tag`i' == 1
	keep rspec* mpay_rspec`i'
	replace mpay_rspec`i' = round(mpay_rspec`i', .01)
	
	loc cnt2 = `i' + 1
	loc cnt3 = `cnt2' + 1
	loc cnt4 = `cnt3' + 1
	
	keep rspec* mpay_rspec`i'
	cap drop rspec`cnt2'
	cap drop rspec`cnt3'
	cap drop rspec`cnt4'
	
	outsheet using temp/mpay_rspec`i'_docsOnly.csv, replace c
	
	//export excel using temp/mpay_rspec`i'.xls, replace first(var)
	//export excel using temp/mpay_rspec.xls, first(var) sh("mpay_rspec`i'")

	restore
}
