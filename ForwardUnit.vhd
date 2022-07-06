library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std_unsigned.all;
USE ieee.std_logic_arith.all;

entity FU is
Port (
	clk: in std_logic;
	ForwardA: out std_logic_vector(1 downto 0);
    ForwardB: out std_logic_vector(1 downto 0);
    
    IDEX_regRs: in std_logic_vector(4 downto 0);
    IDEX_regRt: in std_logic_vector(4 downto 0);
    EXMEM_regRd: in std_logic_vector(4 downto 0);
    MEMWB_regRd: in std_logic_vector(4 downto 0);
    
    EXMEM_regWrite: in std_logic;
    MEMWB_regWrite: in std_logic
);
end FU;

architecture behavioral of FU is
begin
    -- output of 10 if hazard in EX, 01 if hazard in MEM and 00 if no hazards and
    -- operand comes from register bank
    forwarding : process(clk) begin
       	ForwardA <= "00";
        ForwardB <= "00";
            
        --hazard in EX stage
        if((EXMEM_regWrite = '1')
           	and (EXMEM_regRd /= "00000")
            and (EXMEM_regRd = IDEX_regRs)) then
            ForwardA <= "10";
        end if;
            
        if((EXMEM_regWrite = '1')
           	and (EXMEM_regRd /= "00000")
            and (EXMEM_regRd = IDEX_regRt)) then
            ForwardB <= "10";
        end if;
        
        --hazard in MEM stage
        if( (MEMWB_regWrite = '1')
           	and (MEMWB_regRd /= "00000")
            and (MEMWB_regRd = IDEX_regRs)
            and (not((EXMEM_regRd = IDEX_regRs) and (EXMEM_regWrite = '1')))) then
            ForwardA <= "01";
        end if;

        if( (MEMWB_regWrite = '1')
           	and (MEMWB_regRd /= "00000")
            and (MEMWB_regRd = IDEX_regRt)
            and (not ((EXMEM_regRd = IDEX_regRt) and (EXMEM_regWrite = '1')))) then
            ForwardB <= "01";
         end if;
    end process;
    
end behavioral;