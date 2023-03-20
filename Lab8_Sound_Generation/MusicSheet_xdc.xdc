## Clock signal
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clock }]; #IO_L12P_T1_MRCC_35 Sch=clk100mhz
#create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {CLK100MHZ}];

##Switches
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { playSound }]; #IO_L24N_T3_RS0_15 Sch=sw[0]

##Buttons
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { reset }]; #IO_L9P_T1_DQS_14 Sch=btnc

##PWM Audio Amplifier
set_property -dict { PACKAGE_PIN A11 IOSTANDARD LVCMOS33 } [get_ports { audioOut }]; #IO_L4N_T0_15 Sch=aud_pwm
set_property -dict { PACKAGE_PIN D12 IOSTANDARD LVCMOS33 } [get_ports { aud_sd }]; #IO_L6P_T0_15 Sch=aud_sd