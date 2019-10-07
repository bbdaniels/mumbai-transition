// Analysis code

// All items
use "${directory}/constructed/sp-private.dta", clear

  foreach case in 1 2 3 4 7 {
    betterbar re_1 re_3 re_4 re_5 dr_4 med_k_any_9 ///
      med_l_any_1 med_l_any_2 med_l_any_3 ///
    if case == `case' ///
    , over(wave) legend(on symxsize(small) size(small) span) xlab(${pct}) ///
      title("Case `case'" , justification(left) color(black) span pos(11))

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
betterbar correct re_4 if provider_ppia_wave1 == 1, over(wave) by(case)
betterbar correct re_4 if provider_ppia_wave1 == 0, over(wave) by(case)

// End of dofile
