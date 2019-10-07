// Data constuction for transition analysis

// Cleanup: Wave 1
use "${directory}/data/sp-private-1.dta" if sample != 1, clear
tostring dr_5b_no re_1_a re_12_a_1 re_12_a_2 med_h_1 med_j_2, replace

save "${directory}/data/sp-private-1.dta" , replace

// Cleanup: Wave 2
use "${directory}/data/sp-private-2.dta" , clear
tostring form re_9_b re_9_c re_10_c re_11_a re_12_a_4 med_f_2 med_f_3 med_b12_12 med_b2_12, replace
replace re_1 = 1 if re_1 > 1

save "${directory}/data/sp-private-2.dta" , replace
//

use "${directory}/data/sp-private-1.dta"
  tostring form , replace

qui append using "${directory}/data/sp-private-2.dta" , gen(wave)
  label def wave 0 "PPIA" 1 "Post-PPIA"
  label val wave wave

hashdata using "${directory}/constructed/sp-private.dta" , reset replace

// End of dofile
