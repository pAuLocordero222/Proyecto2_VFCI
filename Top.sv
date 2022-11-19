`include "uvm_macros.svh"
import uvm_pkg::*;
`include "DUT_MUL.sv"
`include "Interface.sv"
`include "Seq_item.sv"
`include "Sequence.sv"
`include "Monitor.sv"
`include "Driver.sv"
`include "Scoreboard.sv"
`include "Agent.sv"
`include "Environment.sv"
`include "Test.sv"

module tb;

	reg clk;

	always #10 clk =~ clk;
	dut_if _if(clk);
	
	top dut0(
	.clk (clk),
	.r_mode(_if.r_mode),
	.fp_X(_if.fp_X), .fp_Y(_if.fp_Y),
	.fp_Z(_if.fp_Z),
	.ovrf(_if.ovrf), .udrf(_if.udrf));


	initial begin
		clk <= 0;
        uvm_config_db#(virtual dut_if)::set(null,"uvm_test_top","dut_vif",_if);

		run_test("test1");
	end

endmodule