vlib work
vmap work work
vlog -F scopeNoMPU.files 
vsim -voptargs=+acc AIP_scopeNoMPU_tb
do wave.do
view structure
view signals
restart -f
run -all