! Calculate the bolometer radiation (per cell)

b2ra         ! radiation rate from B2.5 species
b2br m+      ! bremsstrahlung added
0 0 sumz     ! sum over all species
neutrad      ! radiation from Eirene atoms
0 0 sumz m+  ! sum over all species, add
molrad       ! radiation from Eirene molecules
0 0 sumz m+  ! sum over all species, add
ionrad       ! radiation from Eirene molecular ions
0 0 sumz m+  ! sum over all species, add

'Bolometer radiation loss (W)' extl
