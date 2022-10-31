class rand_sequence extends uvm_sequence;
    `uvm_object_utils(rand_sequence)

    function new (string name = "rand_sequence");
        super.new (name);
    endfunction

    rand int num;

    constraint c_num{soft num inside {[4:8]};}

    virtual task body();
        `uvm_info("Sequence","Start of random sequence", UVM_HIGH);
        for(int i = 0; i < num; i++) begin
            Item item = Item::type_id::create("m_item");

            //Constraint modes
            item.c_rand_data.constraint_mode(1);
            item.c_r_mode.constraint_mode(1);
            start_item(item);
            item.randomize();
            `uvm_info("SEQ",$sformatf("New item: %s", item.convert2str()), UVM_HIGH);
            finish_item(item);
        end
        `uvm_info("SEQ",$sformatf("Done generation of %0d items", n),UVM_LOW);

    endtask

endclass

class seq_caso1 extends uvm_sequence;

    `uvm_object_utils(seq_caso1);

    function new(string name="seq_esc1");
        super.new(name);
    endfunction

    rand_sequence rndm_seq;

    task body();
        `uvm_do(rndm_seq);
    endtask 

endclass