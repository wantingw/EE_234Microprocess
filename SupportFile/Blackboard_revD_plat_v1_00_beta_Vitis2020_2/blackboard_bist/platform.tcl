# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct /home/stwg/Blackboard/blackboard/bist/revD/bist_sdk/blackboard_bist/platform.tcl
# 
# OR launch xsct and run below command.
# source /home/stwg/Blackboard/blackboard/bist/revD/bist_sdk/blackboard_bist/platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {blackboard_bist}\
-hw {/home/stwg/Blackboard/blackboard/bist/revD/bist_proj/bist.xsa}\
-proc {ps7_cortexa9_0} -os {standalone} -fsbl-target {psu_cortexa53_0} -out {/home/stwg/Blackboard/blackboard/bist/revD/bist_sdk}

platform write
platform generate -domains 
platform active {blackboard_bist}
platform generate
platform clean
