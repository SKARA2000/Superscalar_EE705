library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG_COMMON.all;

entity FETCH is 
	port(
		CLK: in std_logic;
		RST: in std_logic;
	
		--Code Memory; Needs to be written in PKG_COMMON
		MEM: in CODE_MEM;
		
		-- Inputs from the Decode Stage
		I_TAG_EXEC1, I_TAG_EXEC2: in std_logic_vector(N_LOG_RR - 1 downto 0);
		I_VAL_EXEC1, I_VAL_EXEC2: in std_logic;
		I_PC_EXEC1, I_PC_EXEC2: in std_logic_vector(31 downto 0); 
		I_HIST_IND_EXEC1, I_HIST_IND_EXEC2: in std_logic_vector(N_Br_TAG - 1 downto 0);
		
		-- Inputs from the Branch Execution Unit
		I_TAG_EXEC3: in std_logic_vector(N_LOG_RR - 1 downto 0);
		I_VAL_EXEC3: in std_logic;
		I_PC_EXEC3: in std_logic_vector(31 downto 0); 
		I_HIST_IND_EXEC3: in std_logic_vector(N_Br_TAG - 1 downto 0);
		
		-- Outputs to the Decode Buffer and itself
		O_NEXT_PC1, O_NEXT_PC2: out std_logic_vector(31 downto 0);
		O_I1_HIST_IND, O_I2_HIST_IND: out std_logic_vector(N_Br_TAG - 1 downto 0);
		O_INST1, O_INST2: out std_logic_vector(31 downto 0);
		O_PREDICTION1, O_PREDICTION2: out std_logic; -- '1' if branch taken, '0' if not taken
		
		--Debugging purpose
		O_HIST_TABLE: out TABLE
	);
end entity;

architecture FETCH_ARCH of FETCH is
begin
	process(CLK)
		variable HIST_TABLE: TABLE;
		variable INDEX: std_logic_vector(N_Br_TAG - 1 downto 0);
		variable spec_bit: std_logic;
		variable INST1, INST2: std_logic_vector(31 downto 0);
		variable pc_loc: integer;
		variable prediction1, prediction2: std_logic;
	begin
		--pc_loc := to_integer(unsigned(I_PC));
		if (RST = '1') then
			HIST_TABLE := (others => (others => '0'));
			INDEX := (others => '0');
			
			spec_bit := '0';
			INST1 := (others => '0');
			INST2 := (others => '0');
			pc_loc := 0;
			
			O_I1_HIST_IND <= (others => '0');
			O_I2_HIST_IND <= (others => '0');
			O_INST1 <= (others => '0');
			O_INST2 <= (others => '0');
			O_PREDICTION1 <= '0';
			O_PREDICTION2 <= '0';
			
		elsif rising_edge(CLK) then
			--pc_loc := to_integer(unsigned(I_PC));
				
			if(I_VAL_EXEC2 = '1') then
				HIST_TABLE(to_integer(unsigned(I_HIST_IND_EXEC2)))(31 downto 0) := I_PC_EXEC2;
				if(I_TAG_EXEC2(0) = '0') then
					pc_loc := to_integer(unsigned(I_PC_EXEC2));
				end if;
			end if;			
		
			if(I_VAL_EXEC1 = '1') then
				HIST_TABLE(to_integer(unsigned(I_HIST_IND_EXEC1)))(31 downto 0) := I_PC_EXEC1;
				if(I_TAG_EXEC1(0) = '0') then
					pc_loc := to_integer(unsigned(I_PC_EXEC1));
				end if;
			end if;
			
			if(I_VAL_EXEC3 = '1') then
				HIST_TABLE(to_integer(unsigned(I_HIST_IND_EXEC3)))(31 downto 0) := I_PC_EXEC3;
				if(I_TAG_EXEC3(0) = '0') then
					pc_loc := to_integer(unsigned(I_PC_EXEC3));
				end if;
			end if;
			
			
			-- Read first instruction from code memory first
			INST1 := MEM(pc_loc);
			prediction1 := '0';
			pc_loc := (pc_loc + 1);
			
			-- First identify whether first instruction is branch or not
			if((INST1(31 downto 26) = "000010") or (INST1(31 downto 26) = "000001") or (INST1(31 downto 26) = "000100") or (INST1(31 downto 26) = "000011") or ((INST1(31 downto 26) = "000000") and (INST1(5 downto 0) = "001000"))) then
				INDEX := std_logic_vector(unsigned(INDEX) + 1);
				-- If branch, check for pc in history table
				for i in 0 to (2**N_Br_TAG - 1) loop
					if(unsigned(HIST_TABLE(i)(63 downto 32)) = to_unsigned(pc_loc, 32)) then
						pc_loc := to_integer(unsigned(HIST_TABLE(i)(31 downto 0)));
						INDEX := std_logic_vector(to_unsigned(i, N_Br_TAG));
						prediction1 := '1';
					end if;
				end loop;
				
				O_I1_HIST_IND <= INDEX;
			end if;
			
			O_NEXT_PC1 <= std_logic_vector(to_unsigned(pc_loc, 32));
			
			-- Next fetch the second instruction
			INST2 := MEM(pc_loc);
			pc_loc := (pc_loc + 1);
			prediction2 := '0';
			
			-- Proceed similarly as for the first instruction
			if((INST2(31 downto 26) = "000010") or (INST2(31 downto 26) = "000001") or (INST2(31 downto 26) = "000100") or (INST2(31 downto 26) = "000011") or ((INST2(31 downto 26) = "000000") and (INST2(5 downto 0) = "001000"))) then
				INDEX := std_logic_vector(unsigned(INDEX) + 1);
				-- If branch, check for pc in history table
				for j in 0 to (2**N_Br_TAG - 1) loop
					if(unsigned(HIST_TABLE(j)(63 downto 32)) = to_unsigned(pc_loc, 32)) then
						pc_loc := to_integer(unsigned(HIST_TABLE(j)(31 downto 0)));
						INDEX := std_logic_vector(to_unsigned(j, N_Br_TAG));
						prediction2 := '1';
					end if;
				end loop;
				
				O_I2_HIST_IND <= INDEX;
			end if;
			
			O_NEXT_PC2 <= std_logic_vector(to_unsigned(pc_loc, 32));
			
			O_INST1 <= INST1;
			O_INST2 <= INST2;
			O_PREDICTION1 <= prediction1;
			O_PREDICTION2 <= prediction2;
			O_HIST_TABLE <= HIST_TABLE;
		end if;
	end process;
end architecture FETCH_ARCH;