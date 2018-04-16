proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -radix ascii -position end sim:/testbench/program_name
    add wave -position end sim:/testbench/clock
    add wave -position end sim:/testbench/reset
    add wave -position end sim:/testbench/dump
    add wave -radix unsigned -position end sim:/testbench/processor_instance/stage_if_inst/current_pc
    add wave -radix binary -position end sim:/testbench/processor_instance/stage_id_inst/instruction
    ;#add wave -position end sim:/testbench/processor_instance/stage_id_inst/stall
    ;#add wave -position end sim:/testbench/processor_instance/stage_ex_inst/ignore_stall
    add wave -radix unsigned -position end sim:/testbench/processor_instance/stage_id_inst/ctrl
    add wave -radix unsigned -position end sim:/testbench/processor_instance/stage_ex_inst/ctrl_out
    add wave -radix unsigned -position end sim:/testbench/processor_instance/stage_mem_inst/ctrl_out
    add wave -position end sim:/testbench/processor_instance/stage_if_inst/predictTable
    add wave -position end sim:/testbench/processor_instance/regs/reg_block
    ;#add wave -position end sim:/testbench/processor_instance/stage_mem_inst/main_memory_inst/ram_block
}

vlib work

;# Compile files
vcom signals.vhd

vcom alu.vhd
vcom registers.vhd
vcom memory.vhd

vcom stage_if.vhd
vcom stage_id.vhd
vcom stage_ex.vhd
vcom stage_mem.vhd

vcom processor.vhd
vcom testbench.vhd

;# Start simulation
vsim testbench

;# Generate a clock with 1ns period (1 GHz frequency as per project specification)
force -deposit clock 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
AddWaves

;# Run long enough to complete two 10,000 clock cycle long programs
run 20100 ns

;# Show to first few clock cycles in the window
wave zoom range 0ns 20ns