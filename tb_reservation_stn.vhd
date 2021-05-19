library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PACKAGE_DTYPES_RS_FPU.all;

entity tb is end entity;

architecture ARCH1 of tb is

--	constant N_ENTRIES 	: integer := 8;

--	constant N_TAG_BITS 	: integer := 5 ;
--	constant N_LOC_BITS  : integer := 3 ;
	
component RESERVATION_STN_FPU is
port ( 
			CLK, RST   		: in std_logic;
			
			-- Dispatch Slots
			D_SLOT_VALID 	: in std_logic_vector(2 downto 0) ;
			DS1_INSTR, DS2_INSTR, DS3_INSTR : in std_logic_vector(N_OPCODE_BITS+N_SHAMT_BITS+N_FUNC_BITS-1 downto 0);
			DS1_OPR1, DS1_OPR2, DS2_OPR1, DS2_OPR2, DS3_OPR1, DS3_OPR2 	: in std_logic_vector(31 downto 0);
			DS1_OPR1_VAL, DS1_OPR2_VAL, DS2_OPR1_VAL, DS2_OPR2_VAL, DS3_OPR1_VAL, DS3_OPR2_VAL : in std_logic ;
			DS1_CTRL, DS2_CTRL, DS3_CTRL	: in std_logic_vector(N_CTRL_BITS-1 downto 0);
			DS1_DEST, DS2_DEST, DS3_DEST  : in std_logic_vector(N_LOG_RR-1 downto 0);
			
			-- Forwarding slots
			DATA_FWD_SLOT1, DATA_FWD_SLOT2, DATA_FWD_SLOT3, DATA_FWD_SLOT4 : in std_logic_vector(31 downto 0);  
			TAG_FWD_SLOT1, TAG_FWD_SLOT2, TAG_FWD_SLOT3, TAG_FWD_SLOT4 : in std_logic_vector(N_TAG_BITS-1 downto 0);  
			VAL_FWD_SLOTS : in std_logic_vector(3 downto 0);
			
			-- Outputs
			DREG_OPR1, DREG_OPR2 : out std_logic_vector(31 downto 0);
			DREG_CTRL 				: out std_logic_vector(N_CTRL_BITS-1 downto 0); 	
			DREG_INSTR				: out std_logic_vector(N_OPCODE_BITS+N_SHAMT_BITS+N_FUNC_BITS-1 downto 0);
			DREG_DEST 			   : out std_logic_vector(N_LOG_RR-1 downto 0);
			RS_OUTPUT_VALID      : out std_logic;	
			
			-- TEMP OUTPUTS --
			TEMP_N_INSTR_IN_STN   : out std_logic_vector(N_LOC_BITS downto 0);
			TEMP_ALLOC_BITS : out std_logic_vector(3 downto 0); 
			TEMP_BUSY_BITS, TEMP_READY_BITS : out std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);
			TEMP_ISEQ3, TEMP_ISEQ2 , TEMP_ISEQ1, TEMP_ISEQ0 : out std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);
			TEMP_LOC1, TEMP_LOC2, TEMP_LOC3 : out std_logic_vector(N_LOC_BITS downto 0)

			);
end component;

signal 	CLK 			:  std_logic := '0'; 
signal 	RST   		:  std_logic := '0';
signal	D_SLOT_VALID 	:  std_logic_vector(2 downto 0) ;
signal 	DS1_INSTR, DS2_INSTR, DS3_INSTR :  std_logic_vector(N_OPCODE_BITS+N_SHAMT_BITS+N_FUNC_BITS-1 downto 0);
signal 			DS1_DEST, DS2_DEST, DS3_DEST  : std_logic_vector(N_LOG_RR-1 downto 0);
signal			DS1_OPR1, DS1_OPR2, DS2_OPR1, DS2_OPR2, DS3_OPR1, DS3_OPR2 	:  std_logic_vector(31 downto 0) := (others => '0');
signal			DS1_OPR1_VAL, DS1_OPR2_VAL, DS2_OPR1_VAL, DS2_OPR2_VAL, DS3_OPR1_VAL, DS3_OPR2_VAL :  std_logic := '0';
signal			DS1_CTRL, DS2_CTRL, DS3_CTRL	: std_logic_vector(N_CTRL_BITS-1 downto 0) := (others => '0');
signal			DATA_FWD_SLOT1, DATA_FWD_SLOT2, DATA_FWD_SLOT3, DATA_FWD_SLOT4 :  std_logic_vector(31 downto 0);  
signal			TAG_FWD_SLOT1, TAG_FWD_SLOT2, TAG_FWD_SLOT3, TAG_FWD_SLOT4 :  std_logic_vector(N_TAG_BITS-1 downto 0);  
signal			VAL_FWD_SLOTS :  std_logic_vector(3 downto 0);
			
signal			DREG_OPR1, DREG_OPR2 :  std_logic_vector(31 downto 0);
signal			DREG_CTRL 				:  std_logic_vector(N_CTRL_BITS-1 downto 0); 
signal			DREG_INSTR				:  std_logic_vector(N_OPCODE_BITS+N_SHAMT_BITS+N_FUNC_BITS-1 downto 0);
signal 			DREG_DEST 			   :  std_logic_vector(N_LOG_RR-1 downto 0);

	
signal			TMP_N_INSTR_IN_STN   :  std_logic_vector(N_LOC_BITS downto 0);
			
			-- TEMP OUTPUTS --
signal TEMP_ALLOC_BITS : std_logic_vector(3 downto 0);
signal TEMP_LOC1, TEMP_LOC2, TEMP_LOC3 :  std_logic_vector(N_LOC_BITS downto 0);
signal TEMP_BUSY_BITS, TEMP_READY_BITS	: std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);
signal TEMP_ISEQ3, TEMP_ISEQ2, TEMP_ISEQ1, TEMP_ISEQ0 : std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);
signal OUT_VALID : std_logic;
begin

 dut: RESERVATION_STN_FPU port map ( CLK => CLK, RST => RST , D_SLOT_VALID 	=> D_SLOT_VALID ,
											DS1_INSTR => DS1_INSTR, DS2_INSTR => DS2_INSTR, DS3_INSTR => DS3_INSTR, 
											
											DS1_OPR1 => DS1_OPR1, DS1_OPR2 => DS1_OPR2, 
											DS2_OPR1 => DS2_OPR1, DS2_OPR2 => DS2_OPR2, 
											DS3_OPR1 => DS3_OPR1, DS3_OPR2 => DS3_OPR2,
											
											DS1_OPR1_VAL => DS1_OPR1_VAL, DS1_OPR2_VAL => DS1_OPR2_VAL, 
											DS2_OPR1_VAL => DS2_OPR1_VAL, DS2_OPR2_VAL => DS2_OPR2_VAL, 
											DS3_OPR1_VAL => DS3_OPR1_VAL, DS3_OPR2_VAL => DS3_OPR2_VAL,
											
											DS1_DEST => DS1_DEST, DS2_DEST => DS2_DEST, DS3_DEST => DS3_DEST,
											DS1_CTRL => DS1_CTRL, DS2_CTRL => DS2_CTRL, DS3_CTRL => DS3_CTRL ,
											DATA_FWD_SLOT1 => DATA_FWD_SLOT1, DATA_FWD_SLOT2 => DATA_FWD_SLOT2 , 
											DATA_FWD_SLOT3 => DATA_FWD_SLOT3, DATA_FWD_SLOT4 => DATA_FWD_SLOT4 ,
											TAG_FWD_SLOT1 => TAG_FWD_SLOT1, TAG_FWD_SLOT2 => TAG_FWD_SLOT2, 
											TAG_FWD_SLOT3 => TAG_FWD_SLOT3, TAG_FWD_SLOT4 => TAG_FWD_SLOT4 , 
											VAL_FWD_SLOTS => VAL_FWD_SLOTS,
											TEMP_ISEQ3 => TEMP_ISEQ3, TEMP_ISEQ2 => TEMP_ISEQ2, 
											TEMP_ISEQ1 => TEMP_ISEQ1, TEMP_ISEQ0 => TEMP_ISEQ0,
											DREG_INSTR => DREG_INSTR , DREG_DEST => DREG_DEST ,
											
											DREG_OPR1 => DREG_OPR1, DREG_OPR2 => DREG_OPR2 , 
											DREG_CTRL => DREG_CTRL , 	
											RS_OUTPUT_VALID => OUT_VALID ,
									
									
											-- TEMP OUTPUTS --
											TEMP_N_INSTR_IN_STN => TMP_N_INSTR_IN_STN , 														
											TEMP_ALLOC_BITS => TEMP_ALLOC_BITS ,
											TEMP_BUSY_BITS => TEMP_BUSY_BITS , TEMP_READY_BITS => TEMP_READY_BITS ,
											TEMP_LOC1 => TEMP_LOC1, TEMP_LOC2 => TEMP_LOC2, TEMP_LOC3 => TEMP_LOC3 );
	
	process
	begin
		for i in 0 to 31 loop
			if i = 0 then
				rst <= '1' ;
			end if;
		
			if i = 2 then
				rst <= '0';
			end if;	
				

				
			wait for 5ns;
				
			clk <= '1';

			wait for 1ps ;
			
			if (i = 3) then
				D_SLOT_VALID <= (others => '1');
				
				DS1_OPR1 <= X"10101010";
				DS1_OPR2 <= X"01010101";
				DS1_DEST <= "00001" ;
				DS1_INSTR <= (others => '1') ;
				DS2_OPR1 <= X"20202020";
				DS2_OPR2 <= X"02020202";
				DS2_DEST <= "00010" ;
				DS2_INSTR <= (others => '1') ;
				
				DS3_OPR1 <= X"30303030";
				DS3_OPR2 <= X"03030303";
				DS3_DEST <= "00011" ;
				DS3_INSTR <= (others => '1') ;
				
				DS1_OPR1_VAL <= '1';
				DS1_OPR2_VAL <= '1';
				DS2_OPR1_VAL <= '1';
				DS2_OPR2_VAL <= '1';
				DS3_OPR1_VAL <= '1';
				DS3_OPR2_VAL <= '1';
				
				DS1_CTRL <= (others => '1');
				DS2_CTRL <= (others => '1');
				DS3_CTRL <= (others => '1');

			elsif (i = 4) then
				D_SLOT_VALID <= (others => '1');
				DS1_OPR1 <= X"40404040";
				DS1_OPR2 <= X"04040404";
				DS2_OPR1 <= X"50505050";
				DS2_OPR2 <= X"05050505";
				DS3_OPR1 <= X"60606060";
				DS3_OPR2 <= X"06060606";
				
				DS1_OPR1_VAL <= '1';
				DS1_OPR2_VAL <= '1';
				DS2_OPR1_VAL <= '1';
				DS2_OPR2_VAL <= '1';
				DS3_OPR1_VAL <= '1';
				DS3_OPR2_VAL <= '1';
				
				DS1_CTRL <= (others => '1');
				DS2_CTRL <= (others => '1');
				DS3_CTRL <= (others => '1');
			
			elsif (i = 6) then
				
				D_SLOT_VALID <= "111";
				
				DS1_OPR1 <= X"70707070";
				DS1_OPR2 <= X"07070707";
				DS2_OPR1 <= X"80808080";
				DS2_OPR2 <= X"08080808";
				DS3_OPR1 <= X"90909091";
				DS3_OPR2 <= X"09090919";
				
				DS1_OPR1_VAL <= '0';
				DS1_OPR2_VAL <= '0';
				DS2_OPR1_VAL <= '1';
				DS2_OPR2_VAL <= '1';
				DS3_OPR1_VAL <= '0';
				DS3_OPR2_VAL <= '0';
				
				DS1_CTRL <= (others => '1');
				DS2_CTRL <= (others => '1');
				DS3_CTRL <= (others => '1');

				VAL_FWD_SLOTS <= "1111" ;
				
				TAG_FWD_SLOT4 <= "10001" ;
				DATA_FWD_SLOT4 <= X"9f9f9f9f";
				
				TAG_FWD_SLOT3 <= "11001" ;
				DATA_FWD_SLOT3 <= X"f9f9f9f9";			

				TAG_FWD_SLOT2 <= "10000" ;
				DATA_FWD_SLOT2 <= X"7f7f7f7f";			
				
				TAG_FWD_SLOT1 <= "00111" ;
				DATA_FWD_SLOT1 <= X"f7f7f7f7";			
				
			
			elsif (i = 8) then
				
				D_SLOT_VALID <= "101";
				
				DS1_OPR1 <= X"12121212";
				DS1_OPR2 <= X"21212121";
				DS2_OPR1 <= X"81818181";
				DS2_OPR2 <= X"18181818";
				DS3_OPR1 <= X"91919191";
				DS3_OPR2 <= X"19191919";
				
				DS1_OPR1_VAL <= '1';
				DS1_OPR2_VAL <= '1';
				DS2_OPR1_VAL <= '1';
				DS2_OPR2_VAL <= '1';
				DS3_OPR1_VAL <= '0';
				DS3_OPR2_VAL <= '0';
				
				DS1_CTRL <= (others => '1');
				DS2_CTRL <= (others => '1');
				DS3_CTRL <= (others => '1');

				VAL_FWD_SLOTS <= "1100" ;
				
				TAG_FWD_SLOT4 <= "10001" ;
				DATA_FWD_SLOT4 <= X"9f9f9f9f";
				
				TAG_FWD_SLOT3 <= "11001" ;
				DATA_FWD_SLOT3 <= X"f9f9f9f9";			

			elsif (i = 9) then
				
				D_SLOT_VALID <= "010";
				
				DS1_OPR1 <= X"12121212";
				DS1_OPR2 <= X"21212121";
				DS2_OPR1 <= X"81818181";
				DS2_OPR2 <= X"18181818";
				DS3_OPR1 <= X"91919191";
				DS3_OPR2 <= X"19191919";
				
				DS1_OPR1_VAL <= '0';
				DS1_OPR2_VAL <= '0';
				DS2_OPR1_VAL <= '0';
				DS2_OPR2_VAL <= '0';
				DS3_OPR1_VAL <= '0';
				DS3_OPR2_VAL <= '0';
				
				DS1_CTRL <= (others => '1');
				DS2_CTRL <= (others => '1');
				DS3_CTRL <= (others => '1');

				VAL_FWD_SLOTS <= "1100" ;
				
				TAG_FWD_SLOT4 <= "10001" ;
				DATA_FWD_SLOT4 <= X"9f9f9f9f";
				
				TAG_FWD_SLOT3 <= "11001" ;
				DATA_FWD_SLOT3 <= X"f9f9f9f9";			
				
			elsif (i = 15) then
				D_SLOT_VALID <= (others => '0');
				VAL_FWD_SLOTS <= "0011" ;
				
				TAG_FWD_SLOT2 <= "00001" ;
				DATA_FWD_SLOT2 <= X"f6f7f8f9";
				
				TAG_FWD_SLOT1 <= "11000" ;
				DATA_FWD_SLOT1 <= X"5f6f7f8f";
			else
				D_SLOT_VALID <= (others => '0');
			
			end if;
			
			wait for 5ns;
				
			clk <= '0';
		
		end loop;
	
		wait;
	end process;
	
	
	
end architecture ;