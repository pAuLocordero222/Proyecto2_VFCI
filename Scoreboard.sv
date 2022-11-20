class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
    
    function new(string name="scoreboard",uvm_component parent=null);
        super.new(name, parent);
    endfunction

    bit [23:0]  mantissa_X, mantissa_Y;
    bit [47:0] mantissa_Z;
    bit [7:0] exp_Z, exp_X, exp_Y;
    bit sign_Z, sign_X, sign_Y;

    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        
      	super.build_phase(phase);
      
        m_analysis_imp = new("m_analysis_imp",this);

    endfunction

  virtual function write(Item item);
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

  
  $display("mantissa X: %0h, mantissa Y: %0h, mantissa Z: %0h", mantissa_X, mantissa_Y, mantissa_Z);
  $display("exp X: %0h, exp Y: %0h, exp Z: %0h", exp_X, exp_Y, exp_Z);
  $display("---------------------------------------------------------------------------------------------------------");
/*
  //se normaliza de ser necesario
  if (mantissa_Z[47])  begin
    mantissa_Z = mantissa_Z << 1; //se hace un shift a la izquierda
    exp_Z = exp_Z+1; //se suma 1 al exponente
  end
  bit [26:0]mantissa_Z_norm=mantissa_Z[46:20];//en el numero Z se conservan solo los bits necesarios para redondear

  //se toman
  bit round=mantissa_Z_norm[2];
  bit guard=mantissa_Z_norm[1];
  bit guard=mantissa_Z_norm[0];
  bit Z = [2:0]mantissa_Z_norm;  //24 bits mas significativos de la mantisa
  bit Z_plus=Z+1; // Z + 1

  case(item.r_mode)
    3'b000:begin
    end

    3'b001:begin
    end    

    3'b010:begin
    end

    3'b011:begin
    end

    3'b100:begin
    end
  endcase
*/

  endfunction
    
endclass