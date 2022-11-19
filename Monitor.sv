class monitor extends uvm_monitor;
    `uvm_component_utils(monitor);

    function new(string name="monitor", uvm_component parent =null);
		super.new(name, parent);
	endfunction

    virtual dut_if vif;
    uvm_analysis_port #(Item) mon_analysis_port;

    virtual function void build_phase (uvm_phase phase);
		super.build_phase (phase);

		mon_analysis_port = new("mon_analysis_port", this);

		if (!uvm_config_db #(virtual dut_if) :: get (this, "", "dut_vif", vif)) 
			`uvm_fatal (get_type_name (),  "DUT interface not found")

	endfunction

    virtual task run_phase (uvm_phase phase);
		super.run_phase(phase);
		forever @(vif.cb) begin

					Item item = Item::type_id::create("item");
					item.fp_Z = vif.cb.fp_Z;   //Salida
                    item.ovrf = vif.cb.ovrf;   // overflow
                    item.udrf = vif.cb.udrf;   //underflow

                    item.r_mode = vif.r_mode;  //mode
                    item.fp_X = vif.fp_X;      //A
                    item.fp_Y = vif.fp_Y;      //B
					mon_analysis_port.write(item);
					`uvm_info("MON", $sformatf("SAW item %h", item.convert2str()), UVM_HIGH)

		end
	endtask

endclass
