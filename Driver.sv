class driver extends uvm_driver;
    `uvm_component_utils(driver)

    function new (string name = "driver", uvm_component parent = null);
        super.new (name, parent);
    endfunction

    virtual dut_if vif;

    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        if (! uvm_config_db #(virtual dut_if) :: get (this, "", "vif", vif)) begin
            `uvm_fatal (get_type_name (), "Didn't get handle to virtual interface dut_if")   
        end
    endfunction

    \\Code

endclass