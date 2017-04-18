onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dlx_testbench/CLK
add wave -noupdate /dlx_testbench/RST
add wave -noupdate /dlx_testbench/TO_IRAM_I
add wave -noupdate /dlx_testbench/FROM_IRAM_I
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/REGISTERFILE/REGISTERS
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/REGISTERFILE/ADD_WR
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/REGISTERFILE/ADD_RD1
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/REGISTERFILE/ADD_RD2
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/REGISTERFILE/DATAIN
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/MY_ALU/FUNC
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/MY_ALU/DATA1
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/MY_ALU/DATA2
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/MY_ALU/OUTALU
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/IN_DRAM
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/DATA_DRAM
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/out_A
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/out_B
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/IN_LMD
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/LMD_LATCH_EN
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/WB_MUX_SEL
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/in_addr_dram
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/in_data_dram
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/out_lmd
add wave -noupdate /dlx_testbench/MyDRAM/MY_DRAM
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/out_muxa
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/out_muxb
add wave -noupdate /dlx_testbench/My_DLX/BRANCH_EN_i
add wave -noupdate /dlx_testbench/My_DLX/BRANCH_TYPE_i
add wave -noupdate /dlx_testbench/My_DLX/TAKEN_i
add wave -noupdate /dlx_testbench/My_DLX/CU_I/OPCODE
add wave -noupdate /dlx_testbench/My_DLX/CU_I/FUNC
add wave -noupdate /dlx_testbench/My_DLX/CU_I/aluOpcode_i
add wave -noupdate /dlx_testbench/My_DLX/CU_I/aluOpcode1
add wave -noupdate /dlx_testbench/My_DLX/CU_I/cw0
add wave -noupdate /dlx_testbench/My_DLX/CU_I/cw1
add wave -noupdate /dlx_testbench/My_DLX/CU_I/cw2
add wave -noupdate /dlx_testbench/My_DLX/CU_I/cw3
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/MUXA_SEL
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/MUXB_SEL
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/RF_WE
add wave -noupdate /dlx_testbench/My_DLX/SEL_MUX_PC_i
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/address_in_PC
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/SEL_MUX_PC
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/my_taken
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/address_in_PC
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/data_out_IR
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/adder_out
add wave -noupdate /dlx_testbench/My_DLX/DATAPATH_I/out_adder_branch
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7500 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 178
configure wave -valuecolwidth 92
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {5380 ps} {9260 ps}
