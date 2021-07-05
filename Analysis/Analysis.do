/**
Group Replication Project - Lead Mortality
Group 3
Luke Burstein, Andrew Howe, Percy Pham
4/2020
**/

clear
set more off
capture log close
graph drop _all

log using Analysis\Analysis.log, replace		// create log file
use Data\Lead_Mortality			// use the original data file

codebook, compact 		// summary of the data

gen lnph = ln(ph-5.675) // generate ln(pH-5.675)
gen lnhardness = ln(hardness)		// generate ln(hardness)

// The graph
twoway (scatter lnph infrate) (lfit lnph infrate)
graph save Analysis/Figure1, replace 

// TABLE 3 - determinants of a city’s use of lead-only pipes
// column 1 - lead only 
regress lead lnph lnhardness population precipitation temperature typhoid_rate, robust
outreg2 using Table3.xls, replace
// column 2 - lead only and pH<=7.3
regress lead lnhardness population precipitation temperature typhoid_rate if ph<=7.3, robust
outreg2 using Table3.xls, append

// TABLE 4 - effect of lead and pH on infant mortality
// column 1
regress infrate i.lead##c.lnph, robust 
outreg2 using Table4.xls, replace
// column 2
regress infrate i.lead##c.lnph foreign_share precipitation temperature mom_rate, robust 
outreg2 using Table4.xls, append
// column 3
regress infrate i.lead##c.lnph typhoid_rate np_tub_rate foreign_share precipitation temperature mom_rate, robust
outreg2 using Table4.xls, append
// column 4
gen ph_6675 = ph - 6.675		// generate pH-6.675
gen ph73 = (ph>7.3)			// generate 1(pH > 7.3): =1 if pH>7.3, =0 otherwise
regress infrate c.ph_6675##i.lead i.lead##i.ph73 typhoid_rate np_tub_rate foreign_share precipitation temperature mom_rate, robust
outreg2 using Table4.xls, append

// TABLE 5 - effect of lead on infant mortality
// column 1
regress infrate lnph if lead==1, robust
outreg2 using Table5.xls, replace
// column 2
regress infrate lnph lnhardness if lead==1, robust
outreg2 using Table5.xls, append
// column 3
regress infrate c.hardness##c.ph_6675 c.ph_6675#i.ph73 c.hardness#i.ph73 i.lead#i.ph73 if lead==1, robust
outreg2 using Table5.xls, append

log off