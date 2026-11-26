# Shared GUI policy for the VCS/Verdi flow — analogue of
# sim/questa/waves/common.do. Signal selection stays in each
# test-specific file so every screenshot has an explicit purpose.

# Questa paths look like "sim:/scope/sig"; DVE/Verdi use "/scope/sig".
proc _vcs_norm {p} { return [regsub {^sim:/} $p {}] }

proc wave_divider {label} {
  add wave -noupdate -divider $label
}

proc wave_logic {path} {
  set p [_vcs_norm $path]
  if {[catch {add wave -noupdate $p} reason]} {
    puts "WAVE NOTE: skipped $p ($reason)"
  }
}

proc wave_hex {path} {
  set p [_vcs_norm $path]
  if {[catch {add wave -noupdate -radix hexadecimal $p} reason]} {
    puts "WAVE NOTE: skipped $p ($reason)"
  }
}

proc wave_unsigned {path} {
  set p [_vcs_norm $path]
  if {[catch {add wave -noupdate -radix unsigned $p} reason]} {
    puts "WAVE NOTE: skipped $p ($reason)"
  }
}

proc wave_finish {} {
  catch {update}
  run -all
  catch {wave zoom full}
}
