class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
    
    function new(string name="scoreboard",uvm_component parent=null);
        super.new(name, parent);
    endfunction

    bit mantissa_Z, mantissa_X, mantissa_Y;
    bit exp_Z, exp_X, exp_Y;
    bit sign_Z, sign_X, sign_Y;

    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        
      	super.build_phase(phase);
      
        m_analysis_imp = new("m_analysis_imp",this);

    endfunction

  virtual function write();
  //referencia para comprobar funcionamiento de DUT

  //se toma el numero X
  mantissa_X={1'b1,item.fp_X[22:0]};
  exp_X=item.fp_X[30:23];
  sign_X=item.fp_X[31];

  

  //se toma el numero Y
  mantissa_Y={1'b1, item.fp_Y[22:0]};
  exp_Y=item.fp_Y[30:23];
  sign_Y=item.fp_Y[31];

  //se multiplican las mantissas de X y Y
  mantissa_Z=mantissa_X*mantissa_Y;

  //se calcula el exponente Z
  exp_Z=exp_X+exp_Y-127;

  
  $display("mantissa X: %0d, mantissa Y: %0d, mantissa Z: %0d", mantissa_X, mantissa_Y, mantissa_Z);
  $display("exp X: %0d, exp Y: %0d, exp Z: %0d", exp_X, exp_Y, exp_Z);




  endfunction
    
endclass