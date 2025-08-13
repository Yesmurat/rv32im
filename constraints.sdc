create_clock -name clk -period 10.0 [get_ports {clk}]
set_false_path -from [get_ports {clr}] -to [get_keepers {clr}]