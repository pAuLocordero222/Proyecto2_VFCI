class rand_sequence extends uvm_sequence;
    `uvm_object_utils(rand_sequence)

    function new (string name = "rand_sequence");
        super.new (name);
    endfunction

    rand int num;

    constraint c_num{soft num inside {[10:20]};}

    virtual task body();
        `uvm_info("Sequence","Start of random sequence", UVM_HIGH);
        for(int i = 0; i < num; i++) begin
            Item item = Item::type_id::create("m_item");

            //Constraint modes
            item.c_rand_data.constraint_mode(1);
            item.c_r_mode.constraint_mode(1);
            start_item(item);
            item.randomize();
            //`uvm_info("SEQ",$sformatf("New item: %s", item.convert2str()), UVM_HIGH);
            finish_item(item);
        end
        //`uvm_info("SEQ",$sformatf("Done generation of %0d items", num),UVM_LOW);

    endtask

endclass

class ovrf_seq extends uvm_sequence;
    `uvm_object_utils(ovrf_seq);
  
    function new(string name="ovrf_seq");
        super.new(name);
    endfunction

    rand int num;
    constraint c_num{soft num inside {[10:20]};}

    virtual task body();
        for(int i = 0; i < num; i++) begin
            Item item = Item::type_id::create("m_item");

            //Constraint modes
            item.c_rand_data.constraint_mode(0);
            item.c_r_mode.constraint_mode(1);
            item.c_ovrf.constraint_mode(1);
            item.c_udrf.constraint_mode(0);
            item.c_ovrf.constraint_mode(0);
            item.c_nan.constraint_mode(0);
     
            start_item(item);
            item.randomize();
            finish_item(item);
        end

    endtask
endclass

class udrf_seq extends uvm_sequence;
    `uvm_object_utils(udrf_seq);
  
    function new(string name="udrf_seq");
        super.new(name);
    endfunction

    rand int num;
    constraint c_num{soft num inside {[10:20]};}

    virtual task body();
        for(int i = 0; i < num; i++) begin
            Item item = Item::type_id::create("m_item");

            //Constraint modes
            item.c_rand_data.constraint_mode(0);
            item.c_r_mode.constraint_mode(1);
            item.c_ovrf.constraint_mode(0);
            item.c_udrf.constraint_mode(1);
            item.c_ovrf.constraint_mode(0);
            item.c_nan.constraint_mode(0);
     
            start_item(item);
            item.randomize();
            finish_item(item);
        end

    endtask
endclass


class nan_seq extends uvm_sequence;
    `uvm_object_utils(nan_seq);
  
    function new(string name="nan_seq");
        super.new(name);
    endfunction

    rand int num;
    constraint c_num{soft num inside {[10:20]};}

    virtual task body();
        for(int i = 0; i < num; i++) begin
            Item item = Item::type_id::create("m_item");

            //Constraint modes
            item.c_rand_data.constraint_mode(0);
            item.c_r_mode.constraint_mode(1);
            item.c_ovrf.constraint_mode(0);
            item.c_udrf.constraint_mode(0);
            item.c_ovrf.constraint_mode(0);
            item.c_nan.constraint_mode(1);
     
            start_item(item);
            item.randomize();
            finish_item(item);
        end

    endtask
endclass

//------------------------------------------------------
class seq_caso1 extends uvm_sequence;//secuencia con una serie de valores randomizados

    `uvm_object_utils(seq_caso1);

    function new(string name="seq_esc1");
        super.new(name);
    endfunction

    rand_sequence rndm_seq;

    task body();
        `uvm_do(rndm_seq);
    endtask 

endclass

class seq_caso_esquina extends uvm_sequence;

    `uvm_object_utils(seq_caso_esquina);

    function new(string name="seq_caso_esquina");
        super.new(name);
    endfunction

    ovrf_seq of_seq;
    udrf_seq uf_seq;
    nan_seq nn_seq;

    task body();
        `uvm_do(of_seq);
        `uvm_do(uf_seq);
        `uvm_do(nn_seq);
    endtask 

endclass
