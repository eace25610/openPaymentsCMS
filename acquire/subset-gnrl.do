// ==============================================================================
// This do-file acquires the general payments dataset and subsets it into
// lgeodata data and non-geo data.
// Run this once to generate two datasets. 
// ==============================================================================

version 13.0

import delimited using OPPR_ALL_DTL_GNRL_12192014.csv ///
	, delimiters(",") varnames(1) clear
	
loc vars2keep ///
				general_transaction_id ///
				payment_publication_date ///
				physician_profile_id ///
				recipient_primary_business_stree /// 
				v14 /// 
				recipient_city /// 
				recipient_state /// 
				recipient_zip_code ///
				physician_primary_type ///
				physician_specialty ///
				physician_license_state_code1 ///
				product_indicator ///
				total_amount_of_payment_usdollar ///
				date_of_payment ///
				form_of_payment_or_transfer_of_v ///
				nature_of_payment_or_transfer_of ///
				physician_ownership_indicator
keep `vars2keep'
					
ren general_transaction_id tid
ren payment_publication_date pubdate
ren physician_profile_id rid
ren recipient_primary_business_stree rst1
ren v14 rst2
ren recipient_city rcity
ren recipient_state rstate
ren recipient_zip_code rzip
ren physician_primary_type rtype
ren physician_specialty rspec
ren physician_license_state_code1 lstate
ren product_indicator prodind
ren total_amount_of_payment_usdollar pay
ren date_of_payment payday
ren form_of_payment_or_transfer_of_v payform
ren nature_of_payment_or_transfer_of paynat
ren physician_ownership_indicator rown

// count rspec
tempvar crspec
bysort rspec: gen `crspec' = _n
by rspec: egen crspec = max(`crspec')
order crspec, after(rspec)
lab var crspec "count of each rspec"

// make rzip 5 digits
replace rzip = trim(rzip)
replace rzip = regexr(rzip, "(\-[0-9][0-9][0-9][0-9])", "")
replace rzip = "" if regexm(rzip, "[aA-zZ]")

// split rspec into categories
split rspec, parse("/ ")			// categories appear to be separated by "/ " (not "/")
forval i = 1/4 {
	replace rspec`i' = trim(rspec`i')
	lab var rspec`i' "`:var label rspec' category `i'"
}
order rspec1 rspec2 rspec3 rspec4, after(rspec)

// clean, categorize, encode: prodind, payform, paynat, rown, dates
foreach v in prodind payform paynat rown {
	encode `v', gen(`v'2)
	lab var `v'2 "`:var label `v''"
	order `v'2, after(`v')
	drop `v'
	ren `v'2 `v'
}

recode rown (2 = 0)
lab define rown ///
					0 "NoOwn" ///
					1 "Own" ///
					, modify
lab val rown rown

foreach d in pubdate payday {
	gen `d'2 = date(`d', "MDY")
	format `d'2 %td
	order `d'2, after(`d')
	lab var `d'2 "`:var label `d''"
	drop `d'
	ren `d'2 `d'
}

order rstate, before(rzip)

// create insample variable
gen insample = 0
replace insample = 1 if ///
	regexm(rtype, "(Osteopathy|Medical Doctor)") & ///
	!mi(rspec) & ///
	(crspec > 1000) 

cap drop _*

preserve

loc vars2drop ///
					rst1 ///
					rst2 ///
					rcity
drop `vars2drop'
compress
save gnrl4stats, replace				// save data for stats

restore

loc vars2keep ///
					tid ///
					rid ///
					rst1 ///
					rst2 ///
					rcity ///
					rstate ///
					rzip ///
					pay ///
					payform ///
					paynat ///
					rown	
keep `vars2keep' 
compress
save gnrl4geo, replace					// save geodata
