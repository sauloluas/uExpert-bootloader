# Single source of truth consumed by both root and software Makefiles.
BAREMETAL_PROGRAMS := smoke trap boot_test

BENCHMARK_PROGRAMS := \
	bench_arithmetic \
	bench_branch \
	bench_memory \
	bench_mdu
