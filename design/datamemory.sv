`timescale 1ns / 1ps

module datamemory #(
    parameter DM_ADDRESS = 9,
    parameter DATA_W = 32
) (
    input logic clk,
    input logic MemRead,  // comes from control unit
    input logic MemWrite,  // Comes from control unit
    input logic [DM_ADDRESS - 1:0] a,  // Read / Write address - 9 LSB bits of the ALU output
    input logic [DATA_W - 1:0] wd,  // Write Data
    input logic [2:0] Funct3,  // bits 12 to 14 of the instruction
    output logic [DATA_W - 1:0] rd  // Read Data
);

  logic [31:0] raddress;
  logic [31:0] waddress;
  logic [31:0] Datain;
  logic [31:0] Dataout;
  logic [ 3:0] Wr;

  Memoria32Data mem32 (
      .raddress(raddress),
      .waddress(waddress),
      .Clk(~clk),
      .Datain(Datain),
      .Dataout(Dataout),
      .Wr(Wr)
  );

  always_ff @(*) begin
    raddress = {{22{1'b0}}, a};
    waddress = {{22{1'b0}}, {a[8:2], {2{1'b0}}}};
    Datain = wd;
    Wr = 4'b0000;

    if (MemRead) begin
      case (Funct3)
        3'b001: begin //LH
          case(a[1:0])// Checa o alinhamento de meia palavra
            2'b00: rd <= {{16{Dataout[15]}}, Dataout[15:0]}; // Endereço Par: lê Dataout[15:0] e estende o bit 15
            2'b10: rd <= {{16{Dataout[31]}}, Dataout[31:16]}; // Endereço Par+2: lê Dataout[31:16] e estende o bit 31
            default: rd <= 32'hxxxx;  // Sinaliza desalinhamento (ou exceção)
          endcase
        end
        rd <= Dataout;
        3'b010: rd <= Dataout; //LW
        3'b000: begin          //LB (SIGNED)
          case(a[1:0])                                          // Checks which specific address is required to be outputed, because the addresses (and therefore, the read addresses) are organized into words (4 bytes)
            2'b00: rd <= {{24{Dataout[7]}}, Dataout[7:0]};      // Number divisible by 4
            2'b01: rd <= {{24{Dataout[15]}}, Dataout[15:8]};    // Offset of 1 from a number divisible by 4
            2'b10: rd <= {{24{Dataout[23]}}, Dataout[23:16]};   // Offset of 2 from a number divisible by 4
            2'b11: rd <= {{24{Dataout[31]}}, Dataout[31:24]};   // Offset of 3 from a number divisible by 4
          endcase
        end
        3'b100: begin         //LBU (UNSIGNED)
          case(a[1:0])                                          // Logic similar to LB
            2'b00: rd <= {{24{1'b0}}, Dataout[7:0]};
            2'b01: rd <= {{24{1'b0}}, Dataout[15:8]};
            2'b10: rd <= {{24{1'b0}}, Dataout[23:16]};
            2'b11: rd <= {{24{1'b0}}, Dataout[31:24]};
          endcase
        end
        default: rd <= Dataout;
      endcase
    end else if (MemWrite) begin
      case (Funct3)
        3'b010: begin  //SW
          Wr <= 4'b1111;
          Datain <= wd;
        end
        3'b001: begin  //SH
          case(a[1])
            1'b0: begin
              Wr <= 4'b0011;
              Datain <= {16'b0, wd[15:0]};
            end
            1'b1: begin
              Wr <= 4'b1100;
              Datain <= {wd[15:0], 16'b0};
            end 
          endcase
        end
        3'b000: begin //SB
          case(a[1:0])
            2'b00: begin
              Wr <= 4'b0001;
              Datain <= {24'b0, wd[7:0]};
            end
            2'b01: begin
              Wr <= 4'b0010;
              Datain <= {16'b0, wd[7:0], 8'b0};
            end
            2'b10: begin
              Wr <= 4'b0100;
              Datain <= {8'b0, wd[7:0], 16'b0};
            end
            2'b11: begin
              Wr <= 4'b1000;
              Datain <= {wd[7:0], 24'b0};
            end 
          endcase
        end
        default: begin
          Wr <= 4'b1111;
          Datain <= wd;
        end
      endcase
    end
  end

endmodule

