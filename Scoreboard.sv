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
    bit [22:0]Z;
    bit [22:0]Z_plus;
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
    int fcsv;
  


    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        
      	super.build_phase(phase);
      
        m_analysis_imp = new("m_analysis_imp",this);

        fcsv = $fopen("./resultados.csv", "w");
        $fwrite(fcsv, "X, Y, Z, Underflow, Overflow, Expected Z, Expected Underflow, Expected Overflow \n");

    endfunction

  virtual function write(Item item);
  //referencia para comprobar funcionamiento de DUT

  //se toma el numero X
  frac_X=item.fp_X[22:0];
  exp_X=item.fp_X[30:23];
  sign_X=item.fp_X[31];

  

  //se toma el numero Y
  frac_Y=item.fp_Y[22:0];
  exp_Y=item.fp_Y[30:23];
  sign_Y=item.fp_Y[31];

  //se multiplican las mantissas de X y Y
  frac_Z_full={1'b1,frac_X}*{1'b1,frac_Y};

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
  Z = frac_Z_norm[25:3];  //24 bits mas significativos de la mantisa
  Z_plus=Z+1'b1; // Z + 1

  case(item.r_mode)// se evaluan los distintos casos para redondeo tulizando la logica que se explica en el documento
    3'b000:begin
      if (!round) begin
        frac_Z_final = Z;
      end
      else if (round & (guard | sticky) == 1) begin
        frac_Z_final = Z_plus;
      end
      else if (round & (guard | sticky) == 0) begin
        if (!Z[0]) begin
          frac_Z_final = Z;
        end
        else begin
          frac_Z_final = Z_plus;
        end
      end

    end

    3'b001:begin
      frac_Z_final = Z;
    end    

    3'b010:begin
      frac_Z_final = sign_Z ? Z_plus : Z; 
    end

    3'b011:begin
      frac_Z_final = sign_Z ? Z : Z_plus;
    end

    3'b100:begin
      frac_Z_final = round ? Z_plus : Z;
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


  //Exception Handler, esta logica para manejo de excepciones se obtuvo en base al codigo del DUT

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
  

  fp_Z_expected= nan ? 32'h7fc00000 : (inf ? {sign_Z, 8'hff, 23'b0} : (zer ? {sign_Z, 8'h00, 23'b0} : {sign_Z, exp_Z_final, frac_Z_final}));// se evalua de cual caso se trata, nan, zero, infinito o un numero valido
                                                                                                                                            //se obtiene el valor esperado final en base a esto
$display("-----------------------------------------------------------------------------");
`uvm_info("SCBD", $sformatf("Mode=%0h Op_x=%0h Op_y=%0h DUT_OUT=%h Expected=%0h Overflow=%0h Underflow=%0h", item.r_mode,item.fp_X,item.fp_Y,item.fp_Z,fp_Z_expected,item.ovrf,item.udrf), UVM_LOW)

$fwrite(fcsv, "%0h, %0h, %0h, %0b, %0b, %0h, %0b, %0b \n", item.fp_X, item.fp_Y, item.fp_Z, item.udrf, item.ovrf, fp_Z_expected, udrf, ovrf);

        if(item.fp_Z !=fp_Z_expected ) begin
            `uvm_error("SCBD",$sformatf("TEST FAILED!!!! DUT_OUT=%0h Expected=%0h", item.fp_Z,fp_Z_expected))
        end else begin
            `uvm_info("SCBD",$sformatf("TEST PASS! DUT_OUT=%0h Expected=%0h",item.fp_Z,fp_Z_expected), UVM_HIGH)
        end

        
  endfunction
    
endclass