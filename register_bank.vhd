library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std_unsigned.all;
USE ieee.std_logic_arith.all;

entity Registers is
Port (  clk: in std_logic;
        --asynchronous reset active in high level
		reset: in std_logic;
        wr: in std_logic;
        --register addresing signals
        reg1_rd: in std_logic_vector(4 downto 0);
        reg2_rd: in std_logic_vector(4 downto 0);
        reg_wr: in std_logic_vector(4 downto 0);
        --32 bit data to store
        data_wr: in std_logic_vector(31 downto 0);
        
        --32 bits output signal
        data1_rd: out std_logic_vector(31 downto 0);
        data2_rd: out std_logic_vector(31 downto 0)
);
end Registers;

architecture behavioral of Registers is
	type t_reg is array(0 to 31) of std_logic_vector(31 downto 0);
    signal reg : t_reg;
begin
	regWr: process(clk,reset)
    begin
    	--asynchronous reset
    	if(reset = '1') then
        	reg <= (others => x"00000000");
        -- synchronous writing in falling edge
        else
        	if(falling_edge(clk) and wr='1') then
            	reg(to_integer(reg_wr)) <= data_wr;
            end if;
        end if;
    end process;
    
    data1_rd <= x"00000000" when (reg1_rd = "00000")
    	else reg(to_integer(reg1_rd));
        
   	data2_rd <= x"00000000" when (reg2_rd = "00000")
    	else reg(to_integer(reg2_rd));
end behavioral;