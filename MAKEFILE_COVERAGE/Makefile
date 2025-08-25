##################################################################################################
# This file created by Huy Nguyen (Modified for Linux by ChatGPT)
# Created date: 7/1/2019
# Example run string: make {optional} TESTNAME={name_of_testcase} 
#                    make all TESTNAME=test_reg 
##################################################################################################
# Define variables
export PATH := /home/meynchan/questasim/questa_fse/bin:$(PATH)
TESTNAME        ?= default_value_test
TB_NAME         ?= tb_ip_TIMER
RADIX           ?= hexadecimal
REGRESS_LIST    ?= regress.list
SRCLIST_V_T     ?= compile
macro_en        ?=

#================================================================================================
all: build run

regression: build create_test_list regress report
regression_cov: build create_test_list regress_cov gen_cov

build:
	mkdir -p log
	touch run_test.vt
	vlib work
	vmap work work
	vlog -coveropt 3 +cover +acc -f $(SRCLIST_V_T).f

run:	
#	cp -rf tb/$(TESTNAME).vt run_test.vt
	vlog $(macro_en) -f compile.f
	vsim -l $(TESTNAME).log -voptargs=+acc -assertdebug -c $(TB_NAME) -do "log -r /*; run -all;"
	mv $(TESTNAME).log ./log
	cp -rf vsim.wlf $(TESTNAME).wlf
	mv $(TESTNAME).wlf ./log
	ln -sf ./log/$(TESTNAME).log sim.log

find:
	find tb

create_test_list:  
	find tb -type f -printf "%f\n" | sed 's/.vt//' | tee $(REGRESS_LIST) | wc -l

regress:
	./run_all.sh run

regress_cov:
	./run_all.sh run_cov

wave:
	vsim -i -view vsim.wlf -do "add wave vsim:/$(TB_NAME)/*; radix -$(RADIX)"

run_cov:
	cp -rf tb/$(TESTNAME).vt run_test.vt
	vlog +cover=sbceftx -f compile.f
	vsim -coverage -l $(TESTNAME).log -c $(TB_NAME) -voptargs="+cover=bcesfx" -novopt -assertdebug -do "coverage save -onexit $(TESTNAME).ucdb; log -r -d 6 /*; run -all"
	mv $(TESTNAME).log ./log

gen_cov:
	mkdir -p coverage
	vcover merge IP.ucdb *.ucdb
	vcover report IP.ucdb -file coverage/summary_report.txt
	vcover report -zeros -details -code bcefsx -All -codeAll IP.ucdb -file coverage/detail_report.txt

clean:
	rm -rf work log *.ini *.log *.wlf transcript coverage *.ucdb *.list *.vt

report:
	grep "passed" ./log/*.log -R

