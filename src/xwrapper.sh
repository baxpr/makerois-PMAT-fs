#!/bin/bash
# 
# Run compiled SPM in virtual X.

xvfb-run --server-num=$(($$ + 99)) \
--server-args='-screen 0 1600x1200x24 -ac +extension GLX' \
/opt/makerois/bin/run_spm12.sh \
/usr/local/MATLAB/MATLAB_Runtime/v97 \
"$@"
