source synopsys_tools.sh;
rm -rfv ls |grep -v ".*\.sv\|.*\.sh";

vcs -Mupdate Top.sv -o salida -full64 -sverilog -kdb -debug_acc+all -debug_region+cell+encrypt -l log_test -ntb_opts uvm +lint=TFIPC-L -cm line+tgl+cond+fsm+branch+assert


./salida +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNME=test1 +ntb_random_seed=1
dve -full64 -covdir salida.vdb &
