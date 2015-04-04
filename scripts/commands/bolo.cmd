! Calculate the bolometer radiation (per cell)
rqae rlcl m* 0 0 sumz                       ! electron cooling rate
rsan pot* m* qe rm* rlcl m* 0 0 sumz m-     ! less increase of potential energy
rran poti m* qe rm* rlcl m* 0 0 sumz m+     ! plus decrease of potential energy
rsai rlcl m* 0 0 sumz m-                    ! less energy into ions from ionization
rrai rlcl m* 0 0 sumz m-                    ! less energy into ions from recombination
brhe rlcl m* 0 0 sumz m-                    ! add the loss from Eirene
brna poti m* qe rm* rlcl m* 0 0 sumz m-     ! less increase of potential energy
brhi rlcl m* 0 0 sumz m+                    ! less the loss to the ions

'Bolometer radiation loss (W)' extl
