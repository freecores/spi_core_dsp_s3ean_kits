//************
//  Verilog Testbench - top level
//  Matt Pepe <mtpepe@gwu.edu>
//
//*************

event	tb_in_strobe, tb_out_strobe, tb_test_cycle_strobe;

// Testbench clock variables
reg	tb_clk;
integer	tb_test_cycle_number, tb_max_cycle, tb_err_c, tb_errcode;
integer	tb_error_limit;

// Testbench clock
initial begin
	tb_test_cycle_number = 1;
	tb_clk = 0;
	tb_err_c = 0;
	tb_errcode = 0;
	tb_error_limit = 5;

	forever begin
	fork
		#20	tb_clk = 1;
		#40	tb_clk = 0;
		#60	-> tb_in_strobe;
		#99	-> tb_out_strobe;
		#100	-> tb_test_cycle_strobe;
	join
	tb_test_cycle_number = tb_test_cycle_number + 1;
	end
end // testbench clock

// Error Monitor
initial begin
	forever begin
		@(tb_out_strobe);
		if (tb_err_c >= tb_error_limit)
		begin
			tb_errcode = 2;
			exit_sim;
		end
	end
end

// Testbench exit task
task exit_sim;
begin
	$display("Simulation exiting.  Error code %d.", tb_errcode);
	case (tb_errcode)
		0:	$display(" - Simulation Completed with %d errors.", tb_err_c);
		2:	$display(" - Error limit exceeded.");
	endcase
	$finish;
end
endtask

// Testbench Cycle Error task
task cyc_err;
begin
	tb_err_c <= tb_err_c + 1;
	$display(" Cycle output error.");
end
endtask

// Testbench End-Of-Cycle
always @(tb_test_cycle_strobe)
begin
	if (tb_test_cycle_number == tb_max_cycle)
	begin
		dut_finish;
		tb_errcode = 0;
		exit_sim;
	end
end
