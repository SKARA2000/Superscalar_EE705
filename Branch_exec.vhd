library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG_COMMON.all;

entity BRANCH is
	port(
		CLK: in std_logic;
		--Input operands from the Reservation Station
		I_VALID: in std_logic;
		I_OPR1: in std_logic_vector(31 downto 0);
		I_OPR2: in std_logic_vector(31 downto 0);
		I_OPR3: in std_logic_vector(31 downto 0);
		I_CTRL_BITS: in std_logic_vector(N_CTRL_BITS - 1 downto 0);
		I_PREDICTION: in std_logic; -- 1 if branch taken, 0 if not taken
		
		--Utility Inputs from the reservation station
		I_LOC: in std_logic_vector(N_LOG_ROB - 1 downto 0);
		I_BrTAG: in std_logic_vector(N_Br_TAG - 1 downto 0);
		I_HIST_IND: in std_logic_vector(N_Br_TAG - 1 downto 0);
		
		--Outputs as a proper execution unit
		O_OUT_PC: out std_logic_vector(31 downto 0);
		O_HIST_IND: out std_logic_vector(N_Br_TAG - 1 downto 0);
		O_VAL_EXEC: out std_logic;
		O_TAG_EXEC: out std_logic_vector(N_LOG_RR - 1 downto 0);
		O_LOC_EXEC: out std_logic_vector(N_LOG_ROB - 1 downto 0)
	);
end entity;

architecture BR_ARCH of BRANCH is
begin
	process(CLK)
		variable spec_bit: std_logic;
	begin
		if rising_edge(CLK) then
			if(I_CTRL_BITS(23) = '1') and (I_CTRL_BITS(3 downto 2) = "11") and (I_VALID = '1')then
				if((unsigned(I_OPR1) = unsigned(I_OPR2)) xor (I_PREDICTION = '0')) then
					spec_bit := '1';
				else 
					spec_bit := '0';
				end if;
				O_VAL_EXEC <= '1';
				O_TAG_EXEC <= (I_BrTAG & spec_bit);
			elsif(I_CTRL_BITS(23) = '1') and (I_CTRL_BITS(3 downto 2) = "01") and (I_VALID = '1') then
				if((signed(I_OPR1) < 0) xor (I_PREDICTION = '0')) then
					spec_bit := '1';
				else 
					spec_bit := '0';
					
				end if;
				O_VAL_EXEC <= '1';
				O_TAG_EXEC <= (I_BrTAG & spec_bit);
			elsif(I_CTRL_BITS(23) = '1') and (I_CTRL_BITS(20) = '1') and (I_VALID = '1') then
				O_VAL_EXEC <= '1';
				O_TAG_EXEC <= (I_BrTAG & I_PREDICTION);	
			else
				O_VAL_EXEC <= '0';
				O_TAG_EXEC <= (I_BrTAG & '0');
				O_OUT_PC <= (others => '0');
			end if;
			O_HIST_IND <= I_HIST_IND;
			O_OUT_PC <= I_OPR3;
			O_LOC_EXEC <= I_LOC;
		end if;
	end process;
	
end architecture BR_ARCH;
