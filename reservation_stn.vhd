library ieee;
use ieee.std_logic_1164.all;

package PACKAGE_DTYPES_RS_FPU is

	constant N_ENTRIES_FPU_RS 	: integer := 8;
<<<<<<< HEAD
	constant N_CTRL_BITS 		: integer := 27;
	constant N_TAG_BITS 	: integer := 5 ;
	constant N_LOC_BITS  : integer := 3 ;
	constant N_LOG_RR : integer := 5 ;
	constant N_LOG_ROB : integer := 7;
	constant N_OPCODE_BITS : integer := 6;
	constant N_SHAMT_BITS : integer := 5;
	constant N_FUNC_BITS : integer := 6;
	constant N_BR_BITS_FOR_RS : integer := 10;
	
	type t_arrN_slv32 is array(0 to N_ENTRIES_FPU_RS - 1) of std_logic_vector(31 downto 0); 
	type t_arrN_slvN  is array(0 to N_ENTRIES_FPU_RS - 1) of std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);  
	type t_arrN_slvC  is array(0 to N_ENTRIES_FPU_RS - 1) of std_logic_vector(N_CTRL_BITS-1 downto 0);   
	
	type t_arrN_slvRob is array(0 to N_ENTRIES_FPU_RS - 1) of std_logic_vector(N_LOG_ROB-1 downto 0);   
	
	type t_arr3_slvLoc is array (0 to 2) of std_logic_vector(N_LOC_BITS downto 0);
	
	type t_arrN_slvInstr is array(0 to N_ENTRIES_FPU_RS - 1) of std_logic_vector(N_OPCODE_BITS+N_SHAMT_BITS+N_FUNC_BITS-1 downto 0); 
	
	type t_arrN_slvBranch is array(0 to N_ENTRIES_FPU_RS - 1) of std_logic_vector(N_BR_BITS_FOR_RS-1 downto 0); 
	
	-- For forwarding slots
	type t_arrData_slv is array (3 downto 0) of std_logic_vector(31 downto 0);
	type t_arrTag_slv is array (3 downto 0) of std_logic_vector(N_TAG_BITS-1 downto 0);
	type t_arrN_slvRr is array (0 to N_ENTRIES_FPU_RS - 1) of std_logic_vector(N_LOG_RR-1 downto 0);   
=======
	constant N_FUNC_BITS 		: integer := 16;
	constant N_TAG_BITS 	: integer := 5 ;
	constant N_LOC_BITS  : integer := 3 ;
	
	type t_arrN_slv32 is array(0 to N_ENTRIES_FPU_RS - 1) of std_logic_vector(31 downto 0); 
	type t_arrN_slvN  is array(0 to N_ENTRIES_FPU_RS - 1) of std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);  
	type t_arrN_slvC  is array(0 to N_ENTRIES_FPU_RS - 1) of std_logic_vector(N_FUNC_BITS-1 downto 0);   
	
	type t_arr3_slvLoc is array (0 to 2) of std_logic_vector(N_LOC_BITS downto 0);
	
	-- For forwarding slots
	type t_arrData_slv is array (3 downto 0) of std_logic_vector(31 downto 0);
	type t_arrTag_slv is array (3 downto 0) of std_logic_vector(N_TAG_BITS-1 downto 0);
	
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
end package;

library ieee;
use ieee.std_logic_1164.all;

entity ENCODER8x3 is 
port 
	( 
		INPUT  : in std_logic_vector(7 downto 0) ;
		OUTPUT : out std_logic_vector(2 downto 0) ;
		VALID  : out std_logic );
end entity;

architecture ARCH1 of ENCODER8x3 is 
begin

	OUTPUT <= "000" when INPUT(0) = '1' else
				 "001" when INPUT(1) = '1' else
				 "010" when INPUT(2) = '1' else
				 "011" when INPUT(3) = '1' else
				 "100" when INPUT(4) = '1' else
				 "101" when INPUT(5) = '1' else
				 "110" when INPUT(6) = '1' else				 
				 "111" when INPUT(7) = '1' else				 
				 "000" ;
				 
	VALID <= '0' when INPUT = "00000000"	else '1';		 
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity ENCODER4x2 is 
port 
	( 
		INPUT  : in std_logic_vector(3 downto 0) ;
		OUTPUT : out std_logic_vector(1 downto 0) ;
		VALID  : out std_logic );
end entity;

architecture ARCH1 of ENCODER4x2 is 
begin

	OUTPUT <= "00" when INPUT(0) = '1' else
				 "01" when INPUT(1) = '1' else
				 "10" when INPUT(2) = '1' else
				 "11" when INPUT(3) = '1' else
				 "00" ;
	VALID <= '0' when INPUT = "0000"	else '1';		 
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.PACKAGE_DTYPES_RS_FPU.all;

entity MUX8x1 is 
	port ( 
				DATA1, DATA2, DATA3, DATA4 : in std_logic_vector(N_LOC_BITS-1 downto 0);
				DATA5, DATA6, DATA7, DATA8 : in std_logic_vector(N_LOC_BITS-1 downto 0);
				SEL : in std_logic_vector(2 downto 0);
				OUTPUT : out std_logic_vector(N_LOC_BITS-1 downto 0) );
end entity;	

architecture ARCH1 of MUX8x1 is 

begin

	OUTPUT <= DATA1 when SEL = "000" else
				 DATA2 when SEL = "001" else
				 DATA3 when SEL = "010" else
				 DATA4 when SEL = "011" else
				 DATA5 when SEL = "100" else
				 DATA6 when SEL = "101" else
				 DATA7 when SEL = "110" else
				 DATA8 ;
end architecture;


library ieee;
use ieee.std_logic_1164.all;

entity MUX4x1 is 
	port ( 
				DATA1, DATA2, DATA3, DATA4 : in std_logic_vector(31 downto 0);
				SEL : in std_logic_vector(1 downto 0);
				OUTPUT : out std_logic_vector(31 downto 0) );
end entity;	

architecture ARCH1 of MUX4x1 is 

begin

	OUTPUT <= DATA1 when SEL = "00" else
				 DATA2 when SEL = "01" else
				 DATA3 when SEL = "10" else
				 DATA4 ;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.PACKAGE_DTYPES_RS_FPU.all;

entity READ_FWD_DATA is	
	port    ( 
				 FWD_DATA_SLOT1, FWD_DATA_SLOT2, FWD_DATA_SLOT3, FWD_DATA_SLOT4 : in std_logic_vector(31 downto 0) ;
				 FWD_TAG_SLOT1 , FWD_TAG_SLOT2 , FWD_TAG_SLOT3 , FWD_TAG_SLOT4  : in std_logic_vector(N_TAG_BITS - 1 downto 0);
				 VAL_FWD_ALL_SLOTS  : in std_logic_vector(3 downto 0);
				 TBL_OPR1, TBL_OPR2 : in t_arrN_slv32 ;	
				 TBL_O1VL, TBL_O2VL : in std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);  
				 OPR1_TO_COPY, OPR2_TO_COPY : out t_arrN_slv32;
				 OPR1_VAL_COPY, OPR2_VAL_COPY : out std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0) ) ;
end entity;															

architecture ARCH1 of READ_FWD_DATA is 

type t_arr4_slvTag is array (0 to 3) of std_logic_vector(N_TAG_BITS - 1 downto 0);
type t_arrN_slv4 is array (0 to N_ENTRIES_FPU_RS-1) of std_logic_vector(3 downto 0);


signal TAG_FWD_ALL_SLOTS : t_arr4_slvTag ;
signal MATCH_OPR1, MATCH_OPR2 : t_arrN_slv4 ;

component ENCODER4x2 is 
port 
	( 
		INPUT  : in std_logic_vector(3 downto 0) ;
		OUTPUT : out std_logic_vector(1 downto 0) ;
		VALID  : out std_logic );
end component;

component MUX4x1 is 
	port ( 
				DATA1, DATA2, DATA3, DATA4 : in std_logic_vector(31 downto 0);
				SEL : in std_logic_vector(1 downto 0);
				OUTPUT : out std_logic_vector(31 downto 0) );
end component;	

type t_arrN_slv2 is array(0 to N_ENTRIES_FPU_RS - 1 ) of std_logic_vector(1 downto 0);
signal MATCH_LOC_O1, MATCH_LOC_O2 : t_arrN_slv2 ;

signal INPUT_ENCODER1, INPUT_ENCODER2 : t_arrN_slv4;
begin

		TAG_FWD_ALL_SLOTS(0) <= FWD_TAG_SLOT1;
		TAG_FWD_ALL_SLOTS(1) <= FWD_TAG_SLOT2;
		TAG_FWD_ALL_SLOTS(2) <= FWD_TAG_SLOT3;
		TAG_FWD_ALL_SLOTS(3) <= FWD_TAG_SLOT4;
		
		g1: for i in 0 to N_ENTRIES_FPU_RS-1 generate
			g2: for j in 0 to 3 generate
				MATCH_CKT1: MATCH_OPR1(i)(j) <= '1' when 
								( ( TAG_FWD_ALL_SLOTS(j) = TBL_OPR1(i)(N_TAG_BITS -1 downto 0) )
													and TBL_O1VL(i) = '0' and VAL_FWD_ALL_SLOTS(j) = '1' )  else '0';
				MATCH_CKT2: MATCH_OPR2(i)(j) <= '1' when 
								( ( TAG_FWD_ALL_SLOTS(j) = TBL_OPR2(i)(N_TAG_BITS -1 downto 0) )
													and TBL_O2VL(i) = '0' and VAL_FWD_ALL_SLOTS(j) = '1' ) else '0';
													
			end generate;	

			INPUT_ENCODER1(i) <= MATCH_OPR1(i)(3) & MATCH_OPR1(i)(2) & MATCH_OPR1(i)(1) & MATCH_OPR1(i)(0) ; 
			INPUT_ENCODER2(i) <= MATCH_OPR2(i)(3) & MATCH_OPR2(i)(2) & MATCH_OPR2(i)(1) & MATCH_OPR2(i)(0) ; 
			
			ENC_O1	 : ENCODER4x2 port map ( INPUT => INPUT_ENCODER1(i), 
														 OUTPUT => MATCH_LOC_O1(i) , VALID => OPR1_VAL_COPY(i) );
																											
			ENC_02    : ENCODER4x2 port map ( INPUT => INPUT_ENCODER2(i),
														 OUTPUT => MATCH_LOC_O2(i) , VALID => OPR2_VAL_COPY(i) );
			
			MUX_O1    : MUX4x1 port map ( FWD_DATA_SLOT1, FWD_DATA_SLOT2, FWD_DATA_SLOT3, FWD_DATA_SLOT4, MATCH_LOC_O1(i), OPR1_TO_COPY(i) );
			MUX_O2    : MUX4x1 port map ( FWD_DATA_SLOT1, FWD_DATA_SLOT2, FWD_DATA_SLOT3, FWD_DATA_SLOT4, MATCH_LOC_O2(i), OPR2_TO_COPY(i) );			
		end generate;

		
end architecture;


<<<<<<< HEAD
=======
--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;		
--use work.PACKAGE_DTYPES_RS_FPU.all;
--
--entity ALLOCATE_BLK_RS_FPU is
--port 	 ( CLK									: in std_logic;
--			TBL_BUSY_BITS 						: in std_logic_vector(N_ENTRIES_FPU_RS - 1 downto 0) ;
--			D_SLOT_VALID						: in std_logic_vector(2 downto 0);
--			
--			TEMP_ALLOC_BITS					: out std_logic_vector(3 downto 0);
--			STN_LOC1 , STN_LOC2, STN_LOC3 : out std_logic_vector (N_LOC_BITS downto 0) );
--end entity;
--
--
--architecture arch1 of ALLOCATE_BLK_RS_FPU is
--
--signal DONE1, DONE2, DONE3 : std_logic;
--signal START, CLK_PREV : std_logic;
--
--
--
--begin
--
--
--	process(CLK)
--	variable index : unsigned(1 downto 0) := "00";
--	variable v_stop : std_logic := '0';
--	variable v_avlbl_slot : t_arr3_slvLoc ;
--	variable v_nslots_reqd : unsigned(1 downto 0);
--	variable v_stn_loc1, v_stn_loc2, v_stn_loc3 : std_logic_vector(N_LOC_BITS downto 0);
--	begin
--		
--		if falling_edge(clk) then
--			v_stop := '0';
--			
--			if (D_SLOT_VALID = "000") then
--				v_nslots_reqd := "00";
--			elsif (D_SLOT_VALID = "001") or (D_SLOT_VALID = "010") or (D_SLOT_VALID = "100") then
--				v_nslots_reqd := "01";	
--			elsif (D_SLOT_VALID = "011") or (D_SLOT_VALID = "101") or (D_SLOT_VALID = "110") then
--				v_nslots_reqd := "10";	
--			else
--				v_nslots_reqd := "11";
--			end if;
--			
--			v_avlbl_slot := (others => (others => '0'));	
--			
--			index := "00";	
--			for i in 0 to N_ENTRIES_FPU_RS-1 loop
--					if (v_stop = '0') then
--						
--						-- Check RS Busy bit is 0
--						if ( TBL_BUSY_BITS(i) = '0') then
--								v_avlbl_slot(to_integer(index)) := '1' & std_logic_vector(to_unsigned(i, N_LOC_BITS));
--								index := index + to_unsigned(1,2);
--						end if;		
--						
--						if (index = "11") then v_stop := '1' ; end if ;
--					end if;	
--			end loop;
--				
--				if ( v_nslots_reqd = "11") then
--					v_stn_loc1 := v_avlbl_slot(0);
--					v_stn_loc2 := v_avlbl_slot(1);
--					v_stn_loc3 := v_avlbl_slot(2);
--				elsif ( v_nslots_reqd = "10") then
--					v_stn_loc1 := v_avlbl_slot(0);
--					v_stn_loc2 := v_avlbl_slot(1);
--					v_stn_loc3 := (others => '0');
--				elsif ( v_nslots_reqd = "01") then
--					v_stn_loc1 := v_avlbl_slot(0);
--					v_stn_loc2 := (others => '0');
--					v_stn_loc3 := (others => '0');
--				else
--					v_stn_loc1 := (others => '0');
--					v_stn_loc2 := (others => '0');
--					v_stn_loc3 := (others => '0');
--				end if;
--				
--				STN_LOC1 <= v_stn_loc1;
--				STN_LOC2 <= v_stn_loc2;
--				STN_LOC3 <= v_stn_loc3;
--			
--	end if ;
--end process;
--	
--
--end architecture;
--From Here		

>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		
use work.PACKAGE_DTYPES_RS_FPU.all;

entity ALLOCATE_BLK_RS_FPU is
port 	 ( CLK									: in std_logic;
			TBL_BUSY_BITS 						: in std_logic_vector(N_ENTRIES_FPU_RS - 1 downto 0) ;
			TEMP_ALLOC_BITS					: out std_logic_vector(3 downto 0);
			STN_LOC1 , STN_LOC2, STN_LOC3 : out std_logic_vector (N_LOC_BITS downto 0) );
end entity;


architecture arch1 of ALLOCATE_BLK_RS_FPU is

begin


	process(CLK)
	variable index : unsigned(1 downto 0) := "00";
	variable v_stop : std_logic := '0';
	variable v_avlbl_slot : t_arr3_slvLoc ;
	variable v_nslots_reqd : unsigned(1 downto 0);
	variable v_stn_loc1, v_stn_loc2, v_stn_loc3 : std_logic_vector(N_LOC_BITS downto 0);
	begin
		
		if falling_edge(clk) then
			v_stop := '0';
			
			v_avlbl_slot := (others => (others => '0'));	
			
			index := "00";	
			for i in 0 to N_ENTRIES_FPU_RS-1 loop
					if (v_stop = '0') then
						
						-- Check RS Busy bit is 0
						if ( TBL_BUSY_BITS(i) = '0') then
								v_avlbl_slot(to_integer(index)) := '1' & std_logic_vector(to_unsigned(i, N_LOC_BITS));
								index := index + to_unsigned(1,2);
						end if;		
						
						if (index = "11") then v_stop := '1' ; end if ;
					end if;	
			end loop;
				
			STN_LOC1 <= v_avlbl_slot(0);
			STN_LOC2 <= v_avlbl_slot(1);
			STN_LOC3 <= v_avlbl_slot(2);
			
	end if ;
end process;
	

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.PACKAGE_DTYPES_RS_FPU.all;

<<<<<<< HEAD
entity RESERVATION_STN is
port ( 
			CLK, RST   		: in std_logic;
			
			-- Dispatch Slots
			D_SLOT_VALID 	: in std_logic_vector(2 downto 0) ;
			DS1_INSTR, DS2_INSTR, DS3_INSTR : in std_logic_vector(N_OPCODE_BITS+N_SHAMT_BITS+N_FUNC_BITS-1 downto 0);
			
			DS1_OPR1, DS1_OPR2, DS2_OPR1, DS2_OPR2, DS3_OPR1, DS3_OPR2 	: in std_logic_vector(31 downto 0);
			DS1_OPR3, DS2_OPR3, DS3_OPR3 : in std_logic_vector(31 downto 0);
			
			DS1_OPR1_VAL, DS1_OPR2_VAL, DS2_OPR1_VAL, DS2_OPR2_VAL, DS3_OPR1_VAL, DS3_OPR2_VAL : in std_logic ;
			DS1_CTRL, DS2_CTRL, DS3_CTRL	: in std_logic_vector(N_CTRL_BITS-1 downto 0);
			DS1_DEST, DS2_DEST, DS3_DEST  : in std_logic_vector(N_LOG_RR-1 downto 0);
			DS1_ROB_LOC, DS2_ROB_LOC, DS3_ROB_LOC : in std_logic_vector(N_LOG_ROB-1 downto 0);
			DS1_SPEC_BrTAG_PRED, DS2_SPEC_BrTAG_PRED, DS3_SPEC_BrTAG_PRED	: in std_logic_vector(N_BR_BITS_FOR_RS-1 downto 0) ;
			
			-- Forwarding slots
=======
entity RESERVATION_STN_FPU is
port ( 
			CLK, RST   		: in std_logic;
			D_SLOT_VALID 	: in std_logic_vector(2 downto 0) ;
			DS1_OPR1, DS1_OPR2, DS2_OPR1, DS2_OPR2, DS3_OPR1, DS3_OPR2 	: in std_logic_vector(31 downto 0);
			DS1_OPR1_VAL, DS1_OPR2_VAL, DS2_OPR1_VAL, DS2_OPR2_VAL, DS3_OPR1_VAL, DS3_OPR2_VAL : in std_logic ;
			DS1_FUNC, DS2_FUNC, DS3_FUNC	: std_logic_vector(N_FUNC_BITS-1 downto 0);
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
			DATA_FWD_SLOT1, DATA_FWD_SLOT2, DATA_FWD_SLOT3, DATA_FWD_SLOT4 : in std_logic_vector(31 downto 0);  
			TAG_FWD_SLOT1, TAG_FWD_SLOT2, TAG_FWD_SLOT3, TAG_FWD_SLOT4 : in std_logic_vector(N_TAG_BITS-1 downto 0);  
			VAL_FWD_SLOTS : in std_logic_vector(3 downto 0);
			
<<<<<<< HEAD
			-- From ROB --
			I_ROB_FLUSH, I_ROB_SPEC : in std_logic_vector(127 downto 0);
			
			-- Outputs
			DREG_OPR1, DREG_OPR2, DREG_OPR3 : out std_logic_vector(31 downto 0);
			DREG_CTRL 				: out std_logic_vector(N_CTRL_BITS-1 downto 0); 	
			DREG_INSTR				: out std_logic_vector(N_OPCODE_BITS+N_SHAMT_BITS+N_FUNC_BITS-1 downto 0);
			DREG_DEST 			   : out std_logic_vector(N_LOG_RR-1 downto 0);
			DREG_ROB_LOC			: out std_logic_vector(N_LOG_ROB-1 downto 0);
			DREG_BR_FIELD			: out std_logic_vector(N_BR_BITS_FOR_RS-1 downto 0);
			
			RS_OUTPUT_VALID      : out std_logic;	
			
=======
			DREG_OPR1, DREG_OPR2 : out std_logic_vector(31 downto 0);
			DREG_FUNC 				: out std_logic_vector(N_FUNC_BITS-1 downto 0); 	

			RS_OUTPUT_VALID      : out std_logic;	
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
			-- TEMP OUTPUTS --
			TEMP_N_INSTR_IN_STN   : out std_logic_vector(N_LOC_BITS downto 0);
			TEMP_ALLOC_BITS : out std_logic_vector(3 downto 0); 
			TEMP_BUSY_BITS, TEMP_READY_BITS : out std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);
			TEMP_ISEQ3, TEMP_ISEQ2 , TEMP_ISEQ1, TEMP_ISEQ0 : out std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);
			TEMP_LOC1, TEMP_LOC2, TEMP_LOC3 : out std_logic_vector(N_LOC_BITS downto 0)

			);
end entity;


<<<<<<< HEAD
architecture arch1 of RESERVATION_STN is 

signal TBL_BUSY, TBL_READY : std_logic_vector(N_ENTRIES_FPU_RS - 1 downto 0) := (others => '0');
signal TBL_INSTR : t_arrN_slvInstr;
signal TBL_DEST : t_arrN_slvRr;
signal TBL_OPR1 : t_arrN_slv32 ;
signal TBL_OPR2 : t_arrN_slv32 ;
signal TBL_OPR3 : t_arrN_slv32 ;
signal TBL_CTRL : t_arrN_slvC ;
signal TBL_ROB_LOC : t_arrN_slvRob;
signal TBL_BR_FIELD : t_arrN_slvBranch ;

=======
architecture arch1 of RESERVATION_STN_FPU is 

signal TBL_BUSY, TBL_READY : std_logic_vector(N_ENTRIES_FPU_RS - 1 downto 0) := (others => '0');

signal TBL_OPR1 : t_arrN_slv32 ;
signal TBL_OPR2 : t_arrN_slv32 ;
signal TBL_FUNCTIONAL : t_arrN_slvC ;
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
signal TBL_O1VL, TBL_O2VL : std_logic_vector ( N_ENTRIES_FPU_RS -1 downto 0 ); 
signal TBL_ISEQ : t_arrN_slvN; 

type t_arrLoc_slv is array (0 to 2) of std_logic_vector(N_LOC_BITS downto 0);

signal RS_ALLOC_LOC, RS_FREE_LOC : t_arrLoc_slv;

signal VAL_FWD_ALL_SLOTS : std_logic_vector(3 downto 0);

signal OPR1_TO_COPY, OPR2_TO_COPY : t_arrN_slv32;
signal OPR1_VAL_COPY, OPR2_VAL_COPY : std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);

signal N_INSTR_IN_STN, N0, N1, N2, N3 : std_logic_vector(N_LOC_BITS downto 0) := (others => '0');
signal I1_SEQ, I2_SEQ, I3_SEQ : std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);

component ALLOCATE_BLK_RS_FPU is
port 	 ( CLK									: in std_logic;
			TBL_BUSY_BITS 						: in std_logic_vector(N_ENTRIES_FPU_RS - 1 downto 0) ;
			TEMP_ALLOC_BITS					: out std_logic_vector(3 downto 0);
			STN_LOC1 , STN_LOC2, STN_LOC3 : out std_logic_vector (N_LOC_BITS downto 0) );
end component;

component READ_FWD_DATA is	
	port    ( 
				 FWD_DATA_SLOT1, FWD_DATA_SLOT2, FWD_DATA_SLOT3, FWD_DATA_SLOT4 : in std_logic_vector(31 downto 0) ;
				 FWD_TAG_SLOT1 , FWD_TAG_SLOT2 , FWD_TAG_SLOT3 , FWD_TAG_SLOT4  : in std_logic_vector(N_TAG_BITS -1 downto 0);
				 VAL_FWD_ALL_SLOTS  : in std_logic_vector(3 downto 0);
				 TBL_OPR1, TBL_OPR2 : in t_arrN_slv32 ;	
				 TBL_O1VL, TBL_O2VL : in std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);  
				 OPR1_TO_COPY, OPR2_TO_COPY : out t_arrN_slv32;
				 OPR1_VAL_COPY, OPR2_VAL_COPY : out std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0) ) ;
end component;	

signal DREG_OPR1_NEXT, DREG_OPR2_NEXT : std_logic_vector(31 downto 0);
<<<<<<< HEAD
signal DREG_CTRL_NEXT 				: std_logic_vector(N_CTRL_BITS-1 downto 0) ;

	
=======
signal DREG_FUNC_NEXT 				: std_logic_vector(N_FUNC_BITS-1 downto 0) ;	
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0

 function FUNC_GET_SEQ ( N_INSTR : in UNSIGNED )
    return std_logic_vector is
    variable v_ISEQ : std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);
	 variable iLength : integer;
 begin
	
	
		for i in 0 to (N_ENTRIES_FPU_RS - 1) loop
			if (i = to_integer(N_INSTR)) then
				v_ISEQ(i) := '1';
			else
				v_ISEQ(i) := '0';
			end if;	
		end loop;

	  return v_ISEQ;
 end;

component ENCODER8x3 is 
port 
	( 
		INPUT  : in std_logic_vector(7 downto 0) ;
		OUTPUT : out std_logic_vector(2 downto 0) ;
		VALID  : out std_logic );
end component;
 
component ENCODER4x2 is 
port 
	( 
		INPUT  : in std_logic_vector(3 downto 0) ;
		OUTPUT : out std_logic_vector(1 downto 0) ;
		VALID  : out std_logic );
end component;

component MUX4x1 is 
	port ( 
				DATA1, DATA2, DATA3, DATA4 : in std_logic_vector(31 downto 0);
				SEL : in std_logic_vector(1 downto 0);
				OUTPUT : out std_logic_vector(31 downto 0) );
end component;	

component MUX8x1 is 
	port ( 
				DATA1, DATA2, DATA3, DATA4 : in std_logic_vector(N_LOC_BITS-1 downto 0);
				DATA5, DATA6, DATA7, DATA8 : in std_logic_vector(N_LOC_BITS-1 downto 0);
				SEL : in std_logic_vector(2 downto 0);
				OUTPUT : out std_logic_vector(N_LOC_BITS-1 downto 0) );
end component;	
 
signal OPR1_LOAD_EN, OPR2_LOAD_EN, OPR1_VAL_NEXT, OPR2_VAL_NEXT, TBL_READY_NEXT : std_logic_vector(N_ENTRIES_FPU_RS - 1 downto 0);
signal DS1_TAG1_MATCH, DS1_TAG2_MATCH : std_logic_vector(3 downto 0);
signal DS2_TAG1_MATCH, DS2_TAG2_MATCH : std_logic_vector(3 downto 0);
signal DS3_TAG1_MATCH, DS3_TAG2_MATCH : std_logic_vector(3 downto 0);

type t_arrFwd_slvTag is array(3 downto 0) of std_logic_vector(N_TAG_BITS - 1 downto 0);
signal TAG_ALL_FWD_SLOTS : t_arrFwd_slvTag;

signal LOC_MATCH_DS1_OPR1, LOC_MATCH_DS1_OPR2 : std_logic_vector (1 downto 0);
signal LOC_MATCH_DS2_OPR1, LOC_MATCH_DS2_OPR2 : std_logic_vector (1 downto 0);
signal LOC_MATCH_DS3_OPR1, LOC_MATCH_DS3_OPR2 : std_logic_vector (1 downto 0);
signal DS1_OPR1_FWD, DS1_OPR2_FWD : std_logic_vector(31 downto 0);
signal DS2_OPR1_FWD, DS2_OPR2_FWD : std_logic_vector(31 downto 0);
signal DS3_OPR1_FWD, DS3_OPR2_FWD : std_logic_vector(31 downto 0);
signal DS1_OPR1_NEXT, DS1_OPR2_NEXT, DS2_OPR1_NEXT, DS2_OPR2_NEXT, DS3_OPR1_NEXT, DS3_OPR2_NEXT : std_logic_vector(31 downto 0);
signal VAL_FWD_DS1_OPR1, VAL_FWD_DS1_OPR2, VAL_FWD_DS2_OPR1, VAL_FWD_DS2_OPR2, VAL_FWD_DS3_OPR1, VAL_FWD_DS3_OPR2 : std_logic;
 
signal DS1_OPR1_VAL_NEXT, DS1_OPR2_VAL_NEXT : std_logic ;
signal DS2_OPR1_VAL_NEXT, DS2_OPR2_VAL_NEXT : std_logic ;
signal DS3_OPR1_VAL_NEXT, DS3_OPR2_VAL_NEXT : std_logic ;

signal DS1_INSTR_RDY_NEXT, DS2_INSTR_RDY_NEXT, DS3_INSTR_RDY_NEXT : std_logic ;
signal ISEQ_NEW_SEL1, ISEQ_NEW_SEL2, ISEQ_NEW_SEL3 : std_logic_vector( N_LOC_BITS-1 downto 0 );

signal IS_READY_AT_CLK , TBL_LOC_B0_VAL , INP_ENC_LEVEL2: std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0) ;
signal INP_ENC_LEVEL1 : t_arrN_slvN ;

type t_arrN_slvLoc is array(0 to N_ENTRIES_FPU_RS-1) of std_logic_vector(N_LOC_BITS-1 downto 0);
signal TBL_LOC_ALL_BITS : t_arrN_slvLoc;

signal LSB_BIT_NO : std_logic_vector(N_LOC_BITS-1 downto 0);
signal LSB_BIT_VALID : std_logic;
signal ROW_NEXT : std_logic_vector(N_LOC_BITS-1 downto 0);
signal INSTR_NEXT_ROW_FROM_TBL , INSTR_NEXT_ROW : std_logic_vector(N_LOC_BITS downto 0);
signal INSTR_RDY_DS1, INSTR_RDY_DS2, INSTR_RDY_DS3 : std_logic ;
<<<<<<< HEAD
signal INSTR_CTRL_NEXT : std_logic_vector( N_CTRL_BITS-1 downto 0 );
=======
signal INSTR_FUNC_NEXT : std_logic_vector( N_FUNC_BITS-1 downto 0 );
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
signal OPR1_NEXT, OPR2_NEXT : t_arrN_slv32 ;
signal INSTR_OPR1_NEXT, INSTR_OPR2_NEXT : std_logic_vector(31 downto 0);

signal INST_VALID : std_logic;
signal I1_SEQ_SHIFTED, I2_SEQ_SHIFTED, I3_SEQ_SHIFTED : std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);
signal RESET_EN, SHIFT_EN : std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);
signal TBL_ISEQ_SHIFTED, ISEQ_NEXT : t_arrN_slvN ;	
signal SHIFT_EN_I1, SHIFT_EN_I2, SHIFT_EN_I3 : std_logic;
signal I1_SEQ_NEXT, I2_SEQ_NEXT, I3_SEQ_NEXT : std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);
<<<<<<< HEAD
signal INSTR_DEST_NEXT : std_logic_vector(N_LOG_RR-1 downto 0);
signal INSTR_NEXT : std_logic_vector(N_OPCODE_BITS+N_SHAMT_BITS+N_FUNC_BITS-1 downto 0);

signal INSTR_ROB_LOC_NEXT : std_logic_vector(N_LOG_ROB-1 downto 0);
signal INSTR_BR_FIELD_NEXT   : std_logic_vector(N_BR_BITS_FOR_RS-1 downto 0) ;
signal INSTR_OPR3_NEXT : std_logic_vector(31 downto 0);
signal TBL_FLUSH_NEXT, TBL_ISPEC_NEXT : std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);
=======
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0

begin

	-- ALLOCATE UNIT : ALLOCATE 3 FREE LOCATIONS OF RESERVATION STATION --
	ALLOCATE_UNIT: ALLOCATE_BLK_RS_FPU port map    ( 	CLK => CLK, TBL_BUSY_BITS => TBL_BUSY,
																		STN_LOC1 => RS_FREE_LOC(0) , STN_LOC2 => RS_FREE_LOC(1), STN_LOC3 => RS_FREE_LOC(2) );
	
	-- ASSIGN LOCATION TO INSTRUCTION --

	RS_ALLOC_LOC(0) <= RS_FREE_LOC(0) when ( RS_FREE_LOC(0)(N_LOC_BITS) = '1' and D_SLOT_VALID(0) = '1') else 
							 (others => '0');
	
	RS_ALLOC_LOC(1) <= RS_FREE_LOC(0) when ( RS_FREE_LOC(0)(N_LOC_BITS) = '1' and D_SLOT_VALID(0) = '0' and D_SLOT_VALID(1) = '1' ) else
							 RS_FREE_LOC(1) when ( RS_FREE_LOC(1)(N_LOC_BITS) = '1' and D_SLOT_VALID(1) = '1') else 
							 (others => '0');
		
	RS_ALLOC_LOC(2) <= RS_FREE_LOC(0) when ( RS_FREE_LOC(0)(N_LOC_BITS) = '1' and D_SLOT_VALID(0) = '0' and D_SLOT_VALID(2) = '1') else
							 RS_FREE_LOC(1) when ( RS_FREE_LOC(1)(N_LOC_BITS) = '1' and D_SLOT_VALID(1) = '0' and D_SLOT_VALID(2) = '1') else 
							 RS_FREE_LOC(2) when ( RS_FREE_LOC(2)(N_LOC_BITS) = '1' and D_SLOT_VALID(2) = '1') else 
							 (others => '0');

	
	-- TEMPORARY OUTPUTS --
	TEMP_LOC1 <= RS_ALLOC_LOC(0);
	TEMP_LOC2 <= RS_ALLOC_LOC(1);
	--TEMP_LOC3 <= RS_ALLOC_LOC(2);
	TEMP_LOC3 <= INSTR_NEXT_ROW	;	
	
	VAL_FWD_ALL_SLOTS  <= VAL_FWD_SLOTS;
	
	DATA_FWD : READ_FWD_DATA port map    ( 	FWD_DATA_SLOT1 => DATA_FWD_SLOT1, 
															FWD_DATA_SLOT2 => DATA_FWD_SLOT2,
															FWD_DATA_SLOT3 => DATA_FWD_SLOT3,
															FWD_DATA_SLOT4 => DATA_FWD_SLOT4,
															
															FWD_TAG_SLOT1 => TAG_FWD_SLOT1,
															FWD_TAG_SLOT2 => TAG_FWD_SLOT2,
															FWD_TAG_SLOT3 => TAG_FWD_SLOT3,
															FWD_TAG_SLOT4 => TAG_FWD_SLOT4,
															
															VAL_FWD_ALL_SLOTS  => 	VAL_FWD_ALL_SLOTS, 
															TBL_OPR1 => TBL_OPR1, TBL_OPR2 => TBL_OPR2,
															TBL_O1VL	=> TBL_O1VL, TBL_O2VL => TBL_O2VL,
															OPR1_TO_COPY => OPR1_TO_COPY, OPR1_VAL_COPY => OPR1_VAL_COPY,
														   OPR2_TO_COPY => OPR2_TO_COPY, OPR2_VAL_COPY => OPR2_VAL_COPY	
														) ;
														
	-- SET LOAD ENABLE TO FORWARDED DATA --
	g3: for i in 0 to (N_ENTRIES_FPU_RS - 1) generate
	
		OPR1_LOAD_EN(i) <= '1' when ( OPR1_VAL_COPY(i) = '1' and TBL_BUSY(i) = '1' ) else '0' ;
		OPR2_LOAD_EN(i) <= '1' when ( OPR2_VAL_COPY(i) = '1' and TBL_BUSY(i) = '1' ) else '0' ;
		
		OPR1_VAL_NEXT(i) <= '1' when OPR1_LOAD_EN(i) = '1' else TBL_O1VL(i) ;
		OPR2_VAL_NEXT(i) <= '1' when OPR2_LOAD_EN(i) = '1' else TBL_O2VL(i) ;
		
		OPR1_NEXT(i) 	<= OPR1_TO_COPY(i) when OPR1_LOAD_EN(i) = '1' else TBL_OPR1(i) ;
		OPR2_NEXT(i) 	<= OPR2_TO_COPY(i) when OPR2_LOAD_EN(i) = '1' else TBL_OPR2(i) ;
		
		TBL_READY_NEXT(i) <= OPR1_VAL_NEXT(i) and OPR2_VAL_NEXT(i) ;
		
	end generate ;	
	
	
	TAG_ALL_FWD_SLOTS(3) <= TAG_FWD_SLOT4 ;
	TAG_ALL_FWD_SLOTS(2) <= TAG_FWD_SLOT3 ;
	TAG_ALL_FWD_SLOTS(1) <= TAG_FWD_SLOT2 ; 
	TAG_ALL_FWD_SLOTS(0) <= TAG_FWD_SLOT1 ;
	
	g5: for j in 0 to 3 generate	-- For each forwarding slot
			
		DS1_TAG1_MATCH(j) <= '1' when ( 	  D_SLOT_VALID(0) = '1' and 
													  DS1_OPR1_VAL = '0' and VAL_FWD_SLOTS(j) = '1' and 
													  TAG_ALL_FWD_SLOTS(j) = DS1_OPR1(N_TAG_BITS-1 downto 0)) 
										else '0';
			
		DS1_TAG2_MATCH(j) <= '1' when ( 	  D_SLOT_VALID(0) = '1' and 
													  DS1_OPR2_VAL = '0' and VAL_FWD_SLOTS(j) = '1' and 
													  TAG_ALL_FWD_SLOTS(j) = DS1_OPR2(N_TAG_BITS-1 downto 0)) 
										else '0';

		DS2_TAG1_MATCH(j) <= '1' when ( 	  D_SLOT_VALID(1) = '1' and 
													  DS2_OPR1_VAL = '0' and VAL_FWD_SLOTS(j) = '1' and 
													  TAG_ALL_FWD_SLOTS(j) = DS2_OPR1(N_TAG_BITS-1 downto 0)) 
										else '0';
			
		DS2_TAG2_MATCH(j) <= '1' when ( 	  D_SLOT_VALID(1) = '1' and 
													  DS2_OPR2_VAL = '0' and VAL_FWD_SLOTS(j) = '1' and 
													  TAG_ALL_FWD_SLOTS(j) = DS2_OPR2(N_TAG_BITS-1 downto 0)) 
										else '0';

		DS3_TAG1_MATCH(j) <= '1' when ( 	  D_SLOT_VALID(2) = '1' and 
													  DS3_OPR1_VAL = '0' and VAL_FWD_SLOTS(j) = '1' and 
													  TAG_ALL_FWD_SLOTS(j) = DS3_OPR1(N_TAG_BITS-1 downto 0)) 
										else '0';
			
		DS3_TAG2_MATCH(j) <= '1' when ( 	  D_SLOT_VALID(2) = '1' and 
													  DS3_OPR2_VAL = '0' and VAL_FWD_SLOTS(j) = '1' and 
													  TAG_ALL_FWD_SLOTS(j) = DS3_OPR2(N_TAG_BITS-1 downto 0)) 
										else '0';
										
	end generate;
	
	ENCODER1 : ENCODER4x2 port map ( INPUT => DS1_TAG1_MATCH, OUTPUT => LOC_MATCH_DS1_OPR1, VALID => VAL_FWD_DS1_OPR1 );
	ENCODER2 : ENCODER4x2 port map ( INPUT => DS1_TAG2_MATCH, OUTPUT => LOC_MATCH_DS1_OPR2, VALID => VAL_FWD_DS1_OPR2 );
	ENCODER3 : ENCODER4x2 port map ( INPUT => DS2_TAG1_MATCH, OUTPUT => LOC_MATCH_DS2_OPR1, VALID => VAL_FWD_DS2_OPR1 );
	ENCODER4 : ENCODER4x2 port map ( INPUT => DS2_TAG2_MATCH, OUTPUT => LOC_MATCH_DS2_OPR2, VALID => VAL_FWD_DS2_OPR2 );
	ENCODER5 : ENCODER4x2 port map ( INPUT => DS3_TAG1_MATCH, OUTPUT => LOC_MATCH_DS3_OPR1, VALID => VAL_FWD_DS3_OPR1 );
	ENCODER6 : ENCODER4x2 port map ( INPUT => DS3_TAG2_MATCH, OUTPUT => LOC_MATCH_DS3_OPR2, VALID => VAL_FWD_DS3_OPR2 );
	
	MUX1 : MUX4x1 port map ( DATA1 => DATA_FWD_SLOT1 , DATA2 => DATA_FWD_SLOT2, DATA3 => DATA_FWD_SLOT3, DATA4 => DATA_FWD_SLOT4, 
									 SEL => LOC_MATCH_DS1_OPR1, OUTPUT => DS1_OPR1_FWD );
	MUX2 : MUX4x1 port map ( DATA1 => DATA_FWD_SLOT1 , DATA2 => DATA_FWD_SLOT2, DATA3 => DATA_FWD_SLOT3, DATA4 => DATA_FWD_SLOT4, 
									 SEL => LOC_MATCH_DS1_OPR2, OUTPUT => DS1_OPR2_FWD );
	MUX3 : MUX4x1 port map ( DATA1 => DATA_FWD_SLOT1 , DATA2 => DATA_FWD_SLOT2, DATA3 => DATA_FWD_SLOT3, DATA4 => DATA_FWD_SLOT4, 
									 SEL => LOC_MATCH_DS2_OPR1, OUTPUT => DS2_OPR1_FWD );
	MUX4 : MUX4x1 port map ( DATA1 => DATA_FWD_SLOT1 , DATA2 => DATA_FWD_SLOT2, DATA3 => DATA_FWD_SLOT3, DATA4 => DATA_FWD_SLOT4, 
									 SEL => LOC_MATCH_DS2_OPR2, OUTPUT => DS2_OPR2_FWD );
	MUX5 : MUX4x1 port map ( DATA1 => DATA_FWD_SLOT1 , DATA2 => DATA_FWD_SLOT2, DATA3 => DATA_FWD_SLOT3, DATA4 => DATA_FWD_SLOT4, 
									 SEL => LOC_MATCH_DS3_OPR1, OUTPUT => DS3_OPR1_FWD );
	MUX6 : MUX4x1 port map ( DATA1 => DATA_FWD_SLOT1 , DATA2 => DATA_FWD_SLOT2, DATA3 => DATA_FWD_SLOT3, DATA4 => DATA_FWD_SLOT4, 
									 SEL => LOC_MATCH_DS3_OPR2, OUTPUT => DS3_OPR2_FWD );
	
	DS1_OPR1_NEXT <= 	DS1_OPR1_FWD when VAL_FWD_DS1_OPR1 = '1' else DS1_OPR1 ;
	DS1_OPR2_NEXT <= 	DS1_OPR2_FWD when VAL_FWD_DS1_OPR2 = '1' else DS1_OPR2 ;

	DS2_OPR1_NEXT <= 	DS2_OPR1_FWD when VAL_FWD_DS2_OPR1 = '1' else DS2_OPR1 ;
	DS2_OPR2_NEXT <= 	DS2_OPR2_FWD when VAL_FWD_DS2_OPR2 = '1' else DS2_OPR2 ;

	DS3_OPR1_NEXT <= 	DS3_OPR1_FWD when VAL_FWD_DS3_OPR1 = '1' else DS3_OPR1 ;
	DS3_OPR2_NEXT <= 	DS3_OPR2_FWD when VAL_FWD_DS3_OPR2 = '1' else DS3_OPR2 ;
	
	DS1_OPR1_VAL_NEXT  <= '1' when VAL_FWD_DS1_OPR1 = '1' else DS1_OPR1_VAL ;
	DS1_OPR2_VAL_NEXT  <= '1' when VAL_FWD_DS1_OPR2 = '1' else DS1_OPR2_VAL ;
	
	DS2_OPR1_VAL_NEXT  <= '1' when VAL_FWD_DS2_OPR1 = '1' else DS2_OPR1_VAL ;
	DS2_OPR2_VAL_NEXT  <= '1' when VAL_FWD_DS2_OPR2 = '1' else DS2_OPR2_VAL ;
	
	DS3_OPR1_VAL_NEXT  <= '1' when VAL_FWD_DS3_OPR1 = '1' else DS3_OPR1_VAL ;
	DS3_OPR2_VAL_NEXT  <= '1' when VAL_FWD_DS3_OPR2 = '1' else DS3_OPR2_VAL ;

<<<<<<< HEAD
	DS1_INSTR_RDY_NEXT <= DS1_OPR1_VAL_NEXT and DS1_OPR2_VAL_NEXT and RS_ALLOC_LOC(0)(N_LOC_BITS);
	DS2_INSTR_RDY_NEXT <= DS2_OPR1_VAL_NEXT and DS2_OPR2_VAL_NEXT and RS_ALLOC_LOC(1)(N_LOC_BITS);
	DS3_INSTR_RDY_NEXT <= DS3_OPR1_VAL_NEXT and DS3_OPR2_VAL_NEXT and RS_ALLOC_LOC(2)(N_LOC_BITS);
=======
	DS1_INSTR_RDY_NEXT <= DS1_OPR1_VAL_NEXT and DS1_OPR2_VAL_NEXT ;
	DS2_INSTR_RDY_NEXT <= DS2_OPR1_VAL_NEXT and DS2_OPR2_VAL_NEXT ;
	DS3_INSTR_RDY_NEXT <= DS3_OPR1_VAL_NEXT and DS3_OPR2_VAL_NEXT ;
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
	
	-- Instruction Sequence generation --
	N0 <= N_INSTR_IN_STN ;
	
	N1 <= std_logic_vector( unsigned(N0) + unsigned( std_logic_vector(to_unsigned(0,N_LOC_BITS)) & RS_ALLOC_LOC(0)(N_LOC_BITS)) );
	
	N2 <= std_logic_vector( unsigned(N1) + unsigned( std_logic_vector(to_unsigned(0,N_LOC_BITS)) & RS_ALLOC_LOC(1)(N_LOC_BITS)) );
	
	N3 <= std_logic_vector( unsigned(N2) + unsigned( std_logic_vector(to_unsigned(0,N_LOC_BITS)) & RS_ALLOC_LOC(2)(N_LOC_BITS)) );
	
	ISEQ_NEW_SEL1 <= N0( N_LOC_BITS-1 downto 0 ) ;
	ISEQ_NEW_SEL2 <= N1( N_LOC_BITS-1 downto 0 ) ;
	ISEQ_NEW_SEL3 <= N2( N_LOC_BITS-1 downto 0 ) ;
	
	g20: for i in 0 to N_ENTRIES_FPU_RS - 1 generate 
		I1_SEQ(i) <= 		  '0' when ( N0(N_LOC_BITS) ='1' or RS_ALLOC_LOC(0)(N_LOC_BITS) = '0' )
							else '1' when i = to_integer(unsigned(ISEQ_NEW_SEL1)) 
							else '0' ;
							
		I2_SEQ(i) <= 		  '0' when ( N1(N_LOC_BITS) ='1' or RS_ALLOC_LOC(1)(N_LOC_BITS) = '0' )
							else '1' when i = to_integer(unsigned(ISEQ_NEW_SEL2)) 
							else '0' ;
							
		I3_SEQ(i) <= 		  '0' when ( N2(N_LOC_BITS) ='1' or RS_ALLOC_LOC(2)(N_LOC_BITS) = '0' )
							else '1' when i = to_integer(unsigned(ISEQ_NEW_SEL3)) 
							else '0' ;

	end generate ;
	
	-- DISPATCH SELECTION --
	g40: for j in 0 to N_ENTRIES_FPU_RS-1 generate
<<<<<<< HEAD
		IS_READY_AT_CLK(j) <= '1' when ( (TBL_READY(j) = '1' or TBL_READY_NEXT(j) = '1') and TBL_BUSY(j) = '1' 
													and TBL_BR_FIELD(j)(9) = '0' and TBL_FLUSH_NEXT(j) = '0' ) else '0' ;
=======
		IS_READY_AT_CLK(j) <= '1' when (TBL_READY(j) = '1' or TBL_READY_NEXT(j) = '1') else '0' ;
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
	end generate;
	
	-- 8 LEVEL 1 ENCODERS : Selects the location of ready instruction for each bit of Instruction Sequnece
	g41 : for i in 0 to N_ENTRIES_FPU_RS-1 generate		-- over bits of ISEQ
		g42 : for j in 0 to N_ENTRIES_FPU_RS-1 generate	-- Over all rows of reservation table

			INP_ENC_LEVEL1(i)(j) <= '1' when ( TBL_ISEQ(j)(i) = '1' and IS_READY_AT_CLK(j) = '1' ) else '0' ;

		end generate ;
			
		ENC_LOGIC : ENCODER8x3 port map ( INPUT => INP_ENC_LEVEL1(i), OUTPUT => TBL_LOC_ALL_BITS(i) , VALID => TBL_LOC_B0_VAL(i) );
		
	end generate;

<<<<<<< HEAD
	
=======
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
	-- 1 LEVEL 2 ENCODER : Selects the least significant bit which is 1

		INP_ENC_LEVEL2 <= TBL_LOC_B0_VAL ; 
		
		ENC_2 : ENCODER8x3 port map ( INPUT => INP_ENC_LEVEL2, OUTPUT => LSB_BIT_NO , VALID => LSB_BIT_VALID );
		
--		TEMP_ISEQ0 <= "0000" & INSTR_NEXT_ROW_FROM_TBL;
--		TEMP_ISEQ1 <= "0000" & INSTR_NEXT_ROW;
--		TEMP_ISEQ2 <= OPR1_NEXT(1)(7 downto 0);
--		TEMP_ISEQ3 <= OPR2_NEXT(2)(7 downto 0);
<<<<<<< HEAD
=======

	
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
	INSTR_NEXT_ROW_FROM_TBL <= '1' & TBL_LOC_ALL_BITS(to_integer(unsigned(LSB_BIT_NO))) when LSB_BIT_VALID = '1' else
										(others => '0');
	
	INSTR_RDY_DS1 <= '1' when (DS1_INSTR_RDY_NEXT = '1' and LSB_BIT_VALID = '0') else '0' ;
	INSTR_RDY_DS2 <= '1' when (DS2_INSTR_RDY_NEXT = '1' and LSB_BIT_VALID = '0') else '0' ;
	INSTR_RDY_DS3 <= '1' when (DS3_INSTR_RDY_NEXT = '1' and LSB_BIT_VALID = '0') else '0' ;
	
<<<<<<< HEAD
	INSTR_NEXT_ROW <= INSTR_NEXT_ROW_FROM_TBL when ( LSB_BIT_VALID = '1' ) else
--							RS_ALLOC_LOC(0) when ( INSTR_RDY_DS1 = '1' and  DS1_SPEC_BrTAG_PRED(9) = '0') else
--							RS_ALLOC_LOC(1) when ( INSTR_RDY_DS2 = '1' and  DS2_SPEC_BrTAG_PRED(9) = '0') else
--							RS_ALLOC_LOC(2) when ( INSTR_RDY_DS3 = '1' and  DS3_SPEC_BrTAG_PRED(9) = '0') else
							(others => '0') ;
							
	INSTR_NEXT 		<= TBL_INSTR(to_integer(unsigned(INSTR_NEXT_ROW_FROM_TBL(N_LOC_BITS -1 downto 0)))) when (LSB_BIT_VALID = '1') else
							DS1_INSTR when INSTR_RDY_DS1 = '1' else
							DS2_INSTR when INSTR_RDY_DS2 = '1' else
							DS3_INSTR when INSTR_RDY_DS3 = '1' else
							(others => '0') ;
							
	INSTR_DEST_NEXT 	<= TBL_DEST(to_integer(unsigned(INSTR_NEXT_ROW_FROM_TBL(N_LOC_BITS -1 downto 0)))) when (LSB_BIT_VALID = '1') else
								DS1_DEST when INSTR_RDY_DS1 = '1' else
								DS2_DEST when INSTR_RDY_DS2 = '1' else
								DS3_DEST when INSTR_RDY_DS3 = '1' else
								(others => '0') ;
							
							
	INSTR_CTRL_NEXT <= TBL_CTRL(to_integer(unsigned(INSTR_NEXT_ROW_FROM_TBL(N_LOC_BITS -1 downto 0)))) when (LSB_BIT_VALID = '1') else
							 DS1_CTRL when INSTR_RDY_DS1 = '1' else
							 DS2_CTRL when INSTR_RDY_DS2 = '1' else
							 DS3_CTRL when INSTR_RDY_DS3 = '1' else
							 (others => '0') ;
							 
	INSTR_OPR1_NEXT <= OPR1_NEXT(to_integer(unsigned(INSTR_NEXT_ROW_FROM_TBL(N_LOC_BITS -1 downto 0)))) when (LSB_BIT_VALID = '1') else
							 DS1_OPR1_NEXT when INSTR_RDY_DS1 = '1' else
							 DS2_OPR1_NEXT when INSTR_RDY_DS2 = '1' else
							 DS3_OPR1_NEXT when INSTR_RDY_DS3 = '1' else
							 (others => '0') ;
							 
	INSTR_OPR2_NEXT <= OPR2_NEXT(to_integer(unsigned(INSTR_NEXT_ROW_FROM_TBL(N_LOC_BITS -1 downto 0)))) when (LSB_BIT_VALID = '1') else
							 DS1_OPR2_NEXT when INSTR_RDY_DS1 = '1' else
							 DS2_OPR2_NEXT when INSTR_RDY_DS2 = '1' else
							 DS3_OPR2_NEXT when INSTR_RDY_DS3 = '1' else
							 (others => '0') ;
	
	INSTR_OPR3_NEXT <= TBL_OPR3(to_integer(unsigned(INSTR_NEXT_ROW_FROM_TBL(N_LOC_BITS -1 downto 0)))) when (LSB_BIT_VALID = '1') else
							 DS1_OPR3 when INSTR_RDY_DS1 = '1' else
							 DS2_OPR3 when INSTR_RDY_DS2 = '1' else
							 DS3_OPR3 when INSTR_RDY_DS3 = '1' else
							 (others => '0') ;
	
	INSTR_ROB_LOC_NEXT <= 	TBL_ROB_LOC(to_integer(unsigned(INSTR_NEXT_ROW_FROM_TBL(N_LOC_BITS -1 downto 0)))) when (LSB_BIT_VALID = '1') else
									DS1_ROB_LOC when INSTR_RDY_DS1 = '1' else
									DS2_ROB_LOC when INSTR_RDY_DS2 = '1' else
									DS3_ROB_LOC when INSTR_RDY_DS3 = '1' else
									(others => '0') ;
									
	INSTR_BR_FIELD_NEXT 	 <= 	TBL_BR_FIELD(to_integer(unsigned(INSTR_NEXT_ROW_FROM_TBL(N_LOC_BITS -1 downto 0)))) when (LSB_BIT_VALID = '1') else
										DS1_SPEC_BrTAG_PRED when INSTR_RDY_DS1 = '1' else
										DS2_SPEC_BrTAG_PRED when INSTR_RDY_DS2 = '1' else
										DS3_SPEC_BrTAG_PRED when INSTR_RDY_DS3 = '1' else
										(others=>'0') ;
	
	-- END OF DISPATCH SELECTION --	

	-- RS FLUSH BASED ON SPECULATION --
	g60: for j in 0 to N_ENTRIES_FPU_RS-1 generate
		TBL_FLUSH_NEXT(j) <= '1' when ( I_ROB_FLUSH(to_integer(unsigned(TBL_ROB_LOC(j)))) = '1' and TBL_BUSY(j) = '1' ) else '0' ;
	end generate;

	-- RS MAKE NON SPECULATIVE --
	g61: for j in 0 to N_ENTRIES_FPU_RS-1 generate
		TBL_ISPEC_NEXT(j) <= '0' when ( I_ROB_FLUSH(to_integer(unsigned(TBL_ROB_LOC(j)))) = '0'  and 
												  I_ROB_SPEC(to_integer(unsigned(TBL_ROB_LOC(j)))) = '0' and 
												  TBL_BUSY(j) = '1' ) else TBL_BR_FIELD(j)(9) ;
	end generate;
	
	
=======
	INSTR_NEXT_ROW <= INSTR_NEXT_ROW_FROM_TBL when LSB_BIT_VALID = '1' else
							RS_ALLOC_LOC(0) when INSTR_RDY_DS1 = '1' else
							RS_ALLOC_LOC(1) when INSTR_RDY_DS2 = '1' else
							RS_ALLOC_LOC(2) when INSTR_RDY_DS3 = '1' else
							(others => '0') ;
							
	INSTR_FUNC_NEXT <= TBL_FUNCTIONAL(to_integer(unsigned(INSTR_NEXT_ROW_FROM_TBL(N_LOC_BITS -1 downto 0)))) when (LSB_BIT_VALID = '1') else
							 DS1_FUNC when RS_ALLOC_LOC(0)(N_LOC_BITS) = '1' else
							 DS2_FUNC when RS_ALLOC_LOC(1)(N_LOC_BITS) = '1' else
							 DS3_FUNC when RS_ALLOC_LOC(2)(N_LOC_BITS) = '1' else
							 (others => '0') ;
							 
	INSTR_OPR1_NEXT <= OPR1_NEXT(to_integer(unsigned(INSTR_NEXT_ROW_FROM_TBL(N_LOC_BITS -1 downto 0)))) when (LSB_BIT_VALID = '1') else
							 DS1_OPR1_NEXT when DS1_INSTR_RDY_NEXT = '1' else
							 DS2_OPR1_NEXT when DS2_INSTR_RDY_NEXT = '1' else
							 DS3_OPR1_NEXT when DS3_INSTR_RDY_NEXT = '1' else
							 (others => '0') ;
							 
	INSTR_OPR2_NEXT <= OPR2_NEXT(to_integer(unsigned(INSTR_NEXT_ROW_FROM_TBL(N_LOC_BITS -1 downto 0)))) when (LSB_BIT_VALID = '1') else
							 DS1_OPR2_NEXT when DS1_INSTR_RDY_NEXT = '1' else
							 DS2_OPR2_NEXT when DS2_INSTR_RDY_NEXT = '1' else
							 DS3_OPR2_NEXT when DS3_INSTR_RDY_NEXT = '1' else
							 (others => '0') ;
							 

	-- END OF DISPATCH SELECTION --	

>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
	-- SHIFTING INSTRUCTION SEQUENCE FOR NEXT CYCLE --
	INST_VALID <=	INSTR_NEXT_ROW(N_LOC_BITS) ;
	
	SHIFT_EN_I1 <= '1' when (INST_VALID = '1' and I1_SEQ(0) /= '1') else '0' ;
	SHIFT_EN_I2 <= '1' when (INST_VALID = '1' and I2_SEQ(0) /= '1') else '0' ;
	SHIFT_EN_I3 <= '1' when (INST_VALID = '1' and I3_SEQ(0) /= '1') else '0' ;
	
	I1_SEQ_SHIFTED  <= '0' & I1_SEQ(N_ENTRIES_FPU_RS-1 downto 1) ;
	I2_SEQ_SHIFTED  <= '0' & I2_SEQ(N_ENTRIES_FPU_RS-1 downto 1) ;
	I3_SEQ_SHIFTED  <= '0' & I3_SEQ(N_ENTRIES_FPU_RS-1 downto 1) ;
	
	I1_SEQ_NEXT <= I1_SEQ_SHIFTED when SHIFT_EN_I1 = '1' else I1_SEQ ;
	I2_SEQ_NEXT <= I2_SEQ_SHIFTED when SHIFT_EN_I2 = '1' else I2_SEQ ;
	I3_SEQ_NEXT <= I3_SEQ_SHIFTED when SHIFT_EN_I3 = '1' else I3_SEQ ;

--	I1_SEQ_NEXT <= I1_SEQ ;
--	I2_SEQ_NEXT <= I2_SEQ ;
--	I3_SEQ_NEXT <= I3_SEQ ;

	
	g50: for i in 0 to N_ENTRIES_FPU_RS - 1 generate		-- Over all rows of reservation table

			SHIFT_EN(i) <= '1' when ( TBL_BUSY(i) = '1' and INST_VALID = '1' and TBL_ISEQ(i)(0) /= '1' and LSB_BIT_VALID = '1') else '0' ;
			RESET_EN(i) <= '1' when ( INST_VALID = '1' and i = to_integer(unsigned(INSTR_NEXT_ROW(N_LOC_BITS-1 downto 0))) ) else '0' ;
			
			TBL_ISEQ_SHIFTED(i)(N_ENTRIES_FPU_RS-2 downto 0) <= TBL_ISEQ(i)(N_ENTRIES_FPU_RS-1 downto 1) ;
			TBL_ISEQ_SHIFTED(i)(N_ENTRIES_FPU_RS - 1) 		 <= '0' ;
			
			ISEQ_NEXT(i) <= TBL_ISEQ_SHIFTED(i) when SHIFT_EN(i) = '1'   else
								 (others => '0') when RESET_EN(i) = '1' else
								 I1_SEQ_NEXT when (i = to_integer(unsigned(RS_ALLOC_LOC(0)(N_LOC_BITS-1 downto 0))) and RS_ALLOC_LOC(0)(N_LOC_BITS) = '1' ) else 
								 I2_SEQ_NEXT when (i = to_integer(unsigned(RS_ALLOC_LOC(1)(N_LOC_BITS-1 downto 0))) and RS_ALLOC_LOC(1)(N_LOC_BITS) = '1' ) else
								 I3_SEQ_NEXT when (i = to_integer(unsigned(RS_ALLOC_LOC(2)(N_LOC_BITS-1 downto 0))) and RS_ALLOC_LOC(2)(N_LOC_BITS) = '1' ) else
								 TBL_ISEQ(i) ;

--			ISEQ_NEXT(i) <= I1_SEQ_NEXT when (i = to_integer(unsigned(RS_ALLOC_LOC(0)(N_LOC_BITS-1 downto 0))) and RS_ALLOC_LOC(0)(N_LOC_BITS) = '1' ) else 
--								 I2_SEQ_NEXT when (i = to_integer(unsigned(RS_ALLOC_LOC(1)(N_LOC_BITS-1 downto 0))) and RS_ALLOC_LOC(1)(N_LOC_BITS) = '1' ) else
--								 I3_SEQ_NEXT when (i = to_integer(unsigned(RS_ALLOC_LOC(2)(N_LOC_BITS-1 downto 0))) and RS_ALLOC_LOC(2)(N_LOC_BITS) = '1' ) else
--								 TBL_ISEQ_SHIFTED(i) when SHIFT_EN(i) = '1'   else
--								 TBL_ISEQ(i) ;


	end generate;
	
		
	process( CLK , RST )
	variable iloc : integer;
	variable val_opr1, val_opr2 : std_logic;
	variable v_instr_exec , v_flag_dispatch: std_logic := '0';
	variable v_instr_loc_next : std_logic_vector(N_LOC_BITS downto 0);
	variable v_opr1_next , v_opr2_next : std_logic_vector(31 downto 0);
<<<<<<< HEAD

=======
	variable v_FUNC_next : std_logic_vector(N_FUNC_BITS-1 downto 0);
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
	variable v_iseq, v_iseq_next : t_arrN_slvN ;
	variable v_iseq1, v_iseq2, v_iseq3 : std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);
	variable v_n_instr_after_alloc : std_logic_vector(N_LOC_BITS downto 0);
	variable v_zeros : std_logic_vector(N_LOC_BITS-1 downto 0);
	variable n_instr1, n_instr2, n_instr3, n_instr4 : unsigned(N_LOC_BITS downto 0);
	begin
		if (RST = '1') then
			TBL_BUSY  <= std_logic_vector(to_unsigned(0, N_ENTRIES_FPU_RS));
			TBL_READY <= std_logic_vector(to_unsigned(0, N_ENTRIES_FPU_RS));
			TBL_O1VL <= std_logic_vector(to_unsigned(0, N_ENTRIES_FPU_RS));
			TBL_O2VL <= std_logic_vector(to_unsigned(0, N_ENTRIES_FPU_RS));
<<<<<<< HEAD
			TBL_ROB_LOC <= (others => (others => '0'));
=======
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
			TBL_ISEQ <= (others => (others => '0'));
			v_iseq := (others => (others => '0'));
		elsif rising_edge(clk) then
		
<<<<<<< HEAD

=======
			-- Update Table for old instructions if data is available
--			for j in 0 to N_ENTRIES_FPU_RS-1 loop
--				if (TBL_BUSY(j) = '1') then
--					val_opr1 := TBL_O1VL(j);
--					val_opr2 := TBL_O2VL(j);
--					if (TBL_O1VL(j) = '0' and OPR1_VAL_COPY(j) = '1' ) then
--							TBL_OPR1(j) <= OPR1_TO_COPY(j);
--							TBL_O1VL(j) <= '1';
--							val_opr1 := '1';		
--					end if;
--					if (TBL_O2VL(j) = '0' and OPR2_VAL_COPY(j) = '1' ) then
--							TBL_OPR2(j) <= OPR2_TO_COPY(j);
--							TBL_O2VL(j) <= '1';
--							val_opr2 := '1';
--					end if;
--					
--					TBL_READY(j) <= val_opr1 and val_opr2;
--				end if;	
--			end loop;
------			
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
			for j in 0 to N_ENTRIES_FPU_RS-1 loop
				if ( OPR1_LOAD_EN(j) = '1' ) then
					TBL_OPR1(j) <= OPR1_TO_COPY(j);
					TBL_O1VL(j) <= OPR1_VAL_NEXT(j);
				end if;

				if ( OPR2_LOAD_EN(j) = '1' ) then
					TBL_OPR2(j) <= OPR2_TO_COPY(j);
					TBL_O2VL(j) <= OPR2_VAL_NEXT(j);
				end if;
				
				if (OPR1_LOAD_EN(j) = '1' or OPR2_LOAD_EN(j) = '1' ) then
					TBL_READY(j) <= TBL_READY_NEXT(j);
				end if;
			end loop;	
<<<<<<< HEAD
		
			n_instr1 := unsigned(N3) ;
			
			for j in 0 to N_ENTRIES_FPU_RS-1 loop
				if (TBL_FLUSH_NEXT(j) = '1') then
					TBL_READY(j) <= '0';
					
					if (TBL_BUSY(j) = '1') then
						n_instr1 := n_instr1 - to_unsigned(1,N_LOC_BITS+1) ;
					end if;
					
					TBL_BUSY(j) <= '0';
				end if;
				
				TBL_BR_FIELD(j)(9) <= TBL_ISPEC_NEXT(j) ;
			end loop;
			
=======

--				v_zeros :=  std_logic_vector(to_unsigned(0, N_LOC_BITS));
--
--				n_instr1 := 	unsigned(N_INSTR_IN_STN);
--				n_instr2 := 	n_instr1 + unsigned( v_zeros & RS_ALLOC_LOC(0)(N_LOC_BITS));
--				n_instr3 :=    n_instr2 + unsigned( v_zeros & RS_ALLOC_LOC(1)(N_LOC_BITS)) ;
--				n_instr4 :=    n_instr3 + unsigned( v_zeros & RS_ALLOC_LOC(2)(N_LOC_BITS)) ;
--
--				if (RS_ALLOC_LOC(0)(N_LOC_BITS) = '1') then
--					v_iseq1 := FUNC_GET_SEQ (n_instr1) ;
--				end if;		
--
--				if (RS_ALLOC_LOC(1)(N_LOC_BITS) = '1') then
--					v_iseq2 := FUNC_GET_SEQ (n_instr2) ;
--				end if;		
--						
--				if (RS_ALLOC_LOC(2)(N_LOC_BITS) = '1') then
--					v_iseq3 := FUNC_GET_SEQ (n_instr3) ;
--				end if;
--				
--				v_n_instr_after_alloc := std_logic_vector(n_instr4);			

>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
			-- Update Table for new instructions
			if (RS_ALLOC_LOC(0)(N_LOC_BITS) = '1') then
			
					iloc := to_integer(unsigned(RS_ALLOC_LOC(0)(N_LOC_BITS-1 downto 0)));
					
<<<<<<< HEAD
					TBL_INSTR(iloc) 		<= DS1_INSTR; 
					TBL_DEST(iloc)  		<= DS1_DEST; 
					TBL_CTRL(iloc)  		<= DS1_CTRL; 
					TBL_ROB_LOC(iloc) 	<= DS1_ROB_LOC ;
					TBL_BR_FIELD(iloc)	<= DS1_SPEC_BrTAG_PRED ;
					
					TBL_OPR1(iloc) 		<= DS1_OPR1_NEXT;
					TBL_OPR2(iloc) 		<= DS1_OPR2_NEXT;
					TBL_OPR3(iloc) 		<= DS1_OPR3;
					
					TBL_BUSY(iloc)  		<= '1';
					
					TBL_O1VL(iloc)  		<= DS1_OPR1_VAL_NEXT;
					TBL_O2VL(iloc)  		<= DS1_OPR2_VAL_NEXT;
					
					TBL_READY(iloc) 		<= DS1_INSTR_RDY_NEXT ;
					
					
					v_iseq(iloc) := I1_SEQ;
					TBL_ISEQ(iloc)  		<= I1_SEQ;
=======
					TBL_FUNCTIONAL(iloc) <= DS1_FUNC; 
					
					TBL_OPR1(iloc) <= DS1_OPR1_NEXT;
					TBL_OPR2(iloc) <= DS1_OPR2_NEXT;
					
					TBL_BUSY(iloc)  <= '1';
					
					TBL_O1VL(iloc)  <= DS1_OPR1_VAL_NEXT;
					TBL_O2VL(iloc)  <= DS1_OPR2_VAL_NEXT;
					
					TBL_READY(iloc) <= DS1_INSTR_RDY_NEXT ;
					
					v_iseq(iloc) := I1_SEQ;
					TBL_ISEQ(iloc)  <= I1_SEQ;
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
			end if;		
	
			if (RS_ALLOC_LOC(1)(N_LOC_BITS) = '1') then
			
					iloc := to_integer(unsigned(RS_ALLOC_LOC(1)(N_LOC_BITS-1 downto 0)));
					
<<<<<<< HEAD
					TBL_INSTR(iloc) 		<= DS2_INSTR; 
					TBL_DEST(iloc)  		<= DS2_DEST; 
					TBL_CTRL(iloc)  		<= DS2_CTRL;
					TBL_ROB_LOC(iloc) 	<= DS2_ROB_LOC ;
					TBL_BR_FIELD(iloc)	<= DS2_SPEC_BrTAG_PRED ;
					
					TBL_OPR1(iloc) 		<= DS2_OPR1_NEXT;
					TBL_OPR2(iloc) 		<= DS2_OPR2_NEXT;
					TBL_OPR3(iloc) 		<= DS2_OPR3;
					
					TBL_BUSY(iloc)  		<= '1';
					
					TBL_O1VL(iloc)  		<= DS2_OPR1_VAL_NEXT;
					TBL_O2VL(iloc)  		<= DS2_OPR2_VAL_NEXT;
					
					TBL_READY(iloc) 		<= DS2_INSTR_RDY_NEXT ;
					
					TBL_ISEQ(iloc)  		<= I2_SEQ;
=======
					TBL_FUNCTIONAL(iloc) <= DS2_FUNC;
					
					TBL_OPR1(iloc) <= DS2_OPR1_NEXT;
					TBL_OPR2(iloc) <= DS2_OPR2_NEXT;
					
					TBL_BUSY(iloc)  <= '1';
					
					TBL_O1VL(iloc)  <= DS2_OPR1_VAL_NEXT;
					TBL_O2VL(iloc)  <= DS2_OPR2_VAL_NEXT;
					
					TBL_READY(iloc) <= DS2_INSTR_RDY_NEXT ;
					
					TBL_ISEQ(iloc)  <= I2_SEQ;
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
					v_iseq(iloc) := I2_SEQ;
			end if;		
			
			if (RS_ALLOC_LOC(2)(N_LOC_BITS) = '1') then
			
					iloc := to_integer(unsigned(RS_ALLOC_LOC(2)(N_LOC_BITS-1 downto 0)));
					
<<<<<<< HEAD
					TBL_INSTR(iloc) 		<= DS3_INSTR; 
					TBL_DEST(iloc)  		<= DS3_DEST; 
					TBL_CTRL(iloc)  		<= DS3_CTRL;
					TBL_ROB_LOC(iloc) 	<= DS3_ROB_LOC ;
					TBL_BR_FIELD(iloc)	<= DS3_SPEC_BrTAG_PRED ;
					
					TBL_OPR1(iloc) 		<= DS3_OPR1_NEXT;
					TBL_OPR2(iloc) 		<= DS3_OPR2_NEXT;
					TBL_OPR3(iloc) 		<= DS3_OPR3;
					
					TBL_BUSY(iloc)  		<= '1';
					
					TBL_O1VL(iloc)  		<= DS3_OPR1_VAL_NEXT;
					TBL_O2VL(iloc)  		<= DS3_OPR2_VAL_NEXT;
					
					TBL_READY(iloc) 		<= DS3_INSTR_RDY_NEXT ;
					
					TBL_ISEQ(iloc)  		<= I3_SEQ;
					v_iseq(iloc) := I3_SEQ;
			end if;
			
			RS_OUTPUT_VALID <= '0' ;
			
			if (INST_VALID = '1') then
				
				iloc := to_integer(unsigned(INSTR_NEXT_ROW(N_LOC_BITS-1 downto 0)));
				
				if ( TBL_FLUSH_NEXT(iloc) = '0' and TBL_ISPEC_NEXT(iloc) = '0' ) then
					TBL_BUSY(to_integer(unsigned(INSTR_NEXT_ROW(N_LOC_BITS-1 downto 0)))) <= '0';
					TBL_READY(to_integer(unsigned(INSTR_NEXT_ROW(N_LOC_BITS-1 downto 0)))) <= '0';
					
					DREG_OPR1  		<= INSTR_OPR1_NEXT;
					DREG_OPR2  		<= INSTR_OPR2_NEXT;
					DREG_OPR3      <= INSTR_OPR3_NEXT;
					
					DREG_INSTR 		<= INSTR_NEXT ;
					DREG_DEST  		<= INSTR_DEST_NEXT ;
					DREG_CTRL  		<= INSTR_CTRL_NEXT;
					DREG_ROB_LOC 	<= INSTR_ROB_LOC_NEXT;
					DREG_BR_FIELD	<= INSTR_BR_FIELD_NEXT;
					
					for i in 0 to N_ENTRIES_FPU_RS-1 loop
						TBL_ISEQ(i) <= ISEQ_NEXT(i);
					end loop;
					
					TBL_ISEQ(to_integer(unsigned(INSTR_NEXT_ROW(N_LOC_BITS-1 downto 0)))) <= (others => '0');
					N_INSTR_IN_STN <= std_logic_vector(n_instr1 - to_unsigned(1, N_LOC_BITS+1));
					
					RS_OUTPUT_VALID <= '1';
				else
					N_INSTR_IN_STN <= std_logic_vector(n_instr1);
				end if;
			else
				N_INSTR_IN_STN <= std_logic_vector(n_instr1);
			end if;
		


=======
					TBL_FUNCTIONAL(iloc) <= DS3_FUNC;
					
					TBL_OPR1(iloc) <= DS3_OPR1_NEXT;
					TBL_OPR2(iloc) <= DS3_OPR2_NEXT;
					
					TBL_BUSY(iloc)  <= '1';
					
					TBL_O1VL(iloc)  <= DS3_OPR1_VAL_NEXT;
					TBL_O2VL(iloc)  <= DS3_OPR2_VAL_NEXT;
					
					TBL_READY(iloc) <= DS3_INSTR_RDY_NEXT ;
					
					TBL_ISEQ(iloc)  <= I3_SEQ;
					v_iseq(iloc) := I3_SEQ;
			end if;
			
			if (INST_VALID = '1') then
				TBL_BUSY(to_integer(unsigned(INSTR_NEXT_ROW(N_LOC_BITS-1 downto 0)))) <= '0';
				TBL_READY(to_integer(unsigned(INSTR_NEXT_ROW(N_LOC_BITS-1 downto 0)))) <= '0';
				
				DREG_OPR1 <= INSTR_OPR1_NEXT;
				DREG_OPR2 <= INSTR_OPR2_NEXT;
				DREG_FUNC <= INSTR_FUNC_NEXT;
		
				for i in 0 to N_ENTRIES_FPU_RS-1 loop
					TBL_ISEQ(i) <= ISEQ_NEXT(i);
				end loop;
				
				--TBL_ISEQ(to_integer(unsigned(INSTR_NEXT_ROW(N_LOC_BITS-1 downto 0)))) <= (others => '0');
				N_INSTR_IN_STN <= std_logic_vector(unsigned(N3) - to_unsigned(1, N_LOC_BITS+1));
				
			end if;
		
--			-- Dispath Instruction and Free Reservation Station
--			-- DISPATCH PATH --
--			v_instr_loc_next := (others => '0');
--			v_flag_dispatch := '0';
--			
--			for i in 0 to N_ENTRIES_FPU_RS-1 loop
--				for j in 0 to N_ENTRIES_FPU_RS-1 loop
--					if (v_iseq(j)(i) = '1') and (v_flag_dispatch = '0') then 
--						if (TBL_READY(j) = '1') then
--							v_instr_loc_next := '1' & std_logic_vector(to_unsigned(j, N_LOC_BITS));
--							v_opr1_next := TBL_OPR1(j);
--							v_opr2_next := TBL_OPR2(j);
--							v_FUNC_next := TBL_FUNCTIONAL(j) ;
--							v_flag_dispatch := '1';
--							
--						else 
--							if ( OPR1_LOAD_EN(j) = '1' ) and ( OPR2_LOAD_EN(i) = '1' ) then
--								v_instr_loc_next := '1' & std_logic_vector(to_unsigned(j, N_LOC_BITS));
--								v_opr1_next := OPR1_TO_COPY(j);
--								v_opr2_next := OPR2_TO_COPY(j);
--								v_FUNC_next := TBL_FUNCTIONAL(j) ;
--								v_flag_dispatch := '1';
--								
--							elsif ( OPR1_LOAD_EN(j) = '1' ) and (TBL_O2VL(j) = '1') then	
--								v_instr_loc_next := '1' & std_logic_vector(to_unsigned(j, N_LOC_BITS));
--								v_opr1_next 	  := OPR1_TO_COPY(j);
--								v_opr2_next := TBL_OPR2(j);
--								v_FUNC_next := TBL_FUNCTIONAL(j) ;
--								v_flag_dispatch := '1';
--								
--							elsif	( OPR2_LOAD_EN(j) = '1' ) and (TBL_O1VL(j) = '1') then	
--								v_instr_loc_next := '1' & std_logic_vector(to_unsigned(j, N_LOC_BITS));
--								v_opr1_next 	  := TBL_OPR1(j);
--								v_opr2_next 	  := OPR2_TO_COPY(j);
--								v_FUNC_next 	  := TBL_FUNCTIONAL(j) ;
--								v_flag_dispatch := '1';
--								
--							end if;	
--						end if;
--					end if;	
--				end loop;
--			end loop;
--			
--			-- DISPATCH UNIT --
--			v_instr_exec := '0';
--			
--			if (v_instr_loc_next(N_LOC_BITS) = '1') then
--			
--					TBL_BUSY(to_integer(unsigned(v_instr_loc_next(N_LOC_BITS -1 downto 0)))) <= '0';
--					TBL_READY(to_integer(unsigned(v_instr_loc_next(N_LOC_BITS -1 downto 0)))) <= '0';
--					
--					v_iseq(to_integer(unsigned(v_instr_loc_next(N_LOC_BITS -1 downto 0)))) := (others => '0');
--					DREG_OPR1 <= v_opr1_next;
--					DREG_OPR2 <= v_opr2_next;
--					DREG_FUNC <= v_FUNC_next;
--
--					v_instr_exec := '1';
--			
--			elsif (RS_ALLOC_LOC(0)(N_LOC_BITS) = '1') and (DS1_INSTR_RDY_NEXT = '1') then			
--					
--					TBL_BUSY(to_integer(unsigned(RS_ALLOC_LOC(0)(N_LOC_BITS-1 downto 0)))) <= '0';
--					TBL_READY(to_integer(unsigned(RS_ALLOC_LOC(0)(N_LOC_BITS-1 downto 0)))) <= '0';
--					
--					v_iseq(to_integer(unsigned(RS_ALLOC_LOC(0)(N_LOC_BITS -1 downto 0)))) := (others => '0');
--					
--					DREG_OPR1 <= DS1_OPR1_NEXT;
--					DREG_OPR2 <= DS1_OPR2_NEXT;
--					DREG_FUNC <= DS1_FUNC;
--
--					v_instr_exec := '1';	
--					
--			elsif (RS_ALLOC_LOC(1)(N_LOC_BITS) = '1') and (DS2_INSTR_RDY_NEXT = '1') then			
--					
--					TBL_BUSY(to_integer(unsigned(RS_ALLOC_LOC(1)(N_LOC_BITS-1 downto 0)))) <= '0';
--					TBL_READY(to_integer(unsigned(RS_ALLOC_LOC(1)(N_LOC_BITS-1 downto 0)))) <= '0';
--					
--					v_iseq(to_integer(unsigned(RS_ALLOC_LOC(1)(N_LOC_BITS -1 downto 0)))) := (others => '0');
--					
--					DREG_OPR1 <= DS2_OPR1_NEXT;
--					DREG_OPR2 <= DS2_OPR2_NEXT;
--					DREG_FUNC <= DS2_FUNC;
--
--					v_instr_exec := '1';					
--
--			elsif (RS_ALLOC_LOC(2)(N_LOC_BITS) = '1') and (DS3_INSTR_RDY_NEXT = '1') then			
--					
--					TBL_BUSY(to_integer(unsigned(RS_ALLOC_LOC(2)(N_LOC_BITS-1 downto 0)))) <= '0';
--					TBL_READY(to_integer(unsigned(RS_ALLOC_LOC(2)(N_LOC_BITS-1 downto 0)))) <= '0';
--					
--					v_iseq(to_integer(unsigned(RS_ALLOC_LOC(2)(N_LOC_BITS -1 downto 0)))) := (others => '0');
--					
--					DREG_OPR1 <= DS3_OPR1_NEXT;
--					DREG_OPR2 <= DS3_OPR2_NEXT;
--					DREG_FUNC <= DS3_FUNC;
--
--
--					v_instr_exec := '1';					
--			end if;
--
--			
--			if ( v_instr_exec	= '1') then
--				for i in 0 to N_ENTRIES_FPU_RS-1 loop
--					if (v_iseq(i)(0) /= '1' ) then
--						v_iseq_next(i)(N_ENTRIES_FPU_RS - 1) := '0' ;
--						v_iseq_next(i)(N_ENTRIES_FPU_RS - 2 downto 0) := v_iseq(i)(N_ENTRIES_FPU_RS-1 downto 1);
--					else
--						v_iseq_next(i) := v_iseq(i);
--					end if;	
--					v_iseq(i) := v_iseq_next(i);
--				end loop;
--				--N_INSTR_IN_STN <= std_logic_vector(unsigned(v_n_instr_after_alloc) - to_unsigned(1, N_LOC_BITS+1));			
--				N_INSTR_IN_STN <= std_logic_vector(unsigned(N3) - to_unsigned(1, N_LOC_BITS+1));
--			end if;			
		RS_OUTPUT_VALID <= INST_VALID;
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0
		end if;
		

		
--		RS_OUTPUT_VALID <= v_instr_exec;
		--INSTR_NEXT_ROW(N_LOC_BITS-1 downto 0)		
		
--		TEMP_ISEQ0 <= v_iseq(0);
--		TEMP_ISEQ1 <= v_iseq(1);
--		TEMP_ISEQ2 <= v_iseq(2);
--		TEMP_ISEQ3 <= v_iseq(3);
				
--				DREG_OPR1 <= INSTR_OPR1_NEXT;
--				DREG_OPR2 <= INSTR_OPR2_NEXT;
<<<<<<< HEAD
--				DREG_CTRL <= INSTR_CTRL_NEXT;
=======
--				DREG_FUNC <= INSTR_FUNC_NEXT;
>>>>>>> 76a393e8bb939fd57d775ef3f7f4b8887f9eead0

				
--		TEMP_ISEQ0 <= TBL_ISEQ(0);
--		TEMP_ISEQ1 <= TBL_ISEQ(1);
--		TEMP_ISEQ2 <= TBL_ISEQ(2);
--		TEMP_ISEQ3 <= TBL_ISEQ(3);

	end process;
	
		TEMP_ISEQ0 <= TBL_ISEQ(0);
		TEMP_ISEQ1 <= TBL_ISEQ(1);
		TEMP_ISEQ2 <= TBL_ISEQ(2);
		TEMP_ISEQ3 <= TBL_ISEQ(3);
		
--	TEMP_ISEQ0 <= ISEQ_NEXT(0);
--	TEMP_ISEQ1 <= ISEQ_NEXT(1);
--	TEMP_ISEQ2 <= ISEQ_NEXT(2);
--	TEMP_ISEQ3 <= ISEQ_NEXT(3);
	
--	TEMP_ISEQ0 <= I1_SEQ;
--	TEMP_ISEQ1 <= I2_SEQ;
--	TEMP_ISEQ2 <= I3_SEQ;
--	TEMP_ISEQ3 <= ISEQ_NEXT(3);

	TEMP_N_INSTR_IN_STN <= N_INSTR_IN_STN ;
	TEMP_BUSY_BITS <= TBL_BUSY;
	TEMP_READY_BITS <= TBL_READY;

end architecture;
