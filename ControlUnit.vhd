library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std_unsigned.all;
USE ieee.std_logic_arith.all;

entity CU is
Port (
	instr: in std_logic_vector(5 downto 0);
    RegDst: out std_logic;
    Branch: out std_logic;
    MemRead: out std_logic;
    MemToReg: out std_logic;
    MemWrite: out std_logic;
    AluSrc: out std_logic;
    RegWrite: out std_logic;
    AluOp: out std_logic_vector(1 downto 0)
);
end CU;

architecture behavioral of CU is

begin
	control:process(instr) begin
    	case instr is
        when "000000" => -- type R
        	RegDst <= '1';
            Branch <= '0';
            MemRead <= '0';
            MemToReg <= '0';
            MemWrite <= '0';
            AluSrc <= '0';
            RegWrite <= '1';
            AluOp <= "11";
        when "100011" => --load
        	RegDst <= '0';
            Branch <= '0';
            MemRead <= '1';
            MemToReg <= '1';
            MemWrite <= '0';
            AluSrc <= '1';
            RegWrite <= '1';
            AluOp <= "00";
        when "101011" => --store
        	RegDst <= '0';
            Branch <= '0';
            MemRead <= '0';
            MemToReg <= '0';
            MemWrite <= '1';
            AluSrc <= '1';
            RegWrite <= '0';
            AluOp <= "00";
        when "000100" => --beq
        	RegDst <= '0';
            Branch <= '1';
            MemRead <= '0';
            MemToReg <= '0';
            MemWrite <= '0';
            AluSrc <= '0';
            RegWrite <= '0';
        	AluOp <= "01";
        when "001111" => --lui
        	RegDst <= '0';
            Branch <= '0';
            MemRead <= '0';
            MemToReg <= '0';
            MemWrite <= '0';
            AluSrc <= '1';
            RegWrite <= '1';
        	AluOp <= "10";
        when others => --unknown instruction
        	RegDst <= '0';
            Branch <= '0';
            MemRead <= '0';
            MemToReg <= '0';
            MemWrite <= '0';
            AluSrc <= '0';
            RegWrite <= '0';
        	AluOp <= "00";
        end case;
    end process;
end behavioral;