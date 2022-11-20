class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
    
    function new(string name="scoreboard",uvm_component parent=null);
        super.new(name, parent);
    endfunction

    bit [22:0] mantissa_X, mantissa_Y;
    bit [47:0] frac_Z_full;
    bit [47:0] frac_Z_shift;
    bit [26:0] frac_Z_norm;
    bit [7:0] exp_Z, exp_X, exp_Y;
    bit sign_Z, sign_X, sign_Y;
    bit round;
    bit guard;
    bit sticky;
    bit [23:0]Z;
    bit [23:0]Z_plus;
    bit [22:0]frac_Z_final;
    bit [7:0]exp_Z_final;

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
  frac_Z_full=mantissa_X*mantissa_Y;

  //se calcula el exponente Z
  exp_Z=exp_X+exp_Y-127;

  sign_Z = sign_X ^ sign_Y; //Signo de Z

  /*
  $display("mantissa X: %0h, mantissa Y: %0h, mantissa Z: %0h", mantissa_X, mantissa_Y, frac_Z_full);
  $display("exp X: %0h, exp Y: %0h, exp Z: %0h", exp_X, exp_Y, exp_Z);
  $display("X: %0h, Y: %0h, Z: %0h", {sign_X, exp_X, mantissa_X}, {sign_Y, exp_Y, mantissa_Y}, {sign_Z, exp_Z, frac_Z_full} );
  $display("---------------------------------------------------------------------------------------------------------");
*/
  //se normaliza de ser necesario
  if (!frac_Z_full[47])  begin
    frac_Z_shift = frac_Z_full << 1; //se hace un shift a la izquierda
  end
  else frac_Z_shift = frac_Z_full;
  frac_Z_norm[26:1]=frac_Z_shift[47:22];//en el numero Z se conservan solo los bits necesarios para redondear
  frac_Z_norm[0] = |frac_Z_shift[21:0]; // sticky bit
  norm_n = frac_Z_full[47];

  exp_Z_final = exp_Z + norm_n;


  //se toman
  round=frac_Z_norm[2];
  guard=frac_Z_norm[1];
  sticky=frac_Z_norm[0];
  Z = [26:3]frac_Z_norm;  //24 bits mas significativos de la mantisa
  Z_plus=Z+1; // Z + 1

  case(item.r_mode)
    3'b000:begin
      if (!round) begin
        frac_Z_final = Z[22:0];
      end
      else if (round & (guard | sticky) == 1) begin
        frac_Z_final = Z_plus[22:0];
      end
      else if (round & (guard | sticky) == 0) begin
        if (!Z[0]) begin
          frac_Z_final = Z[22:0];
        end
        else begin
          frac_Z_final = Z_plus[22:0];
        end
      end

    end

    3'b001:begin
      frac_Z_final = Z[22:0];
    end    

    3'b010:begin
      frac_Z_final = sign_Z ? Z_plus[22:0] : Z[22:0]; 
    end

    3'b011:begin
      frac_Z_final = sign_Z ? Z[22:0] : Z_plus[22:0];
    end

    3'b100:begin
      frac_Z_final = round ? Z_plus[22:0] : Z[22:0];
    end
  endcase


  endfunction
    
endclass