class SeqItem extends uvm_sequence_item;
    `uvm_object_utils(SeqItem)
    rand bit [2:0] r_mode;
    rand bit [31:0] fp_X;
    rand bit [31:0] fp_Y;
    bit [31:0] fp_Z;
    bit ovrf;
    bit udrf;

    virtual function string convert2str();
        return $sformatf("r_mode=%0b, fp_X=%0b, fp_Y=%0b, fp_Z=%0b, ovrf=%0b, udrf=%0b", r_mode, fp_X, fp_Y, fp_Z, ovrf, udrf);
    endfunction
    
    function new(string name = "SeqItem");
        super.new(name);
    endfunction

    \\contraints

endclass