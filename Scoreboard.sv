class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
    
    function new(string name="scoreboard",uvm_component parent=null);
        super.new(name, parent);
    endfunction

    bit [22:0] frac_X, frac_Y;
    bit [47:0] frac_Z_full;
    bit [47:0] frac_Z_shift;
    bit [26:0] frac_Z_norm;
    bit [7:0] exp_Z, exp_X, exp_Y;
    bit sign_Z, sign_X, sign_Y;
    bit norm_n;
    bit round;
    bit guard;
    bit sticky;
    bit [23:0]Z;
    bit [23:0]Z_plus;
    bit [22:0]frac_Z_final;
    bit [7:0]exp_Z_final;
    real exp_flag;
    bit udrf, ovrf;
    real bias;
    bit nan_X, nan_Y, nan_Z, nan;
    bit inf_X, inf_Y, inf;
    bit zer_X, zer_Y, zer;
    bit [31:0]fp_Z_expected;//Valor para comparar con DUT
    bit except;
  


    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        
      	super.build_phase(phase);
      
        m_analysis_imp = new("m_analysis_imp",this);

    endfunction

  virtual function write(Item item);
  //referencia para comprobar funcionamiento de DUT

  //se toma el numero X
  frac_X={1'b1,item.fp_X[22:0]};
  exp_X=item.fp_X[30:23];
  sign_X=item.fp_X[31];

  

  //se toma el numero Y
  frac_Y={1'b1, item.fp_Y[22:0]};
  exp_Y=item.fp_Y[30:23];
  sign_Y=item.fp_Y[31];

  //se multiplican las mantissas de X y Y
  frac_Z_full=frac_X*frac_Y;

  //se calcula el exponente Z
  exp_Z=exp_X+exp_Y-127;

  exp_flag = $itor(exp_X)+$itor(exp_Y);

  sign_Z = sign_X ^ sign_Y; //Signo de Z


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
  Z = frac_Z_norm[26:3];  //24 bits mas significativos de la mantisa
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


  //Logica para Overflow y Underflow
  if (norm_n) begin
    udrf = exp_flag<=126 ? 1 : 0;
    ovrf = exp_flag>=255+126 ? 1 : 0;
  end
  else if (!norm_n) begin
    udrf = exp_flag<=127 ? 1 : 0;
    ovrf = exp_flag>=255+127 ? 1 : 0;
  end


  //Exception Handler

  inf_X = &exp_X & ~|frac_X;
  inf_Y = &exp_Y & ~|frac_Y;
  inf = inf_X | inf_Y | ovrf;
  
  zer_X = ~|exp_X;
  zer_Y = ~|exp_Y;
  zer = zer_X | zer_Y | udrf;
  
  nan_X = &exp_X & |frac_X;
  nan_Y = &exp_Y & |frac_Y;
  nan_Z = {&exp_X & zer_Y} | {&exp_Y & zer_X};
  nan = nan_X | nan_Y | nan_Z;
  

  fp_Z_expected= nan ? 32'h7fc00000 : (inf ? {sign_Z, 8'hff, 23'b0} : (zer ? {sign_Z, 8'h00, 23'b0} : {sign_Z, exp_Z_final, frac_Z_final}));


  `uvm_info("SCBD", $sformatf("Mode = %b X = %h Y = %h, DUT = %h Expected = %h", item.r_mode,item.fp_X,item.fp_Y,item.fp_Z,fp_Z_expected), UVM_LOW)  
  `uvm_info("SCBD", $sformatf("Overflow DUT = %b Underflow DUT = %b  Overflow Expected = %b Underflow Expected = %b", item.ovrf,item.udrf,inf,zer), UVM_LOW)      
  `uvm_info("SCBD", $sformatf("------------------------------------------------------------------------------------"), UVM_LOW)    

  endfunction
    
endclass