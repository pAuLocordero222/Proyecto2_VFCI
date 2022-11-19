class Item extends uvm_sequence_item;
    `uvm_object_utils(Item)
    rand bit [2:0] r_mode;
    rand bit [31:0] fp_X;
    rand bit [31:0] fp_Y;
    bit [31:0] fp_Z;
    bit ovrf;
    bit udrf;

    virtual function string convert2str();
        return $sformatf("r_mode=%0h, fp_X=%0h, fp_Y=%0h, fp_Z=%0h, ovrf=%0h, udrf=%0h", r_mode, fp_X, fp_Y, fp_Z, ovrf, udrf);
    endfunction
    
    function new(string name = "Item");
        super.new(name);
    endfunction

    //constraints
    constraint c_rand_data  {

    // Exponente
    fp_X[30:23] <= 8'hFE;
    fp_Y[30:23] <= 8'hFE;

    //Fraccion
    //fp_X[22:0] <= 23'h8F;
    //fp_Y[22:0] <= 23'h8F; 

    }

    constraint c_r_mode {r_mode<=3'b100;}

endclass