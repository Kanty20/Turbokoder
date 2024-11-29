set_property PACKAGE_PIN U4 [get_ports RST]
set_property IOSTANDARD LVCMOS18 [get_ports RST]

set_property IOSTANDARD LVCMOS18 [get_ports {TX[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {TX[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {TX[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {TX[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {TX[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {TX[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {TX[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {TX[0]}]

set_property DRIVE 8 [get_ports {TX[7]}]
set_property DRIVE 8 [get_ports {TX[6]}]
set_property DRIVE 8 [get_ports {TX[5]}]
set_property DRIVE 8 [get_ports {TX[4]}]
set_property DRIVE 8 [get_ports {TX[3]}]
set_property DRIVE 8 [get_ports {TX[2]}]
set_property DRIVE 8 [get_ports {TX[1]}]
set_property DRIVE 8 [get_ports {TX[0]}]

set_property IOSTANDARD LVCMOS18 [get_ports {RX[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {RX[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {RX[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {RX[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {RX[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {RX[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {RX[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {RX[0]}]

set_property CONFIG_VOLTAGE 3.3 [current_design]
#vcco or gnd
set_property CFGBVS VCCO [current_design]
#provided to configuration bank 0, 3.3

set_property PACKAGE_PIN U19 [get_ports {TX[7]}]
set_property PACKAGE_PIN T19 [get_ports {RX[7]}]

set_property PACKAGE_PIN H1 [get_ports {TX[6]}]
set_property PACKAGE_PIN K3 [get_ports {TX[5]}]
set_property PACKAGE_PIN N7 [get_ports {TX[4]}]
set_property PACKAGE_PIN L5 [get_ports {TX[3]}]
set_property PACKAGE_PIN L7 [get_ports {TX[2]}]
set_property PACKAGE_PIN N6 [get_ports {TX[1]}]
set_property PACKAGE_PIN L3 [get_ports {TX[0]}]


set_property PACKAGE_PIN M6 [get_ports {RX[0]}]
set_property PACKAGE_PIN K1 [get_ports {RX[1]}]
set_property PACKAGE_PIN M7 [get_ports {RX[2]}]
set_property PACKAGE_PIN K5 [get_ports {RX[3]}]
set_property PACKAGE_PIN L4 [get_ports {RX[4]}]
set_property PACKAGE_PIN J3 [get_ports {RX[5]}]
set_property PACKAGE_PIN M4 [get_ports {RX[6]}]

set_property PACKAGE_PIN R5 [get_ports GPIO]
set_property IOSTANDARD LVCMOS18 [get_ports GPIO]

set_property IOSTANDARD LVDS_25 [get_ports CLK_p]
