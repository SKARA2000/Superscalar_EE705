library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG_COMMON.all;
use work.PKG_StoreBuf.all;

entity ROB is 
	port(
		CLK, RST: in std_logic;
		
		--Inputs from Dispatch stage
		I_PC1, I_PC2: in std_logic_vector(31 downto 0);
		I_I1, I_I2: in std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
		I_I1_CTRL, I_I2_CTRL: in std_logic_vector(N_CTRL_BITS - 1 downto 0);
		I_I1_VALID, I_I2_VALID: in std_logic;
		I_I1_SPEC, I_I2_SPEC: in std_logic;
		I_I1_BrTAG, I_I2_BrTAG: in std_logic_vector(N_Br_TAG -1 downto 0);
		I_I1_ARCH_REG, I_I2_ARCH_REG: in std_logic_vector(N_LOG_AR - 1 downto 0);
		I_I1_RNME_REG, I_I2_RNME_REG: in std_logic_vector(N_LOG_RR - 1 downto 0);
		
		--Inputs from the Common Data Bus
		I_TAG_EXEC: in T_ARR4_SLV_TAG;
		I_LOC_EXEC: in T_ARR4_SLV_LOC;
		I_VAL_EXEC: in std_logic_vector(0 to 3);
		I_OPR_EXEC: in T_ARR4_SLV32;
		I_HIST_IND_EXEC: in std_logic_vector(N_Br_TAG - 1 downto 0);
		I_BR_PC_EXEC: in std_logic_vector(31 downto 0);
		I_STORE_BUFF_IND: in std_logic_vector(BufferSize - 1 downto 0);
		I_SW_VALID: in std_logic;
		
		--Outputs to dispatch stage
		O_ROB_FREE_LOC1, O_ROB_FREE_LOC2: out std_logic_vector(N_LOG_ROB - 1 downto 0);
		O_ROB_REG_WR1, O_ROB_REG_WR2: out std_logic;
		O_ROB_REG_FLUSH1, O_ROB_REG_FLUSH2: out std_logic;
		O_ROB_RNME_REG1, O_ROB_RNME_REG2: out std_logic_vector(N_LOG_RR - 1 downto 0);
		O_ROB_ARCH_REG1, O_ROB_ARCH_REG2: out std_logic_vector(N_LOG_AR - 1 downto 0);
		
		--Outputs to Decode and Dispatch Unit
		O_ROB_HIST_IND_EXEC: out std_logic_vector(N_Br_TAG - 1 downto 0);
		O_ROB_BR_PC_EXEC: out std_logic_vector(31 downto 0);
		O_ROB_DEC_VAL, O_ROB_DEC_BR_RES: out std_logic;
		O_ROB_DEC_TAG: out std_logic_vector(N_Br_TAG - 1 downto 0);
		
		--Outputs to store buffer
		O_STORE_COMMIT: out std_logic;
		O_LOC_BUFF: out std_logic_vector(BufferSize - 1 downto 0);
		
		--Maintenance Outputs
		O_FULL: out std_logic;
		
		--For debugging purposes
		O_head: out std_logic_vector(N_LOG_ROB - 1 downto 0);
		O_last: out std_logic_vector(N_LOG_ROB - 1 downto 0);
		O_BRTAG: out ROB_BrTAG_COLUMN;
		O_FLUSH, O_SPEC, O_VALID: out std_logic_vector(2**N_LOG_ROB - 1 downto 0)
	);
end entity;

architecture ROB_ARCH of ROB is
begin	
	process(CLK, RST)
		variable temp_last_1: unsigned(N_LOG_ROB - 1 downto 0);
		variable temp_loc: integer;
		variable temp_opr_br: std_logic_vector(N_LOG_RR - 1 downto 0);
		variable temp_last_loc: unsigned(N_LOG_ROB - 1 downto 0);
		variable new_head: unsigned(N_LOG_ROB - 1 downto 0);
		variable temp_brTag: unsigned(N_Br_TAG - 1 downto 0);
		variable rob_count: integer;
		
		variable WR1, WR2: std_logic;
		variable FREE_LOC1, FREE_LOC2: std_logic_vector(N_LOG_ROB - 1 downto 0);
		variable RNME_REG1, RNME_REG2: std_logic_vector(N_LOG_RR - 1 downto 0);
		variable ARCH_REG1, ARCH_REG2: std_logic_vector(N_LOG_AR - 1 downto 0);
		variable STORE_COMMIT: std_logic;
		variable StoreLocationBuffer: std_logic_vector(BufferSize - 1 downto 0);
		
		-- ROB internal table structure
		variable PC: ROB_PC_COLUMN;
		variable LOC: ROB_LOC_COLUMN;
		variable VALID, BUSY, SPEC, FLUSH, SW, RWRITE, BrINST: std_logic_vector(2**N_LOG_ROB - 1 downto 0);
		variable LOC_Buff: ROB_BrTAG_COLUMN;
		
		--signal I1_EXC, I2_EXC: ROB_BIT_COLUMN;
		variable BrTAG: ROB_BrTAG_COLUMN;
		variable ARCH_REG, RNME_REG: ROB_TAG_COLUMN;
	
		-- ROB table/queue pointers
		variable head, last: std_logic_vector(N_LOG_ROB - 1 downto 0) := (others => '0');
		variable beg: std_logic;
		
		variable FULL: std_logic;
	
	begin
		if (rst = '1') then
			head := "0000000";
			last := "0000000";
			beg := '1';
			
			PC := (others => (others => '0'));
			LOC := (others => (others => '0'));
			VALID := (others => '0');
			BUSY := (others => '0');
			SPEC := (others => '0');
			FLUSH := (others => '0');
			SW := (others => '0');
			RWRITE := (others => '0');
			BrTAG := (others => (others => '0'));
			BrINST := (others => '0');
			temp_brTag := (others => '0');
			ARCH_REG := (others => (others => '0'));
			RNME_REG := (others => (others => '0'));
			LOC_Buff := (others => (others => '0'));
			FULL := '0';
			rob_count := 0;
			
			temp_last_loc := unsigned(last);
			O_ROB_FREE_LOC1 <= std_logic_vector(temp_last_loc);
			
			temp_last_loc := unsigned(last) + 1;
			O_ROB_FREE_LOC2 <= std_logic_vector(temp_last_loc);
			
			O_ROB_ARCH_REG1 <= "00000";
			O_ROB_ARCH_REG2 <= "00000";
			
			O_ROB_RNME_REG1 <= "00000";
			O_ROB_RNME_REG2 <= "00000";
			
			O_ROB_DEC_TAG <= (others => '0');
			O_ROB_DEC_BR_RES <= '0';
			O_ROB_DEC_VAL <= '0';
			O_ROB_HIST_IND_EXEC <= (others => '0');
			O_ROB_BR_PC_EXEC <= (others => '0');
			
			O_ROB_REG_WR1 <= '0';
			O_ROB_REG_WR2 <= '0';
			O_ROB_REG_FLUSH1 <= '0';
			O_ROB_REG_FLUSH2 <= '0';
			
			O_STORE_COMMIT <= '0';
			O_LOC_BUFF <= (others => '0');
			
			O_FULL <= '0';
		
		elsif rising_edge(CLK) then
			-- Take inputs from the Dispatch Buffer and arrange the table
			-- at the tail end to add instructions into the ROB
			temp_last_1 := unsigned(last);
			--If ROB fills up right now, stop taking in further
			--instructions and stop all stages
			if(rob_count >= 122) then
				FULL := '1';
			-- Else take in the next instruction
			elsif((I_I1_VALID = '1') or (I_I2_VALID = '1')) and (FULL = '0') then
				if(I_I1_VALID = '1') then
					-- Take in the first instruction; increase last pointer by 1
					PC(to_integer(temp_last_1)) := I_PC1;
					LOC(to_integer(temp_last_1)) := std_logic_vector(temp_last_1);
					if(I_I1_CTRL(N_CTRL_BITS - 1 downto N_CTRL_BITS - 7) = "0001010") or (I_I1_CTRL(N_CTRL_BITS - 1 downto N_CTRL_BITS - 7) = "0001101") then
						VALID(to_integer(temp_last_1)) := '1';
					else 
						VALID(to_integer(temp_last_1)) := '0';
					end if;
					BUSY(to_integer(temp_last_1)) := '1';
					FLUSH(to_integer(temp_last_1)) := '0';
					if(I_I1_CTRL(N_CTRL_BITS - 1 downto N_CTRL_BITS - 4) = "0010") and (I_I1_CTRL(4) = '1') then
						SW(to_integer(temp_last_1)) := '1';
					else 
						SW(to_integer(temp_last_1)) := '0';
					end if;
					if (I_I1_CTRL(N_CTRL_BITS - 7) = '1') then
						RWRITE(to_integer(temp_last_1)) := '1';
					else 
						RWRITE(to_integer(temp_last_1)) := '0';
					end if;
					if(I_I1_CTRL(N_CTRL_BITS - 4) = '1') and ((I_I1_CTRL(1 downto 0) = "00") or (I_I1_CTRL(1 downto 0) = "10") ) then
						BrINST(to_integer(temp_last_1)) := '1';
					else
						BrINST(to_integer(temp_last_1)) := '0';
					end if;
					SPEC(to_integer(temp_last_1)) := I_I1_SPEC;
					BrTAG(to_integer(temp_last_1)) := I_I1_BrTAG;
					ARCH_REG(to_integer(temp_last_1)) := I_I1_ARCH_REG;
					RNME_REG(to_integer(temp_last_1)) := I_I1_RNME_REG;
					
					temp_last_1 := temp_last_1 + 1;
					rob_count := rob_count + 1;
				end if;
				if(I_I2_VALID = '1') then
					PC(to_integer(temp_last_1)) := I_PC2;
					LOC(to_integer(temp_last_1)) := std_logic_vector(temp_last_1);
					if(I_I2_CTRL(N_CTRL_BITS - 1 downto N_CTRL_BITS - 7) = "0001010") or (I_I2_CTRL(N_CTRL_BITS - 1 downto N_CTRL_BITS - 7) = "0001101") then
						VALID(to_integer(temp_last_1)) := '1';
					else 
						VALID(to_integer(temp_last_1)) := '0';
					end if;
					BUSY(to_integer(temp_last_1)) := '1';
					FLUSH(to_integer(temp_last_1)) := '0';
					if(I_I2_CTRL(N_CTRL_BITS - 1 downto N_CTRL_BITS - 4) = "0010") and (I_I2_CTRL(4) = '1') then
						SW(to_integer(temp_last_1)) := '1';
					else 
						SW(to_integer(temp_last_1)) := '0';
					end if;
					if (I_I2_CTRL(N_CTRL_BITS - 7) = '1') then
						RWRITE(to_integer(temp_last_1)) := '1';
					else 
						RWRITE(to_integer(temp_last_1)) := '0';
					end if;					
					if(I_I2_CTRL(N_CTRL_BITS - 4) = '1') and ((I_I2_CTRL(1 downto 0) = "00") or (I_I2_CTRL(1 downto 0) = "10")) then
						BrINST(to_integer(temp_last_1)) := '1';
					else
						BrINST(to_integer(temp_last_1)) := '0';
					end if;
					SPEC(to_integer(temp_last_1)) := I_I2_SPEC;
					BrTAG(to_integer(temp_last_1)) := I_I2_BrTAG;
					ARCH_REG(to_integer(temp_last_1)) := I_I2_ARCH_REG;
					RNME_REG(to_integer(temp_last_1)) := I_I2_RNME_REG;
					
					temp_last_1 := temp_last_1 + 1;
					rob_count := rob_count + 1;
				end if;
				last := std_logic_vector(temp_last_1);
			end if;
			
			
			-- Process the inpts from the Common Databus and 
			-- correct for actual result of the branches and remove
			-- speculations
			--Register the Validity of the Executed Instructions
			for i in 0 to 1 loop
				if(I_VAL_EXEC(i) = '1') then
					temp_loc := to_integer(unsigned(I_LOC_EXEC(i)));
					VALID(temp_loc) := '1';
					BUSY(temp_loc) := '0';
				end if;
			end loop;
			-- If Memory instruction(sw especially, store the Store Location Buffer)
			if(I_VAL_EXEC(2) = '1') then
				temp_loc := to_integer(unsigned(I_LOC_EXEC(2)));
				VALID(temp_loc) := '1';
				BUSY(temp_loc) := '0';
				
				if(I_SW_VALID = '1') then
					LOC_Buff(temp_loc) := I_STORE_BUFF_IND;
					SW(temp_loc) := '1';
				end if;
			end if;
			--If Branch instruction finished execution, 
			--check whether speculation made was correct or not
			O_ROB_DEC_VAL <= '0';
			O_ROB_DEC_TAG <= (others => '0');
			O_ROB_DEC_BR_RES <= '0';
			if(I_VAL_EXEC(3) = '1') then
				temp_opr_br := I_TAG_EXEC(3);
				temp_loc := to_integer(unsigned(I_LOC_EXEC(3)));
				VALID(temp_loc) := '1';
				BUSY(temp_loc) := '0';
				temp_brTag := unsigned(BrTAG(temp_loc));
				-- Case: Speculation is wrong; flush Instructions
				-- with tags greater than the corresponding branch tag
				if(temp_opr_br(0) = '0')  then
					for j in 0 to (2**N_LOG_ROB - 1) loop
						if(to_integer(temp_brTag) = to_integer(unsigned(temp_opr_br(4 downto 1)))) then
							FLUSH(j) := '1';
						end if;
					end loop;
				-- Case: Speculation was right; Decrease Branch Tags by one
				else
					for j in 0 to (2**N_LOG_ROB - 1) loop
						if(temp_brTag >= unsigned(temp_opr_br(4 downto 1))) then
							if(BrTAG(j) = "0001") then
								SPEC(j) := '0';
							end if;
							BrTAG(j) := std_logic_vector(unsigned(BrTAG(j)) - 1);
						end if;
					end loop;
				end if;
				-- Give the Branch results back to Decode and Dispatch Unit for proper maintenance of Branch Tags
				if(BrINST(temp_loc) = '1') then
					O_ROB_HIST_IND_EXEC <= I_HIST_IND_EXEC;
					O_ROB_BR_PC_EXEC <= I_BR_PC_EXEC;
					O_ROB_DEC_VAL <= '1';
					O_ROB_DEC_TAG <= std_logic_vector(temp_brTag);
					O_ROB_DEC_BR_RES <= temp_opr_br(0);
				else
					O_ROB_DEC_VAL <= '0';
					O_ROB_DEC_TAG <= (others => '0');
					O_ROB_DEC_BR_RES <= '0';
				end if;
			end if;
		
	
			new_head := unsigned(head);
			--Pass over instrtuctions to be flushed and get the new head pointer
			-- for i in 0 to (2**N_LOG_ROB - 1) loop
				-- if(FLUSH(to_integer(new_head)) = '0') or (new_head = unsigned(last)) then
					-- exit;
				-- end if;
				-- new_head := new_head + 1;
				-- rob_count := rob_count - 1;
			-- end loop;
			--Start operating using this new head pointer
			--If head instruction is valid, not busy and speculative,
			--then commit it
			if ((((VALID(to_integer(new_head)) = '1') and (BUSY(to_integer(new_head)) = '0') and (SPEC(to_integer(new_head)) = '0')) 
							or (FLUSH(to_integer(new_head)) = '1'))) and (new_head < unsigned(last)) then
				if(SW(to_integer(new_head)) = '1') then
					STORE_COMMIT := '1';
					StoreLocationBuffer := LOC_Buff(to_integer(new_head));
				else 
					STORE_COMMIT := '0';
					StoreLocationBuffer := (others => '0');
				end if;
				if(RWRITE(to_integer(new_head)) = '1') then
					WR1 := '1';
					O_ROB_REG_FLUSH1 <= FLUSH(to_integer(new_head));
				else
					WR1 := '0';
					O_ROB_REG_FLUSH1 <= '0';
				end if;			
				ARCH_REG1 := ARCH_REG(to_integer(new_head));
				RNME_REG1 := RNME_REG(to_integer(new_head));
				
				new_head := new_head + 1;
				rob_count := rob_count - 1;
				-- Do the same for the next instruction
				if ((((VALID(to_integer(new_head)) = '1') and (BUSY(to_integer(new_head)) = '0') and (SPEC(to_integer(new_head)) = '0')) 
								or (FLUSH(to_integer(new_head)) = '1') )) and (new_head < unsigned(last)) then
					if(SW(to_integer(new_head)) = '1') then
						STORE_COMMIT := '1';
						StoreLocationBuffer := LOC_Buff(to_integer(new_head));
					else 
						STORE_COMMIT := '0';
						StoreLocationBuffer := (others => '0');
					end if;
					if(RWRITE(to_integer(new_head)) = '1') then
						WR2 := '1';
						O_ROB_REG_FLUSH2 <= FLUSH(to_integer(new_head));
					else
						WR2 := '0';
						O_ROB_REG_FLUSH2 <= '0';
					end if;
					ARCH_REG2 := ARCH_REG(to_integer(new_head));
					RNME_REG2 := RNME_REG(to_integer(new_head));
					
					new_head := new_head + 1;
					rob_count := rob_count - 1;
				-- This means that the second instruction is not valid
				else
					WR2 := '0';
					O_ROB_REG_FLUSH2 <= '0';					
					ARCH_REG2 := ARCH_REG(to_integer(new_head));
					RNME_REG2 := RNME_REG(to_integer(new_head));
				end if;
			-- This means that none of the instruction sare valid to be committed
			else
				WR1 := '0';
				WR2 := '0';
				STORE_COMMIT := '0';
				O_ROB_REG_FLUSH1 <= '0';					
				O_ROB_REG_FLUSH2 <= '0';					
				StoreLocationBuffer := (others => '0');
				ARCH_REG1 := ARCH_REG(to_integer(new_head));
				RNME_REG1 := RNME_REG(to_integer(new_head));
				ARCH_REG2 := ARCH_REG(to_integer(new_head) + 1);
				RNME_REG2 := RNME_REG(to_integer(new_head) + 1);
			end if;
			-- Change the head pointer location to the new one
			head := std_logic_vector(new_head);
			
			if(rob_count < 122) then
				FULL := '0';
			else 
				FULL := '1';
			end if;
			
			temp_last_loc := unsigned(last);
			O_ROB_FREE_LOC1 <= std_logic_vector(temp_last_loc);
			
			temp_last_loc := unsigned(last) + 1;
			O_ROB_FREE_LOC2 <= std_logic_vector(temp_last_loc);
			
			O_ROB_ARCH_REG1 <= ARCH_REG1;
			O_ROB_ARCH_REG2 <= ARCH_REG2;
			
			O_ROB_RNME_REG1 <= RNME_REG1;
			O_ROB_RNME_REG2 <= RNME_REG2;
			
			O_ROB_REG_WR1 <= WR1;
			O_ROB_REG_WR2 <= WR2;
			
			O_STORE_COMMIT <= STORE_COMMIT;
			O_LOC_BUFF <= StoreLocationBuffer;
			
			O_FULL <= FULL;
			
			O_head <= head;
			O_last <= last;
			O_FLUSH <= FLUSH;
			O_SPEC <= SPEC;
			O_BRTAG <= BrTAG;
			O_VALID <= VALID;
		end if;
	end process;
		
end architecture ROB_ARCH;
