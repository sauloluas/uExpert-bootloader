simSetSimulator "-vcssv" -exec "/tmp/rv32im-core-vcs-1060/tb_baremetal/simv" \
           -args \
           "-i /home/ciexpert/saulo.teipel/riscv-rv32im-core-main/sim/vcs/waves/tb_baremetal.tcl +test=boot_test +mem=/tmp/rv32im-core-software-1060/boot_test.mem" \
           -uvmDebug on -simDelim
debImport "-i" "-simflow" "-dbdir" \
          "/tmp/rv32im-core-vcs-1060/tb_baremetal/simv.daidir"
srcTBInvokeSim
# tb_baremetal.tcl - VCS/Verdi (equivalente a sim/questa/waves/tb_baremetal.do)
# O alvo vcs-gui exporta FSDB_FILE no ambiente antes de chamar este script.

# ---------- FSDB dump ----------
if {[info exists env(FSDB_FILE)]} {
    fsdbDumpfile $env(FSDB_FILE)
} else {
    fsdbDumpfile "tb_baremetal.fsdb"
}

# Dump completo do harness e do DUT (precisamos de hierarquia para achar
# regfile, pipeline registers, sinais de trace, etc.)
fsdbDumpvars 0 tb_baremetal "+all"
fsdbDumpvars 1 tb_baremetal/dut "+all"
fsdbDumpMDA 0 tb_baremetal

# ---------- Run ----------
run
quit
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "perf_mem_stall" -line 344 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "trace_rd_we" -line 296 -pos 1 -win $_nTrace1
wvCreateWindow
verdiSetActWin -win $_nWave3
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvAddSignal -win $_nWave3 "/tb_baremetal/trace_rd_we"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvSetPosition -win $_nWave3 {("G1" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "trace_rd_data" -line 298 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvSetPosition -win $_nWave3 {("G2" 0)}
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G2" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvAddSignal -win $_nWave3 "/tb_baremetal/trace_rd_data\[31:0\]"
wvSetPosition -win $_nWave3 {("G1" 1)}
wvSetPosition -win $_nWave3 {("G1" 2)}
verdiSetActWin -win $_nWave3
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "trace_rd_data" -line 298 -pos 1 -win $_nTrace1
srcAction -pos 297 1 11 -win $_nTrace1 -name "trace_rd_data" -ctrlKey off
verdiSetActWin -dock widgetDock_<Member>
verdiSetActWin -win $_nWave3
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvSetCursor -win $_nWave3 426556.519836 -snap {("G1" 2)}
wvSetCursor -win $_nWave3 428871.305492 -snap {("G1" 2)}
wvZoomIn -win $_nWave3
srcDeselectAll -win $_nTrace1
srcSelect -signal "trace_taken_o" -line 255 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave3 {("G1" 1)}
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G2" 0)}
wvSetPosition -win $_nWave3 {("G1" 2)}
wvAddSignal -win $_nWave3 "/tb_baremetal/dut/trace_taken_o"
wvSetPosition -win $_nWave3 {("G1" 2)}
wvSetPosition -win $_nWave3 {("G1" 3)}
verdiSetActWin -win $_nWave3
srcDeselectAll -win $_nTrace1
srcSelect -signal "trace_insn_o" -line 244 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "trace_rd_addr_o" -line 246 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "trace_mem_wstrb_o" -line 249 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "trace_mem_addr_o" -line 248 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 239 1 9 -win $_nTrace1 -name \
          "// MEM/WB is the only trace source; traps are events, not retirements." \
          -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 239 1 4 -win $_nTrace1 -name \
          "// MEM/WB is the only trace source; traps are events, not retirements." \
          -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 239 1 8 -win $_nTrace1 -name \
          "// MEM/WB is the only trace source; traps are events, not retirements." \
          -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {240 240 2 2 2 11}
srcDeselectAll -win $_nTrace1
srcSelect -signal "mtimer_irq_eligible_after_commit_o" -line 237 -pos 1 -win \
          $_nTrace1
srcAction -pos 236 2 9 -win $_nTrace1 -name "mtimer_irq_eligible_after_commit_o" \
          -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 71 1 28 -win $_nTrace1 -name \
          "// Eligibility is architectural state only; precise take/injection remains" \
          -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 71 1 27 -win $_nTrace1 -name \
          "// Eligibility is architectural state only; precise take/injection remains" \
          -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 71 1 27 -win $_nTrace1 -name \
          "// Eligibility is architectural state only; precise take/injection remains" \
          -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 71 1 27 -win $_nTrace1 -name \
          "// Eligibility is architectural state only; precise take/injection remains" \
          -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 71 1 27 -win $_nTrace1 -name \
          "// Eligibility is architectural state only; precise take/injection remains" \
          -ctrlKey off
srcDeselectAll -win $_nTrace1
srcAction -pos 71 1 27 -win $_nTrace1 -name \
          "// Eligibility is architectural state only; precise take/injection remains" \
          -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
debExit
