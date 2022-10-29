class driver extends uvm_driver #(Item);
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

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      Item m_item;
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_HIGH);
      seq_item_port.get_next_item(m_item);
      drive_item(m_item);
      seq_item_port.item_done();
    end    
  endtask

  virtual task drive_item(Item m_item);
    @(vif.cb);
      vif.cb.fp_X <= m_item.fp_X;
      vif.cb.fp_Y <= m_item.fp_Y;
      vif.cb.r_mode <= m_item.r_mode;
  endtask

endclass