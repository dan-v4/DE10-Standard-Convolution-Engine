module sccb_rom (
    input clock,
    input [7:0] address,
    //output reg [7:0] register,
    output reg [15:0] register
);

    always @ (posedge clock) begin
        case (address)
            8'd0:  register <= 16'h12_80;  // Reset all register to default values
            8'd1:  register <= 16'h12_04;  // Set output format to RGB
            8'd2:  register <= 16'h11_80;  // PCLK will not toggle during horizontal blank
            8'd3:  register <= 16'h0C_00;  // RGB565
            8'd4:  register <= 16'h41_18;  // COM7, set RGB color output
            8'd5:  register <= 16'h11_80;  // CLKRC internal PLL matches input clock
            8'd6:  register <= 16'h0C_00;  // COM3, default settings
            8'd7:  register <= 16'h3E_00;  // COM14, no scaling, normal pclock
            8'd8:  register <= 16'h04_00;  // COM1, disable CCIR656
            8'd9:  register <= 16'h40_d0;  // COM15, RGB565, full output range
            8'd10: register <= 16'h3a_04;  // TSLB set correct output data sequence (magic)
            8'd11: register <= 16'h14_4a;  // COM9 MAX AGC value x4 0001_1000
            8'd12: register <= 16'h4F_B3;  // MTX1 magical matrix coefficients
            8'd13: register <= 16'h50_B3;  // MTX2
            8'd14: register <= 16'h51_00;  // MTX3
            8'd15: register <= 16'h52_3d;  // MTX4
            8'd16: register <= 16'h53_A7;  // MTX5
            8'd17: register <= 16'h54_E4;  // MTX6
            8'd18: register <= 16'h58_9E;  // MTXS
            8'd19: register <= 16'h3D_C0;  // COM13 sets gamma enable, might be wrong?
            8'd20: register <= 16'h17_14;  // HSTART start high 8 bits
            8'd21: register <= 16'h18_02;  // HSTOP stop high 8 bits
            8'd22: register <= 16'h32_80;  // HREF edge offset
            8'd23: register <= 16'h19_03;  // VSTART start high 8 bits
            8'd24: register <= 16'h1A_7B;  // VSTOP stop high 8 bits
            8'd25: register <= 16'h03_0A;  // VREF vsync edge offset
            8'd26: register <= 16'h0F_41;  // COM6 reset timings
            8'd27: register <= 16'h1E_00;  // MVFP disable mirror / flip
            8'd28: register <= 16'h33_0B;  // CHLF magic value from the internet
            8'd29: register <= 16'h3C_78;  // COM12 no HREF when VSYNC low
            8'd30: register <= 16'h69_00;  // GFix fix gain control
            8'd31: register <= 16'h74_00;  // REG74 Digital gain control
            8'd32: register <= 16'hB0_84;  // RSVD required magic value for good color
            8'd33: register <= 16'hB1_0C;  // ABLC1
            8'd34: register <= 16'hB2_0E;  // RSVD more magic internet values
            8'd35: register <= 16'hB3_80;  // THL_ST
				8'd36: register <= 16'h70_3A;  // mystery scaling
            8'd37: register <= 16'h71_35;  // mystery scaling
            8'd38: register <= 16'h72_11;  // mystery scaling
            8'd39: register <= 16'h73_F0;  // mystery scaling
            8'd40: register <= 16'hA2_02;  // mystery scaling
            8'd41: register <= 16'h7A_20;  // gamma curve
            8'd42: register <= 16'h7B_10;  // gamma curve
            8'd43: register <= 16'h7C_1E;  // gamma curve
            8'd44: register <= 16'h7D_35;  // gamma curve
            8'd45: register <= 16'h7e_5a;  // gamma curve
            8'd46: register <= 16'h7f_69;  // gamma curve
            8'd47: register <= 16'h80_76;  // gamma curve
            8'd48: register <= 16'h81_80;  // gamma curve
            8'd49: register <= 16'h82_88;  // gamma curve
            8'd50: register <= 16'h81_80;  // gamma curve
            8'd51: register <= 16'h82_88;  // gamma curve
            8'd52: register <= 16'h83_8f;  // gamma curve
            8'd53: register <= 16'h84_96;  // gamma curve
            8'd54: register <= 16'h85_a3;  // gamma curve
            8'd55: register <= 16'h86_af;  // gamma curve
            8'd56: register <= 16'h87_c4;  // gamma curve
            8'd57: register <= 16'h88_d7;  // COM8 disable AGC/AEC
            8'd58: register <= 16'h89_e8;  // set gain reg to 0 for AGC
            8'd59: register <= 16'h13_e0;  // set ARCJ reg to 0
            8'd60: register <= 16'h00_00;  // magic reserved bit for COM4
            8'd61: register <= 16'h10_00;  // COM9, 4x gain + magic bit
            8'd62: register <= 16'h0d_40;  // BD50MAX
            8'd63: register <= 16'h14_18;  // DB60MAX
            8'd64: register <= 16'ha5_05;  // AGC upper limit
            8'd65: register <= 16'hab_07;  // AGC lower limit
            8'd66: register <= 16'h24_95;  // AGC/AEC fast mode op region
            8'd67: register <= 16'h25_33;  // HAECC1
            8'd68: register <= 16'h26_e3;  // HAECC2
            8'd69: register <= 16'h9f_78;  // magic
            8'd70: register <= 16'ha0_68;  // HAECC3
            8'd71: register <= 16'ha1_03;  // HAECC4
            8'd72: register <= 16'ha6_d8;  // HAECC5
            8'd73: register <= 16'ha7_d8;  // HAECC6
            8'd74: register <= 16'ha8_f0;  // HAECC7
				8'd75: register <= 16'ha9_90;  // HAECC7
				8'd76: register <= 16'haa_94;  // HAECC7
				8'd77: register <= 16'h13_a7;  // HAECC7
				8'd78: register <= 16'h69_0F;  // HAECC7 h69_06
            default: register <= 16'h00_00;
        endcase
    end
endmodule