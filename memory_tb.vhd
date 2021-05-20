library ieee;
use ieee.std_logic_1164.all;

entity memory_tb is
	generic (address_bit 	: integer := 32;
				data_bit 		: integer := 32;
				N_CTRL_BITS 	: integer := 27;
				N_LOG_RR 		: integer := 5;
				BUFFER_SIZE 	: INTEGER := 4;
				N_LOG_ROB 		: integer := 7;
				ram_size		: integer := 2**9 -1);

 end entity;

architecture arch_tb of memory_tb is



component memory is
	generic (address_bit 	: integer := 32;
				data_bit 		: integer := 32;
				N_CTRL_BITS 	: integer := 27;
				N_LOG_RR 		: integer := 5;
				BUFFER_SIZE 	: INTEGER := 4;
				N_LOG_ROB 		: integer := 7;
				ram_size		: integer := 2**9 -1);
port(
		clk 					: in std_logic;
		rst						: in std_logic;
		
		SB_Enable				: in std_logic;
		SB_mem_add				: in std_logic_vector(data_bit -1 downto 0);
		SB_Data					: in std_logic_vector(address_bit - 1 downto 0);		
		
		DREG_CTRL 				: in std_logic_vector(N_CTRL_BITS-1 downto 0); 
		DREG_DEST 			  	: in std_logic_vector(N_LOG_RR-1 downto 0);
		DREG_ROB_LOC			: in std_logic_vector(N_LOG_ROB-1 downto 0);
		RS_OUTPUT_VALID      	: in std_logic;

		operand0 				: in std_logic_vector(address_bit - 1 downto 0);	-- Rt
		operand1 				: in std_logic_vector(address_bit - 1 downto 0);	-- Rs
		operand2 				: in std_logic_vector(address_bit - 1 downto 0);	-- Imm
		
		in_freeloc 				: in std_logic_vector(BUFFER_SIZE-1 downto 0);
		out_freeloc 			: out std_Logic_vector(BUFFER_SIZE-1 downto 0);

		Data 					: out std_logic_vector(data_bit - 1 downto 0);
		
		mem_address 			: out std_logic_vector(address_bit - 1 downto 0);
		valid 					: out std_logic;
		sw_valid 				: out std_logic;
		reg_dest 				: out std_logic_vector(N_LOG_RR-1 downto 0);
		reg_rob_loc				: out std_logic_vector(N_LOG_ROB-1 downto 0));
		
end component;

signal clk : std_logic;
signal rst : std_logic;
		
signal SB_Enable				: std_logic;
signal SB_mem_add				: std_logic_vector(data_bit -1 downto 0);
signal SB_Data					: std_logic_vector(address_bit - 1 downto 0);

signal	DREG_CTRL 				: std_logic_vector(N_CTRL_BITS-1 downto 0); 
signal	DREG_DEST 			  	: std_logic_vector(N_LOG_RR-1 downto 0);
signal	DREG_ROB_LOC			: std_logic_vector(N_LOG_ROB-1 downto 0);
signal	RS_OUTPUT_VALID      	: std_logic;

signal	operand0 				: std_logic_vector(address_bit - 1 downto 0);	-- Rt
signal	operand1 				: std_logic_vector(address_bit - 1 downto 0);	-- Rs
signal	operand2 				: std_logic_vector(address_bit - 1 downto 0);	-- Imm
		
signal	in_freeloc 				: std_logic_vector(BUFFER_SIZE-1 downto 0);
signal	out_freeloc 			: std_Logic_vector(BUFFER_SIZE-1 downto 0);

signal	Data 					: std_logic_vector(data_bit - 1 downto 0);
		
signal	mem_address 			: std_logic_vector(address_bit - 1 downto 0);
signal	valid 					: std_logic;
signal	sw_valid 				: std_logic;
signal	reg_dest 				: std_logic_vector(N_LOG_RR-1 downto 0);
signal	reg_rob_loc				: std_logic_vector(N_LOG_ROB-1 downto 0);

begin
dut_instance : memory port map(clk, rst, SB_Enable, SB_mem_add, SB_Data, DREG_CTRL, DREG_DEST, DREG_ROB_LOC, RS_OUTPUT_VALID, operand0, operand1, operand2, in_freeloc, out_freeloc, Data, mem_address,valid, sw_valid, reg_dest, reg_rob_loc);
--								1	 1	   1			32			32		27		5			7				1				32		32			32			4			4		 32		  32			1		1		5			7
process begin

clk <= '0';
		for i in 0 to 15 loop
			wait for 5 ps; clk<=not clk; wait for 5 ps; clk<=not clk;
		end loop;
		wait;
end process;


process begin

--	Ctrl_store <= "001000000000000000000010000";
--	Ctrl_load  <= "001000000000000000000100000";

-- STORE

	rst					<= '1';
	SB_Enable  			<= '1';
	SB_mem_add 			<= "00000000000000000000000000010101";
	SB_Data 			<= "00000000000000000000000000010101";
	DREG_CTRL 			<= "001000000000000000000010000";
	DREG_DEST		 	<= "11111";
	DREG_ROB_LOC	 	<= "1111111";
	RS_OUTPUT_VALID 	<= '1';
	operand0			<= "00000000000000000000000000010101";
	operand1			<= "00000000000000000000000000010101";
	operand2			<= "00000000000000000000000000010101";
	in_freeloc 			<= "1111";
	wait for 10 ps;

	rst					<= '0';
	SB_Enable  			<= '1';
	SB_mem_add 			<= "00000000000000000000000000010101";
	SB_Data 			<= "00000000000000000000000000010101";
	DREG_CTRL 			<= "001000000000000000000010000";
	DREG_DEST		 	<= "11111";
	DREG_ROB_LOC	 	<= "1111111";
	RS_OUTPUT_VALID 	<= '1';
	operand0			<= "00000000000000000000000000010101";
	operand1			<= "00000000000000000000000000010101";
	operand2			<= "00000000000000000000000000010101";
	in_freeloc 			<= "1111";
	wait for 10 ps;
	
	rst					<= '0';
	SB_Enable  			<= '1';
	SB_mem_add 			<= "00000000000000000000000000010111";
	SB_Data 			<= "00000000000000000000000000010111";
	DREG_CTRL 			<= "001000000000000000000010000";
	DREG_DEST		 	<= "11111";
	DREG_ROB_LOC	 	<= "1111111";
	RS_OUTPUT_VALID 	<= '1';
	operand0			<= "00000000000000000000000000010111";
	operand1			<= "00000000000000000000000000010111";
	operand2			<= "00000000000000000000000000010111";
	in_freeloc 			<= "1111";
	wait for 10 ps;
	
	rst					<= '0';
	SB_Enable  			<= '1';
	SB_mem_add 			<= "00000000000000000000000000011111";
	SB_Data 			<= "00000000000000000000000000011111";
	DREG_CTRL 			<= "001000000000000000000010000";
	DREG_DEST		 	<= "11111";
	DREG_ROB_LOC	 	<= "1111111";
	RS_OUTPUT_VALID 	<= '1';
	operand0			<= "00000000000000000000000000011111";
	operand1			<= "00000000000000000000000000010101";
	operand2			<= "00000000000000000000000000001010";
	in_freeloc 			<= "1111";
	wait for 10 ps;
	
	-- LOAD

	rst					<= '0';
	SB_Enable  			<= '0';
	SB_mem_add 			<= "00000000000000000000000000010101";
	SB_Data 			<= "00000000000000000000000000010101";
	DREG_CTRL 			<= "001000000000000000000100000";
	DREG_DEST		 	<= "11111";
	DREG_ROB_LOC	 	<= "1111111";
	RS_OUTPUT_VALID 	<= '1';
	operand0			<= "00000000000000000000000000010101";
	operand1			<= "00000000000000000000000000010101";
	operand2			<= "00000000000000000000000000001010";
	in_freeloc 			<= "1111";
	wait for 10 ps;
	
	rst					<= '0';
	SB_Enable  			<= '0';
	SB_mem_add 			<= "00000000000000000000000000010111";
	SB_Data 			<= "00000000000000000000000000010111";
	DREG_CTRL 			<= "001000000000000000000100000";
	DREG_DEST		 	<= "11111";
	DREG_ROB_LOC	 	<= "1111111";
	RS_OUTPUT_VALID 	<= '1';
	operand0			<= "00000000000000000000000000010101";
	operand1			<= "00000000000000000000000000010111";
	operand2			<= "00000000000000000000000000010111";
	in_freeloc 			<= "1111";
	wait for 10 ps;
	
	rst					<= '0';
	SB_Enable  			<= '0';
	SB_mem_add 			<= "00000000000000000000000000010111";
	SB_Data 			<= "00000000000000000000000000010111";	
	DREG_CTRL 			<= "001000000000000000000100000";
	DREG_DEST		 	<= "11111";
	DREG_ROB_LOC	 	<= "1111111";
	RS_OUTPUT_VALID 	<= '1';
	operand0			<= "00000000000000000000000000010101";
	operand1			<= "00000000000000000000000000010101";
	operand2			<= "00000000000000000000000000010101";
	in_freeloc 			<= "1111";
	wait for 10 ps;
	
--	num1 <= "01111111100000000000000000000000";
--	num2 <= "01111111100000000000000000000000";
--	wait for 10ns;
	
	wait;
end process;

end arch_tb;