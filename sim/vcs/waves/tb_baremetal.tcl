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
