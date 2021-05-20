library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG_COMMON.all;

entity decode is
port(CLK, RST: in std_logic;
	I_PC1, I_PC2 : in std_logic_vector(31 downto 0);
	I_I1_HIST_IND, I_I2_HIST_IND: in std_logic_vector(N_Br_TAG - 1 downto 0);
	INSTR1, INSTR2 : in std_logic_vector(31 downto 0);
	I_pred_bit1, I_pred_bit2 : in std_logic;
	I_Branch_Valid : in std_logic;
	I_Branch_Result : in std_logic;
	I_Branch_tag : in std_logic_vector(N_Br_TAG-1 downto 0);
	O_PC1, O_PC2 : out std_logic_vector(31 downto 0);
	O_OPCODE1, O_OPCODE2 : out std_logic_vector(N_OPCODE_BITS-1 downto 0);
	O_FUNC1, O_FUNC2 : out std_logic_vector(N_FUNC_BITS-1 downto 0);
	O_SHAMT1, O_SHAMT2 : out std_logic_vector(N_SHAMT_BITS-1 downto 0);
	O_I1_REG1, O_I1_REG2 : out std_logic_vector(N_LOG_AR-1 downto 0 );
	O_I2_REG1, O_I2_REG2 : out std_logic_vector(N_LOG_AR-1 downto 0 );
	O_I1_DEST, O_I2_DEST : out std_logic_vector(N_LOG_AR-1 downto 0 );
	O_I1_Valid, O_I2_Valid : out std_logic;
	O_CTRL1, O_CTRL2 : out std_logic_vector(N_CTRL_BITS-1 downto 0);
	-- CTRL : ALU_instr FP_instr Mem_instr Br_instr R_type Imm_type RegWrite RegDst RegInSrc ALUSrc Add_sub Logic_ctrl alu_outp_control shift_control Fp_mul/add DataRead DataWrite BrType PCSrc 
	--  27      1          1        1         1        1       1       1       2       2        1       1        2            3              2            1         1         1        2     2    
	speculative_bit1, speculative_bit2 : out std_logic;
	O_pred_bit1, O_pred_bit2 : out std_logic;
	branch_tag1, branch_tag2: out std_logic_vector(N_Br_TAG-1 downto 0);
	O_IMM1, O_IMM2: out std_logic_vector(31 downto 0);
	O_I1_HIST_IND, O_I2_HIST_IND : out std_logic_vector(N_Br_TAG - 1 downto 0);
	O_I1_DEC_FETCH_HIST_IND, O_I2_DEC_FETCH_HIST_IND: out std_logic_vector(N_Br_TAG - 1 downto 0);
	O_FETCH_DEC_pred_bit1, O_FETCH_DEC_pred_bit2: out std_logic;
	jump_valid1, jump_valid2 : out std_logic;
	jump_addr1, jump_addr2 : out std_logic_vector(31 downto 0));
	
end entity;

architecture behav of decode is
	signal COMB_OPCODE1, COMB_OPCODE2 : std_logic_vector(N_OPCODE_BITS-1 downto 0);
	begin
	COMB_OPCODE1 <= INSTR1(31 downto 26);
	COMB_OPCODE2 <= INSTR2(31 downto 26);
	O_I1_DEC_FETCH_HIST_IND <= I_I1_HIST_IND when rst = '0' else (others => '0');
	O_I2_DEC_FETCH_HIST_IND <= I_I2_HIST_IND when rst = '0' else (others => '0');
	O_FETCH_DEC_pred_bit1 <= I_pred_bit1 when rst = '0' else '0';
	O_FETCH_DEC_pred_bit2 <= I_pred_bit2 when rst = '0' else '0';	
	jump_valid1 <= '1' when COMB_OPCODE1 = "000010" else
					'1' when COMB_OPCODE1 = "000011" else
					'0';
					
	jump_valid2 <= '1' when COMB_OPCODE2 = "000010" else
					'1' when COMB_OPCODE2 = "000011" else
					'0';
					
	jump_addr1(31 downto 28) <= I_PC1(31 downto 28) when rst = '0' else (others => '0');
	jump_addr1(27 downto 2) <= INSTR1(25 downto 0) when rst = '0' else (others => '0');
	jump_addr1(1 downto 0) <= "00" when rst = '0' else (others => '0');
	
	jump_addr2(31 downto 28) <= I_PC2(31 downto 28) when rst = '0' else (others => '0');
	jump_addr2(27 downto 2) <= INSTR2(25 downto 0) when rst = '0' else (others => '0');
	jump_addr2(1 downto 0) <= "00" when rst = '0' else (others => '0');
	
	
	process(CLK, rst)
		variable sbit : std_logic := '0';
		variable btag : std_logic_vector(N_Br_TAG-1 downto 0) := (others => '0');
		variable Imm1, Imm2 : std_logic_vector(31 downto 0);
		variable CTRL1, CTRL2: std_logic_vector(N_CTRL_BITS-1 downto 0);
		variable dest1: std_logic_vector(N_LOG_AR-1 downto 0);
		variable dest2: std_logic_vector(N_LOG_AR-1 downto 0);
		variable valid1, valid2:  std_logic;
		variable FUNC1, FUNC2, OPCODE1, OPCODE2: std_logic_vector(5 downto 0);
	begin
	
	if(rst = '1') then
		O_I1_DEST <= (others => '0');
		O_I2_DEST <= (others => '0');
		O_I1_Valid <= '0';
		O_I2_Valid <= '0';
		O_CTRL1 <= (others => '0');
		O_CTRL2 <= (others => '0');
		speculative_bit1 <= '0';
		speculative_bit2 <= '0';
		branch_tag1 <= (others => '0');
		branch_tag2 <= (others => '0');
		O_IMM1 <= (others => '0');
		O_IMM2 <= (others => '0');
		O_I1_REG1 <= (others => '0');
		O_I2_REG1 <= (others => '0');
		O_I1_REG2 <= (others => '0');
		O_I2_REG2 <= (others => '0');
		O_OPCODE1 <= (others => '0');
		O_OPCODE2 <= (others => '0');
		O_FUNC1 <= (others => '0');
		O_FUNC2 <= (others => '0');
		O_PC1 <= (others => '0');
		O_PC2 <= (others => '0');
		O_I1_HIST_IND <= (others => '0');
		O_I2_HIST_IND <= (others => '0');
		O_pred_bit1 <= '0';
		O_pred_bit2 <= '0';
		
	elsif rising_edge(CLK) then
		dest1 := INSTR1(15 downto 11);
		dest2 := INSTR2(15 downto 11);
		OPCODE1 := INSTR1(31 downto 26);
		OPCODE2 := INSTR2(31 downto 26);
		FUNC1 := INSTR1(5 downto 0);
		FUNC2 := INSTR2(5 downto 0);
		Imm1 := std_logic_vector(to_unsigned(0, 32));
		Imm2 := std_logic_vector(to_unsigned(0, 32));
		valid1 := '1';
		valid2 := '1';

		
		if (I_Branch_Valid = '1') then
			case I_Branch_Result is
			when '1' => btag := std_logic_vector(unsigned(btag) - to_unsigned(1,N_Br_TAG));
			when '0' => btag := std_logic_vector(unsigned(I_Branch_tag) - to_unsigned(1,N_Br_TAG));
						valid1 := '0';
						valid2 := '0';
			when others => NULL;
			end case;
			if (btag = "0000") then
				sbit := '0';
			end if;
		end if;
		
		case OPCODE1 is 
		when "000000" =>  case FUNC1 is --R type Instructions
						  when "100000" => CTRL1 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"010"&"00"&'0'&'0'&'0'&"00"&"00"; -- Add
						  when "100010" => CTRL1 := "1000"&"10"&'1'&"01"&"01"&'0'&'1'&"00"&"010"&"00"&'0'&'0'&'0'&"00"&"00"; -- Subtract
						  when "101010" => CTRL1 := "1000"&"10"&'1'&"01"&"01"&'0'&'1'&"00"&"001"&"00"&'0'&'0'&'0'&"00"&"00"; -- Set Less than
						  when "110000" => CTRL1 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"100"&"00"&'0'&'0'&'0'&"00"&"00"; --Mult
						  when "110001" => CTRL1 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"101"&"00"&'0'&'0'&'0'&"00"&"00"; --Div
						  
						  when "100100" => CTRL1 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"011"&"00"&'0'&'0'&'0'&"00"&"00"; -- And
						  when "100101" => CTRL1 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"01"&"011"&"00"&'0'&'0'&'0'&"00"&"00"; -- Or
						  when "100110" => CTRL1 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"10"&"011"&"00"&'0'&'0'&'0'&"00"&"00"; -- Xor
						  
						  when "001000" => CTRL1 := "0001"&"10"&'0'&"00"&"00"&'0'&'0'&"00"&"000"&"00"&'0'&'0'&'0'&"00"&"10"; -- jr
						  sbit := '1'; btag := std_logic_vector(unsigned(btag) + to_unsigned(1,N_Br_TAG));
						  
						  when "000010" => CTRL1 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"000"&"11"&'0'&'0'&'0'&"00"&"00"; -- srl
						  when "000011" => CTRL1 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"000"&"01"&'0'&'0'&'0'&"00"&"00"; -- sra
						  when "000000" => CTRL1 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"000"&"10"&'0'&'0'&'0'&"00"&"00"; -- sll
						  when others   => CTRL1 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"010"&"00"&'0'&'0'&'0'&"00"&"00"; -- Default Add
										   valid1 := '0';
						  end case;
		
		when "001000" => CTRL1 := "1000"&"01"&'1'&"00"&"01"&'1'&'0'&"00"&"010"&"00"&'0'&'0'&'0'&"00"&"00"; -- Addi
						 Imm1 := std_logic_vector(resize(signed(INSTR1(15 downto 0)), 32));              --Sign extension
						 dest1 := INSTR1(20 downto 16);
		when "001010" => CTRL1 := "1000"&"01"&'1'&"00"&"01"&'1'&'1'&"00"&"001"&"00"&'0'&'0'&'0'&"00"&"00"; -- slti
						 Imm1 := std_logic_vector(resize(signed(INSTR1(15 downto 0)), 32));
						 dest1 := INSTR1(20 downto 16);
						 
		when "001100" => CTRL1 := "1000"&"01"&'1'&"00"&"01"&'1'&'0'&"00"&"011"&"00"&'0'&'0'&'0'&"00"&"00"; -- Andi
						 Imm1 := std_logic_vector(resize(unsigned(INSTR1(15 downto 0)), 32));            -- Zero extension
						 dest1 := INSTR1(20 downto 16);
		when "001101" => CTRL1 := "1000"&"01"&'1'&"00"&"01"&'1'&'0'&"01"&"011"&"00"&'0'&'0'&'0'&"00"&"00"; -- Ori
						 Imm1 := std_logic_vector(resize(unsigned(INSTR1(15 downto 0)), 32));
						  dest1 := INSTR1(20 downto 16);
		when "001110" => CTRL1 := "1000"&"01"&'1'&"00"&"01"&'1'&'0'&"10"&"011"&"00"&'0'&'0'&'0'&"00"&"00"; -- Xori
						 Imm1 := std_logic_vector(resize(unsigned(INSTR1(15 downto 0)), 32));
						  dest1 := INSTR1(20 downto 16);
		
		when "100011" => CTRL1 := "0010"&"10"&'1'&"00"&"00"&'1'&'0'&"00"&"010"&"00"&'0'&'1'&'0'&"00"&"00"; -- Load word
						 dest1 := INSTR1(20 downto 16);
						 Imm1 := std_logic_vector(resize(unsigned(INSTR1(15 downto 0)), 32));
		when "101011" => CTRL1 := "0010"&"10"&'0'&"00"&"00"&'1'&'0'&"00"&"010"&"00"&'0'&'0'&'1'&"00"&"00"; -- Store word
						dest1 := INSTR1(20 downto 16);
						 Imm1 := std_logic_vector(resize(unsigned(INSTR1(15 downto 0)), 32));

		when "000010" => CTRL1 := "0001"&"01"&'0'&"00"&"00"&'0'&'0'&"00"&"000"&"00"&'0'&'0'&'0'&"00"&"01"; -- Jump
						 valid1 := '0';
						if I_pred_bit1 = '0' then
							valid2 := '0';
						end if;
		when "000001" => CTRL1 := "0001"&"10"&'0'&"00"&"00"&'1'&'0'&"00"&"000"&"00"&'0'&'0'&'0'&"11"&"00"; -- bltz
						sbit := '1'; btag := std_logic_vector(unsigned(btag) + to_unsigned(1,N_Br_TAG));
						Imm1 := std_logic_vector(resize(signed(INSTR1(15 downto 0)), 32));
		when "000100" => CTRL1 := "0001"&"10"&'0'&"00"&"00"&'1'&'0'&"00"&"000"&"00"&'0'&'0'&'0'&"01"&"00"; -- beq
						sbit := '1'; btag := std_logic_vector(unsigned(btag) + to_unsigned(1,N_Br_TAG));
						Imm1 := std_logic_vector(resize(signed(INSTR1(15 downto 0)), 32));
		when "000011" => CTRL1 := "0001"&"10"&'1'&"10"&"10"&'0'&'0'&"00"&"000"&"00"&'0'&'0'&'0'&"00"&"01"; -- jal
						dest1 := "11111";
						if I_pred_bit1 = '0' then
							valid2 := '0';
						end if;
		
		
		when "000110" => CTRL1 := "0100"&"10"&'1'&"01"&"11"&'0'&'0'&"00"&"000"&"00"&'0'&'0'&'0'&"00"&"00"; --FP add
		when "000111" => CTRL1 := "0100"&"10"&'1'&"01"&"11"&'0'&'0'&"00"&"000"&"00"&'1'&'0'&'0'&"00"&"00"; --FP mul

		
		when others => 	CTRL1 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"010"&"00"&'0'&'0'&'0'&"00"&"00"; -- Default Add
						valid1 := '0';
		end case;
		
		if(INSTR2 = X"00000000") then
			valid1 := '0';
		end if;
		O_IMM1 <= Imm1;
		O_CTRL1 <= CTRL1;
		speculative_bit1 <= sbit;
		branch_tag1 <= btag;
		O_I1_DEST <= dest1;
		O_I1_Valid <= valid1;

		
		
		
		case OPCODE2 is
		when "000000" =>  case FUNC2 is --R type Instructions
						  when "100000" => CTRL2 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"010"&"00"&'0'&'0'&'0'&"00"&"00"; -- Add
						  when "100010" => CTRL2 := "1000"&"10"&'1'&"01"&"01"&'0'&'1'&"00"&"010"&"00"&'0'&'0'&'0'&"00"&"00"; -- Subtract
						  when "101010" => CTRL2 := "1000"&"10"&'1'&"01"&"01"&'0'&'1'&"00"&"001"&"00"&'0'&'0'&'0'&"00"&"00"; -- Set Less than
						  when "110000" => CTRL2 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"100"&"00"&'0'&'0'&'0'&"00"&"00"; --Mult
						  when "110001" => CTRL2 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"101"&"00"&'0'&'0'&'0'&"00"&"00"; --Div
						  
						  when "100100" => CTRL2 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"011"&"00"&'0'&'0'&'0'&"00"&"00"; -- And
						  when "100101" => CTRL2 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"01"&"011"&"00"&'0'&'0'&'0'&"00"&"00"; -- Or
						  when "100110" => CTRL2 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"10"&"011"&"00"&'0'&'0'&'0'&"00"&"00"; -- Xor
						  
						  when "001000" => CTRL2 := "0001"&"10"&'0'&"00"&"00"&'0'&'0'&"00"&"000"&"00"&'0'&'0'&'0'&"00"&"10"; -- jr
						  sbit := '1'; btag := std_logic_vector(unsigned(btag) + to_unsigned(1,N_Br_TAG));
						  
						  when "000010" => CTRL2 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"000"&"11"&'0'&'0'&'0'&"00"&"00"; -- srl
						  when "000011" => CTRL2 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"000"&"01"&'0'&'0'&'0'&"00"&"00"; -- sra
						  when "000000" => CTRL2 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"000"&"10"&'0'&'0'&'0'&"00"&"00"; -- sll
						  when others   => CTRL2 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"010"&"00"&'0'&'0'&'0'&"00"&"00"; -- Default Add
										   valid2 := '0';
						  end case;
		
		when "001000" => CTRL2 := "1000"&"01"&'1'&"00"&"01"&'1'&'0'&"00"&"010"&"00"&'0'&'0'&'0'&"00"&"00"; -- Addi
						 Imm2 := std_logic_vector(resize(signed(INSTR2(15 downto 0)), 32));              --Sign extension
						  dest2 := INSTR2(20 downto 16);
		when "001010" => CTRL2 := "1000"&"01"&'1'&"00"&"01"&'1'&'1'&"00"&"001"&"00"&'0'&'0'&'0'&"00"&"00"; -- slti
						 Imm2 := std_logic_vector(resize(signed(INSTR2(15 downto 0)), 32));
						 dest2 := INSTR2(20 downto 16);
						 
		when "001100" => CTRL2 := "1000"&"01"&'1'&"00"&"01"&'1'&'0'&"00"&"011"&"00"&'0'&'0'&'0'&"00"&"00"; -- Andi
						 Imm2 := std_logic_vector(resize(unsigned(INSTR2(15 downto 0)), 32));            -- Zero extension
						 dest2 := INSTR2(20 downto 16);
		when "001101" => CTRL2 := "1000"&"01"&'1'&"00"&"01"&'1'&'0'&"01"&"011"&"00"&'0'&'0'&'0'&"00"&"00"; -- Ori
						 Imm2 := std_logic_vector(resize(unsigned(INSTR2(15 downto 0)), 32));
						 dest2 := INSTR2(20 downto 16);
		when "001110" => CTRL2 := "1000"&"01"&'1'&"00"&"01"&'1'&'0'&"10"&"011"&"00"&'0'&'0'&'0'&"00"&"00"; -- Xori
						 Imm2 := std_logic_vector(resize(unsigned(INSTR2(15 downto 0)), 32));
						 dest2 := INSTR2(20 downto 16);
		
		when "100011" => CTRL2 := "0010"&"10"&'1'&"00"&"00"&'1'&'0'&"00"&"010"&"00"&'0'&'1'&'0'&"00"&"00"; -- Load word
						 dest2 := INSTR2(20 downto 16);
						 Imm2 := std_logic_vector(resize(unsigned(INSTR2(15 downto 0)), 32));
		when "101011" => CTRL2 := "0010"&"10"&'0'&"00"&"00"&'1'&'0'&"00"&"010"&"00"&'0'&'0'&'1'&"00"&"00"; -- Store word
						 dest2 := INSTR2(20 downto 16);
						 Imm2 := std_logic_vector(resize(unsigned(INSTR2(15 downto 0)), 32));
		
		when "000010" => CTRL2 := "0001"&"01"&'0'&"00"&"00"&'0'&'0'&"00"&"000"&"00"&'0'&'0'&'0'&"00"&"01"; -- Jump
						 valid2 := '0';
		when "000001" => CTRL2 := "0001"&"10"&'0'&"00"&"00"&'1'&'0'&"00"&"000"&"00"&'0'&'0'&'0'&"11"&"00"; -- bltz
						sbit := '1'; btag := std_logic_vector(unsigned(btag) + to_unsigned(1,N_Br_TAG));
						Imm2 := std_logic_vector(resize(signed(INSTR2(15 downto 0)), 32));
		when "000100" => CTRL2 := "0001"&"10"&'0'&"00"&"00"&'1'&'0'&"00"&"000"&"00"&'0'&'0'&'0'&"01"&"00"; -- beq
						sbit := '1'; btag := std_logic_vector(unsigned(btag) + to_unsigned(1,N_Br_TAG));
						Imm2 := std_logic_vector(resize(signed(INSTR2(15 downto 0)), 32));
		when "000011" => CTRL2 := "0001"&"10"&'1'&"10"&"10"&'0'&'0'&"00"&"000"&"00"&'0'&'0'&'0'&"00"&"01"; -- jal
						dest2 := "11111";	
		
		when "000110" => CTRL2 := "0100"&"10"&'1'&"01"&"11"&'0'&'0'&"00"&"000"&"00"&'0'&'0'&'0'&"00"&"00"; --FP add
		when "000111" => CTRL2 := "0100"&"10"&'1'&"01"&"11"&'0'&'0'&"00"&"000"&"00"&'1'&'0'&'0'&"00"&"00"; --FP mul
		
		when others => 	CTRL2 := "1000"&"10"&'1'&"01"&"01"&'0'&'0'&"00"&"010"&"00"&'0'&'0'&'0'&"00"&"00"; -- Default Add
						valid2 := '0';
		end case;
		
		if(INSTR2 = X"00000000") then
			valid2 := '0';
		end if;
		speculative_bit2 <= sbit;
		branch_tag2 <= btag;
		O_IMM2 <= Imm2;
		O_CTRL2 <= CTRL2;
		O_I2_DEST <= dest2;
		O_I2_Valid <= valid2;
		
		O_I1_REG1 <= INSTR1(25 downto 21);
		O_I2_REG1 <= INSTR2(25 downto 21);
		O_I1_REG2 <= INSTR1(20 downto 16);
		O_I2_REG2 <= INSTR2(20 downto 16);
		O_OPCODE1 <= OPCODE1;
		O_OPCODE2 <= OPCODE2;
		O_FUNC1 <= FUNC1;
		O_FUNC2 <= FUNC2;
		O_SHAMT1 <= INSTR1(10 downto 6);
		O_SHAMT2 <= INSTR2(10 downto 6);
		O_PC1 <= I_PC1;
		O_PC2 <= I_PC2;
		O_I1_HIST_IND <= I_I1_HIST_IND;
		O_I2_HIST_IND <= I_I2_HIST_IND;
		O_pred_bit1 <= I_pred_bit1;
		O_pred_bit2 <= I_pred_bit2;	
		end if;
	end process;
	
end behav;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG_COMMON.all;

entity decode_tb is 
end entity;

architecture struct of decode_tb is
signal CLK, RST: std_logic;
signal I_PC1, I_PC2 : std_logic_vector(31 downto 0); 
signal I_I1_HIST_IND, I_I2_HIST_IND: std_logic_vector(N_Br_TAG - 1 downto 0);
signal INSTR1, INSTR2 : std_logic_vector(31 downto 0);
signal I_pred_bit1, I_pred_bit2 : std_logic;
signal I_Branch_Valid : std_logic;
signal I_Branch_Result : std_logic;
signal I_Branch_tag : std_logic_vector(N_Br_TAG-1 downto 0);
signal O_PC1, O_PC2 : std_logic_vector(31 downto 0);
signal	O_OPCODE1, O_OPCODE2 : std_logic_vector(N_OPCODE_BITS-1 downto 0);
signal	O_FUNC1, O_FUNC2 : std_logic_vector(N_FUNC_BITS-1 downto 0);
signal	O_SHAMT1, O_SHAMT2 : std_logic_vector(N_SHAMT_BITS-1 downto 0);
signal	O_I1_REG1, O_I1_REG2 : std_logic_vector(N_LOG_AR-1 downto 0 );
signal	O_I2_REG1, O_I2_REG2 : std_logic_vector(N_LOG_AR-1 downto 0 );
signal	O_I1_DEST, O_I2_DEST : std_logic_vector(N_LOG_AR-1 downto 0 );
signal  O_I1_Valid, O_I2_Valid : std_logic;
signal	O_CTRL1, O_CTRL2 : std_logic_vector(N_CTRL_BITS-1 downto 0);
signal	speculative_bit1, speculative_bit2: std_logic;
signal O_pred_bit1, O_pred_bit2 : std_logic;
signal	branch_tag1, branch_tag2: std_logic_vector(N_Br_TAG-1 downto 0);
signal	O_IMM1, O_IMM2: std_logic_vector(31 downto 0);
signal O_I1_HIST_IND, O_I2_HIST_IND: std_logic_vector(N_Br_TAG - 1 downto 0);
signal jump_valid1, jump_valid2 : std_logic;
signal jump_addr1, jump_addr2 : std_logic_vector(31 downto 0);

component decode is
port(CLK, RST: in std_logic;
	I_PC1, I_PC2 : in std_logic_vector(31 downto 0);
	I_I1_HIST_IND, I_I2_HIST_IND: in std_logic_vector(N_Br_TAG - 1 downto 0);
	INSTR1, INSTR2 : in std_logic_vector(31 downto 0);
	I_pred_bit1, I_pred_bit2 : in std_logic;
	I_Branch_Valid : in std_logic;
	I_Branch_Result : in std_logic;
	I_Branch_tag : in std_logic_vector(N_Br_TAG-1 downto 0);
	O_PC1, O_PC2 : out std_logic_vector(31 downto 0);
	O_OPCODE1, O_OPCODE2 : out std_logic_vector(N_OPCODE_BITS-1 downto 0);
	O_FUNC1, O_FUNC2 : out std_logic_vector(N_FUNC_BITS-1 downto 0);
	O_SHAMT1, O_SHAMT2 : out std_logic_vector(N_SHAMT_BITS-1 downto 0);
	O_I1_REG1, O_I1_REG2 : out std_logic_vector(N_LOG_AR-1 downto 0 );
	O_I2_REG1, O_I2_REG2 : out std_logic_vector(N_LOG_AR-1 downto 0 );
	O_I1_DEST, O_I2_DEST : out std_logic_vector(N_LOG_AR-1 downto 0 );
	O_I1_Valid, O_I2_Valid : out std_logic;
	O_CTRL1, O_CTRL2 : out std_logic_vector(N_CTRL_BITS-1 downto 0);
	speculative_bit1, speculative_bit2 : out std_logic;
	O_pred_bit1, O_pred_bit2 : out std_logic;
	branch_tag1, branch_tag2: out std_logic_vector(N_Br_TAG-1 downto 0);
	O_IMM1, O_IMM2: out std_logic_vector(31 downto 0);
	O_I1_HIST_IND, O_I2_HIST_IND : out std_logic_vector(N_Br_TAG - 1 downto 0);
	jump_valid1, jump_valid2 : out std_logic;
	jump_addr1, jump_addr2 : out std_logic_vector(31 downto 0));
end component;
begin
	process
		begin
		clk <= '0';
		wait for 40 ns;
		clk <= '1';
		wait for 40 ns;
		end process;

dcd: decode port map(CLK, RST,I_PC1,I_PC2,I_I1_HIST_IND, I_I2_HIST_IND, INSTR1, INSTR2,I_pred_bit1, I_pred_bit2,I_Branch_Valid, I_Branch_Result, I_Branch_tag, O_PC1, O_PC2, O_OPCODE1, O_OPCODE2, O_FUNC1, O_FUNC2, O_SHAMT1,O_SHAMT2, O_I1_REG1, O_I1_REG2,
					O_I2_REG1, O_I2_REG2, O_I1_DEST, O_I2_DEST,O_I1_Valid, O_I2_Valid, O_CTRL1, O_CTRL2, speculative_bit1, speculative_bit2,O_pred_bit1, O_pred_bit2, branch_tag1, branch_tag2, O_IMM1, O_IMM2, O_I1_HIST_IND, O_I2_HIST_IND, jump_valid1, jump_valid2, jump_addr1, jump_addr2);
					
I_PC1 <= "00000000000000000000000000000000";
I_PC2 <= "00000000000000000000000000000001";
I_I1_HIST_IND <= (others => '0');
I_I2_HIST_IND <= (others => '0');
I_pred_bit1 <= '1';
I_pred_bit2<= '1';
I_Branch_Valid <= '0', '0' after 320 ns, '0' after 480 ns;
I_Branch_Result <= '1', '0' after 400 ns ;
I_Branch_tag <= "1100";

 
INSTR1 <= "00000000000000010001000000100000", "00000000000000010001000000100000" after 80 ns, "00000000000000010001000000100000" after 160 ns,
          "00001000000000000000000000000000" after 240 ns, "00000000000000010001000000100000" after 320 ns,
          "00001000000000000000000000000000" after 400 ns, "00000000000000010001000000100000" after 480 ns;
INSTR2 <= "00000000000000010001000000100000", "00001000000000010001000000100000" after 80 ns, "00000000000000010001000000100000" after 160 ns,
 "00000000000000010001000000100000" after 240 ns, "00000000000000010001000000100000" after 320 ns,
 "00000000000000010001000000100000" after 400 ns, "00000000000000010001000000100000" after 480 ns;
 
end struct;


