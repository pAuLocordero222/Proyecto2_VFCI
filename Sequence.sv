class rand_sequence extends uvm_sequence;
    `uvm_object_utils(rand_sequence)

    function new (string name = "rand_sequence");
        super.new (name);
    endfunction

    rand int num;

    constraint c_num{soft num inside {[4:8]};}

    virtual task body ();
        `uvm_info("Start of random sequence.", UVM_HIGH);
        for(int i = 0; i < num; i++) begin
            Item m_item = Item::type_id::create("m_item");

            //Constraint modes
            m_item.c_rand_data.constraint_mode(1);
            m_item.c_r_mode.constraint_mode(1);
            start_item(m_item);
            m_item.randomize();
            `uvm_info("SEQ",$sformatf("New item: %s", item.convert2str()), UVM_HIGH);
            finish_item(m_item);
        end
        `uvm_info("SEQ",$sformatf("Done generation of %0d items", n),UVM_LOW);

    endtask