library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.numeric_std_unsigned.all;


entity alu is
Port(
	a: in std_logic_vector(31 downto 0);
    b: in std_logic_vector(31 downto 0);
    control: in std_logic_vector(2 downto 0);
    
    zero: out std_logic;
    result: out std_logic_vector(31 downto 0)
);
end alu;

architecture alu_arch of alu is
signal sal: std_logic_vector(31 downto 0);
begin
	result <= sal;
    
    zero <= '1' when sal = x"00000000" else '0';

	alu_op: process(control,a,b)
    begin
    	case control is
        	when "000" => sal <= (a + b);  --add, lw y sw
            when "001" => sal <= (a - b);
            when "010" => sal <= (a and b);
            when "011" => sal <= (a or b);
            when "100" => if(a < b) then  --slt
            		sal <= x"00000001";
                else
                	sal <= x"00000000";
                end if;
            when "101" => sal <= b; --lui
            when others => sal <= x"00000000";
        end case;
    end process;
end alu_arch;