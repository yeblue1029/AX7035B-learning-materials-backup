onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+ila_m0 -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ila_m0 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {ila_m0.udo}

run -all

endsim

quit -force
