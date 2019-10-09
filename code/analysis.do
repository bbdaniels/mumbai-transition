// Analysis code

// Overall combined
use "${directory}/constructed/sp-private.dta", clear

 betterbar correct re_1 re_3 re_4 re_5 dr_4 med_k_any_9 ///
   med_l_any_1 med_l_any_2 med_l_any_3 ///
 , over(wave) legend(on symxsize(small) size(small)) xlab(${pct}) ///
   title("All cases" , ${title}) barlab

graph export "${directory}/outputs/sp-all.eps" , replace

// All items
use "${directory}/constructed/sp-private.dta", clear

  foreach case in 1 2 3 4 7 {
    betterbar re_1 re_3 re_4 re_5 dr_4 med_k_any_9 ///
      med_l_any_1 med_l_any_2 med_l_any_3 ///
    if case == `case' ///
    , over(wave) legend(on symxsize(small) size(small) span) xlab(${pct}) ///
      title("Case `case'" , ${title})

    graph save "${directory}/outputs/sp`case'.gph" , replace
  }

  graph combine ///
    "${directory}/outputs/sp1.gph" ///
    "${directory}/outputs/sp2.gph" ///
    "${directory}/outputs/sp3.gph" ///
    "${directory}/outputs/sp4.gph"

    graph export "${directory}/outputs/sp-stats.eps" , replace

// Correct and GX
use "${directory}/constructed/sp-private.dta" if case < 7, clear

  betterbar correct re_4 if ppia_facility_1 == 1 ///
    , over(wave) by(case) barlab xlab(${pct}) ///
      legend(on size(small) symxsize(small) region(lc(none) fc(none))) ///
      title("PPIA Facilities in Round 2" , ${title})

    graph save "${directory}/outputs/r2-ppia.gph" , replace

  betterbar correct re_4 if ppia_facility_1 == 0 ///
    , over(wave) by(case) barlab xlab(${pct}) ///
      legend(on size(small) symxsize(small) region(lc(none) fc(none))) ///
      title("Non-PPIA Facilities in Round 2" , ${title})

      graph save "${directory}/outputs/r2-nonppia.gph" , replace

  graph combine ///
    "${directory}/outputs/r2-ppia.gph" ///
    "${directory}/outputs/r2-nonppia.gph"

    graph export "${directory}/outputs/ppia-gx.eps" , replace

// Correct and GX: transitioning
use "${directory}/constructed/sp-private.dta" ///
  if case < 7 & ppia_facility_1 == 1, clear

  betterbarci re_4 if ppia_facility_2 == 1 ///
    , over(wave) by(case) barlab xlab(${pct}) ///
      legend(on size(small) symxsize(small) region(lc(none) fc(none))) ///
      title("PPSA Facilities in Round 3" , ${title})

      graph save "${directory}/outputs/r2-ppia.gph" , replace

  betterbarci re_4 if ppia_facility_2 == 0 ///
    , over(wave) by(case) barlab xlab(${pct}) ///
      legend(on size(small) symxsize(small) region(lc(none) fc(none))) ///
      title("Left PPSA in Transition" , ${title})

      graph save "${directory}/outputs/r2-nonppia.gph" , replace

  graph combine ///
    "${directory}/outputs/r2-ppia.gph" ///
    "${directory}/outputs/r2-nonppia.gph"

    graph export "${directory}/outputs/ex-ppia-gx.eps" , replace

// PPSA RD experiment

  // Eligibility and implementation check
  use "${directory}/constructed/sp-private.dta" ///
    if case < 7 & ppsa_notifications != ., clear
  tw ///
    (scatter ppsa_notifications ppsa_cutoff if ppia_facility_2 == 1 , mc(black)) ///
    (scatter ppsa_notifications ppsa_cutoff if ppia_facility_2 == 0 , mc(red)) ///
    , xline(65 80 95) ytit("") ///
      title("Monthly Notifications and PPSA Transition Eligibility" , ${title}) ///
      xtit("PPSA Eligibility Score Cutoff" ) ///
      xlab(0(20)100 80 "  {&larr} In 80 Out {&rarr}") ///
      legend(on order(1 "Included in PPSA" 2 "Removed at Transition"))

      graph export "${directory}/outputs/ppsa-eligibility.eps" , replace

  // Results
  * collapse (mean) re_4 ppsa_cutoff , by(qutub_id)
  use "${directory}/constructed/sp-private.dta" ///
    if case < 7 & ppsa_notifications != . & wave == 1, clear

    bys qutub_id: egen check = mean(re_4)
    bys qutub_id: egen w = count(re_4)
      replace w = 1/w

  tw ///
    (scatter check ppsa_cutoff if ppia_facility_2 == 1 , mc(black)) ///
    (scatter check ppsa_cutoff if ppia_facility_2 == 0 , mc(red)) ///
    (lfitci re_4 ppsa_cutoff if ppsa_cutoff <= 80 , lc(black) alw(none)) ///
    (lfitci re_4 ppsa_cutoff if ppsa_cutoff > 80 , lc(red) alw(none)) ///
  , legend(on order (1 "Included in PPSA" 2 "Removed at Transition") ring(0) pos(11)) ///
    ylab(${pct}) title("Experimental Results" , ${title}) ///
    xtit("PPSA Eligibility Score Cutoff" ) ///
    xlab(0(20)100 80 "  {&larr} In 80 Out {&rarr}") ///
    xline(65 80 95) ytit("")

    graph export "${directory}/outputs/ppsa-rd.eps" , replace

// PPSA RD experiment YOY
  // 1: Y3 only
  use "${directory}/constructed/sp-private.dta" ///
    if case < 7 & ppsa_notifications != ., clear

    tw ///
      (histogram ppsa_notifications , fc(gs14) lc(gs14) yaxis(2)) ///
      (lowess re_4 ppsa_notifications if wave == 1 & case == 1 ) ///
      (lowess re_4 ppsa_notifications if wave == 1 & case == 2 ) ///
      (lowess re_4 ppsa_notifications if wave == 1 & case == 3 ) ///
      (lowess re_4 ppsa_notifications if wave == 1 & case == 4 ) ///
    , legend(on order (2 "Case 1" 3 "Case 2" 4 "Case 3" 5 "Case 4") ring(0) pos(5) c(1)) ///
      ylab(${pct}) title("Casewise GX use in PPSA" , ${title}) ///
      xtit("Average Monthly PPIA Notifications" ) ///
      xline(65 80 95) ytit("") ${hist_opts}

      graph export "${directory}/outputs/ppia-gx.eps" , replace

  // 2: YOY
  use "${directory}/constructed/sp-private.dta" ///
    if case < 7 & ppsa_notifications != ., clear

   bys qutub_id: egen check = mean(re_4)

    tw ///
      (lfitci re_4 ppsa_cutoff if wave == 0 , lc(black) alw(none)) ///
      (lfit re_4 ppsa_cutoff if wave == 1 , lc(black) lp(dash)) ///
    , legend(on order (2 "Round 2" 3 "Round 3") ring(0) pos(11) c(1)) ///
      ylab(${pct}) title("Year-over-year GX changes in PPSA" , ${title}) ///
      xtit("PPSA Eligibility Score Cutoff" ) ///
      xlab(0(20)100 80 "  {&larr} In 80 Out {&rarr}") ///
      xline(65 80 95) ytit("")

      graph export "${directory}/outputs/ppsa-gx.eps" , replace


// End of dofile
