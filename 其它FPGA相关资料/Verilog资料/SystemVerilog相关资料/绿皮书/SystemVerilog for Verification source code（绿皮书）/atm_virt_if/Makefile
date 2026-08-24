FILES = top.sv atm.sv atm_if.sv atm_cell.sv scoreboard.sv driver.sv monitor.sv atm_router.sv test.sv 
FLAGS = -sverilog -debug -ntb_opts dtm

run:	simv
	simv -l sim.log

simv:   ${FILES} ${IFILES}
	vcs ${FLAGS} -l comp.log ${FILES}

gui:	simv
	./simv -gui

waves:	${FILES}  ${IFILES}
	vcs -sverilog -RI -debug_all +cfgfile+default.cfg -l simv.log ${FILES}


DIR = $(shell basename `pwd`)

tar:	clean
	cd ..; \
	tar cvf ${DIR}.tar ${DIR}

clean:
	@rm -rf simv* csrc* *.log *.key core* .__solver* vcdplus.vpd
	@rm -rf  vera*.rc  .vera_debugger_rc.lock *~ .__snps* 
