transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+G:/My\ Drive/FPGA\ Design/SPI\ Interface/SPI\ Verilog\ Projects/SPI\ for\ LTC2668\ and\ LTC2494/SPI {G:/My Drive/FPGA Design/SPI Interface/SPI Verilog Projects/SPI for LTC2668 and LTC2494/SPI/SPIMaster.v}
vlog -vlog01compat -work work +incdir+G:/My\ Drive/FPGA\ Design/SPI\ Interface/SPI\ Verilog\ Projects/SPI\ for\ LTC2668\ and\ LTC2494/SPI {G:/My Drive/FPGA Design/SPI Interface/SPI Verilog Projects/SPI for LTC2668 and LTC2494/SPI/MasterDriver.v}
vlog -vlog01compat -work work +incdir+G:/My\ Drive/FPGA\ Design/SPI\ Interface/SPI\ Verilog\ Projects/SPI\ for\ LTC2668\ and\ LTC2494/SPI {G:/My Drive/FPGA Design/SPI Interface/SPI Verilog Projects/SPI for LTC2668 and LTC2494/SPI/CLOCK.v}
vlog -vlog01compat -work work +incdir+G:/My\ Drive/FPGA\ Design/SPI\ Interface/SPI\ Verilog\ Projects/SPI\ for\ LTC2668\ and\ LTC2494/SPI {G:/My Drive/FPGA Design/SPI Interface/SPI Verilog Projects/SPI for LTC2668 and LTC2494/SPI/datadriver.v}
vlog -vlog01compat -work work +incdir+G:/My\ Drive/FPGA\ Design/SPI\ Interface/SPI\ Verilog\ Projects/SPI\ for\ LTC2668\ and\ LTC2494/SPI {G:/My Drive/FPGA Design/SPI Interface/SPI Verilog Projects/SPI for LTC2668 and LTC2494/SPI/ClockDivider.v}
vlog -vlog01compat -work work +incdir+G:/My\ Drive/FPGA\ Design/SPI\ Interface/SPI\ Verilog\ Projects/SPI\ for\ LTC2668\ and\ LTC2494/SPI/db {G:/My Drive/FPGA Design/SPI Interface/SPI Verilog Projects/SPI for LTC2668 and LTC2494/SPI/db/clock_altpll.v}

vlog -sv -work work +incdir+G:/My\ Drive/FPGA\ Design/SPI\ Interface/SPI\ Verilog\ Projects/SPI\ for\ LTC2668\ and\ LTC2494/SPI {G:/My Drive/FPGA Design/SPI Interface/SPI Verilog Projects/SPI for LTC2668 and LTC2494/SPI/SPIDAC.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneiii_ver -L rtl_work -L work -voptargs="+acc"  SPIDAC

add wave *
view structure
view signals
run -all
