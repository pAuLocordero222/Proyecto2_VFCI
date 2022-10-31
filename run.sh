source synopsys_tools.sh;
rm -rfv ls |grep -v ".*\.sv\|.*\.sh";

vcs -Mupdate Testbench.sv -o salida -full64 -debug_all -sverilog -l log_test +lint=TFIPC-L -cm line+tgl+cond+fsm+branch+assert;

./salida -cm line+tgl+cond+fsm+branch+assert;
dve -full64 -covdir salida.vdb &