vlib work

vlog ../rtl/counter.v
vlog -sv ../tb/test.v

vsim -voptargs="+acc" work.test

do wave.do

run -all