# Gate 2: RV32M MUL/MULH/MULHSU/MULHU request/response and backpressure.
# VCS/Verdi analogue of sim/questa/waves/tb_mul_unit.do.
source [file join [file dirname [info script]] common.tcl]

# FSDB dump via UCLI — the .sv testbenches stay clean.
if {[info exists ::env(FSDB_FILE)] && $::env(FSDB_FILE) ne ""} {
  set _fsdb $::env(FSDB_FILE)
} else {
  set _fsdb "tb_mul_unit.fsdb"
}
call [format {$fsdbDumpfile("%s")} $_fsdb]
call {$fsdbDumpvars(0, tb_mul_unit)}

wave_divider {CLOCK / RESET}
wave_logic sim:/tb_mul_unit/clk
wave_logic sim:/tb_mul_unit/rst
wave_logic sim:/tb_mul_unit/kill

wave_divider {REQUEST}
wave_logic sim:/tb_mul_unit/req_valid
wave_logic sim:/tb_mul_unit/req_ready
wave_logic sim:/tb_mul_unit/op
wave_hex   sim:/tb_mul_unit/lhs
wave_hex   sim:/tb_mul_unit/rhs

wave_divider {MULTIPLIER STATE}
wave_logic sim:/tb_mul_unit/dut/state_q
wave_logic sim:/tb_mul_unit/dut/op_q
wave_hex   sim:/tb_mul_unit/dut/lhs_q
wave_hex   sim:/tb_mul_unit/dut/rhs_q
wave_hex   sim:/tb_mul_unit/dut/product

wave_divider {RESPONSE / BACKPRESSURE}
wave_logic sim:/tb_mul_unit/rsp_valid
wave_logic sim:/tb_mul_unit/rsp_ready
wave_hex   sim:/tb_mul_unit/result
wave_unsigned sim:/tb_mul_unit/checks

wave_finish
