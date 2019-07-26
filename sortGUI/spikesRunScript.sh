#!/bin/bash
echo running arg 1 == $1 : "$2($3)"

/share/apps/matlab/R2015a/bin/matlab -r "$2($3); exit"  -nodisplay -nojvm 

