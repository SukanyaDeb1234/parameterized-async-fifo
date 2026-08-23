# =========================================================
# ASYNCHRONOUS FIFO CLOCK CONSTRAINTS
# =========================================================

# Write clock: 60 ns period = 16.667 MHz
create_clock -name w_clk -period 60.000 [get_ports w_clk]

# Read clock: 50 ns period = 20 MHz
create_clock -name r_clk -period 50.000 [get_ports r_clk]


# The read and write clocks are asynchronous
# and should not be timed against each other.
set_clock_groups -asynchronous \
    -group [get_clocks w_clk] \
    -group [get_clocks r_clk]