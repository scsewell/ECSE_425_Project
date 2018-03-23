proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/testbench/clock
    add wave -position end sim:/testbench/reset
}

vlib work

;# Compile components if any
vcom memory.vhd
vcom processor.vhd
vcom testbench.vhd

;# Start simulation
vsim testbench

;# Generate a clock with 1ns period
force -deposit clock 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
AddWaves

;# Run
run 200 ns

;# Fit the view to the simulation
wave zoom full