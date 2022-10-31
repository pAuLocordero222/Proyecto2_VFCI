class test extends uvm_test;
    `uvm_component_utils(test)
    function new(string name = "test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    environment e0;
    virtual dut_if vif;
    rand_sequence seq;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        e0 = environment::type_id::create("e0", this);

        if(!uvm_config_db#(virtual dut_if)::get(this, "", "dut_vif",vif))
            `uvm_fatal("TEST","Did not get vif")
        uvm_config_db#(virtual dut_if)::set(this, "e0.a0.*","dut_vif",vif);

        seq = rand_sequence::type_id::create("seq");
        seq.randomize();
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq.start(e0.a0.s0);
        #200;
        phase.drop_objection(this);
    endtask

endclass

class test1 extends test;
    `uvm_component_utils(test1);
    function new(string name="test1", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    seq_caso1 seq;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        seq = seq_caso1::type_id::create("seq");
        seq.randomize();

    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info("TEST_01", "Starting test execution", UVM_HIGH)
        phase.raise_objection(this);
        seq.start(e0.a0.s0);
        #200;
        phase.drop_objection(this);
    endtask

endclass