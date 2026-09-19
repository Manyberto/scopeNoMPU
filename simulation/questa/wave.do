onerror {resume}
radix define States {
    "5'd0" "IDLE",
    "5'd1" "CONFIG",
    "5'd2" "READM0",
    "5'd3" "READM0_F",
    "5'd4" "WRITEM0_FB",
    "5'd5" "READM1",
    "5'd6" "READM1_F",
    "5'd7" "READM2",
    "5'd8" "READM2_F",
    "5'd9" "WRITEM2",
    "5'd10" "WRITEM2_F",
    "5'd11" "PROCESS",
    "5'd12" "PROCESS_F",
    "5'd13" "BYPASS",
    "5'd14" "BYPASS_F",
    "5'd15" "DONE",
    "5'd16" "DONE_F",
    "5'd17" "SHIFT",
    "5'd18" "RECATCH",
    "5'd19" "WAIT_M",
    "5'd20" "WAIT_F",
    "5'd21" "EMPTY",
    "5'd22" "WAIT_CONFIG",
    -default hexadecimal
}
quietly WaveActivateNextPane {} 0
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/clk
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/rstn
add wave -noupdate -color Gold /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/start
add wave -noupdate -radix hexadecimal /AIP_scopeNoMPU_tb/ID00001011/datain
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_CP/doneMapper
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_CP/doneScope
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_CP/startScope
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_CP/startMapper
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_CP/busy_flag
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_CP/done_flag
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Violet Red} -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_CP/state_next
add wave -noupdate -color {Violet Red} -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_CP/state_reg
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/data_MemInReal
add wave -noupdate -radix hexadecimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/data_MemInImag
add wave -noupdate -radix hexadecimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/dataStreamReal_in
add wave -noupdate -radix hexadecimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/dataStreamImag_in
add wave -noupdate -divider COLLECT
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_CP/startColl
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_CP/doneColl
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/sync
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/valid_data
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_CP/time_frec_mode
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/data_in
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/data_in1
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/write_addr_mem
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/write_enable_mem
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_CP/write_addr_local_mem
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_CP/write_en_local_mem
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_CP/state_next
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_CP/state_reg
add wave -noupdate -radix unsigned -childformat {{{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[0]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[1]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[2]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[3]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[4]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[5]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[6]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[7]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[8]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[9]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[10]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[11]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[12]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[13]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[14]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[15]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[16]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[17]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[18]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[19]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[20]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[21]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[22]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[23]} -radix unsigned} {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[24]} -radix unsigned}} -subitemconfig {{/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[0]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[1]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[2]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[3]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[4]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[5]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[6]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[7]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[8]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[9]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[10]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[11]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[12]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[13]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[14]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[15]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[16]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[17]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[18]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[19]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[20]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[21]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[22]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[23]} {-radix unsigned} {/AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect[24]} {-radix unsigned}} /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataCollect
add wave -noupdate -radix hexadecimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/data2Interp
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/startInterp
add wave -noupdate -radix hexadecimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/ID0000100D_DP/dataInterpOut
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/ID0000100D_COLLECTOR_CORE/write_enable_mem
add wave -noupdate -divider DECIM
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/startDecim
add wave -noupdate -radix hexadecimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/data_MemInReal
add wave -noupdate -radix hexadecimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/data_MemInImag
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/read_addr_mem
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/write_addr_DecimMem
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/write_en_DecimMem
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/dataDecimReal_out
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/dataDecimImag_out
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/doneDecim
add wave -noupdate -divider FFT
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/startFFT
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/data2FFT
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/read_addr_FFTMem
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/write_addr_FFTMem
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/write_en_FFTMem
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/dataFFTOut
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/doneFFT
add wave -noupdate -divider ModCuad
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/startModCuad
add wave -noupdate -radix decimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MODCUAD_CORE/data_MemInReal
add wave -noupdate -radix decimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MODCUAD_CORE/data_MemInImag
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/read_addr_modCuadMem
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/write_addr_modCuadMem
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/write_en_modCuadMem
add wave -noupdate -radix hexadecimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/dataCuadOut
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/doneModCuad
add wave -noupdate -divider {ModCuad - Inside}
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MODCUAD_CORE/modCuad_DP/PW2_REAL/startBoot
add wave -noupdate -radix decimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MODCUAD_CORE/modCuad_DP/PW2_REAL/data_in
add wave -noupdate -radix decimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MODCUAD_CORE/modCuad_DP/PW2_REAL/data_in
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MODCUAD_CORE/modCuad_DP/PW2_REAL/bootDone
add wave -noupdate -radix decimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MODCUAD_CORE/modCuad_DP/PW2_REAL/data_mult
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MODCUAD_CORE/modCuad_DP/PW2_REAL/data_out
add wave -noupdate -radix decimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MODCUAD_CORE/modCuad_DP/PW2_IMAG/data_in
add wave -noupdate -radix decimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MODCUAD_CORE/modCuad_DP/PW2_IMAG/data_in
add wave -noupdate -radix decimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MODCUAD_CORE/modCuad_DP/PW2_IMAG/data_mult
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MODCUAD_CORE/modCuad_DP/PW2_IMAG/data_out
add wave -noupdate -divider MTR
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/startMultirate
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/data2Multirate
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/read_addr_multirateMem
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/write_addr_multirateMem
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/write_en_multirateMem
add wave -noupdate -radix decimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/dataMultirateOut
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/doneMultirate
add wave -noupdate -divider Mapper
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/startMapper
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/data2Mapper
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/read_addr_mapperMem
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/wr_addr_mapped_localMem
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/wr_addr_mapped_localMem_reg
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/wr_en_mapped_localMem
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/dataBitMapped
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/wr_en_local_bit
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/local_bit
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/doneMapper
add wave -noupdate -divider RBM
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/RBM/wr_en
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/RBM/data_in
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/RBM/addr_in
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/RBM/data_out
add wave -noupdate -divider {Mapper - Inside}
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MAPPERCORE/SCOPEMAPPER_DP/MAPPER/data_in
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MAPPERCORE/SCOPEMAPPER_DP/MAPPER/data2compare
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MAPPERCORE/SCOPEMAPPER_DP/MAPPER/data2compareRegionSup
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MAPPERCORE/SCOPEMAPPER_DP/MAPPER/data2compareRegionInf
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MAPPERCORE/local_bit
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MAPPERCORE/wr_en_local_bit
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MAPPERCORE/SCOPEMAPPER_DP/MAPPER/row
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MAPPERCORE/SCOPEMAPPER_DP/MAPPER/col
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MAPPERCORE/SCOPEMAPPER_DP/MAPPER/map_on
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MAPPERCORE/SCOPEMAPPER_DP/MAPPER/data_out
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MAPPERCORE/SCOPEMAPPER_DP/MAPPER/validVRegion
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MAPPERCORE/SCOPEMAPPER_DP/MAPPER/validHRegion
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MAPPERCORE/write_enable_mem
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/MAPPERCORE/write_addr_mem
add wave -noupdate -divider SCOPE
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/startScope
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/data2Scope
add wave -noupdate -radix unsigned /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/rd_addr_mapped_localMem
add wave -noupdate /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/doneScope
add wave -noupdate -radix hexadecimal /AIP_scopeNoMPU_tb/ID00001011/SCOPENOMPU_CORE/SCOPENOMPU_DP/SCOPECORE/ctrlReg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {300005740 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 340
configure wave -valuecolwidth 84
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
WaveRestoreZoom {300001026 ns} {300001920 ns}
