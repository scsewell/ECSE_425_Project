proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/testbench/clock
    add wave -position end sim:/testbench/reset
    add wave -position end sim:/testbench/dump
    add wave -radix unsigned -position end sim:/testbench/processor_instance/stage_if_inst/pc_address
    add wave -position end sim:/testbench/processor_instance/regs/reg_write
    add wave -position end sim:/testbench/processor_instance/regs/reg_block
    add wave -radix unsigned -position end sim:/testbench/processor_instance/regs/reg_write_num
    add wave -radix unsigned -position end sim:/testbench/processor_instance/regs/reg_write_data
    add wave -position end sim:/testbench/processor_instance/stage_id_inst/instruction
    add wave -radix unsigned -position end sim:/testbench/processor_instance/stage_ex_inst/ctrl_in
    add wave -radix unsigned -position end sim:/testbench/processor_instance/stage_mem_inst/ctrl_in
    add wave -radix unsigned -position end sim:/testbench/processor_instance/stage_mem_inst/results_ex_in
    add wave -radix unsigned -position end sim:/testbench/processor_instance/stage_mem_inst/ctrl_in
	add wave -position end sim:/testbench/processor_instance/stage_mem_inst/main_memory_inst/ram_block
    add wave -radix unsigned -position end sim:/testbench/processor_instance/stage_wb_inst/ctrl_in
    add wave -radix unsigned -position end sim:/testbench/processor_instance/stage_wb_inst/results_ex_in
    add wave -radix unsigned -position end sim:/testbench/processor_instance/stage_wb_inst/results_mem_in
}

vlib work

;# Compile files
vcom signals.vhd

vcom mux.vhd
vcom alu.vhd
vcom memory.vhd
vcom registers.vhd

vcom stage_if.vhd
vcom stage_id.vhd
vcom stage_ex.vhd
vcom stage_mem.vhd
vcom stage_wb.vhd

vcom processor.vhd
vcom testbench.vhd

;# Start simulation
vsim testbench

;# Generate a clock with 1ns period (1 GHz frequency as per project specification)
force -deposit clock 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
AddWaves

;# Run for 10,000 clock cycles as per project specification
run 10000 ns

;# Show to first few clock cycles in the window
wave zoom range 0ns 20ns