library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity processor is
port(
	Clk         : in  std_logic;
	Reset       : in  std_logic;
	-- Instruction memory
	I_Addr      : out std_logic_vector(31 downto 0);
	I_RdStb     : out std_logic;
	I_WrStb     : out std_logic;
	I_DataOut   : out std_logic_vector(31 downto 0);
	I_DataIn    : in  std_logic_vector(31 downto 0);
	-- Data memory
	D_Addr      : out std_logic_vector(31 downto 0);
	D_RdStb     : out std_logic;
	D_WrStb     : out std_logic;
	D_DataOut   : out std_logic_vector(31 downto 0);
	D_DataIn    : in  std_logic_vector(31 downto 0)
);
end processor;

architecture processor_arq of processor is
	component Registers Port (  Clk: in std_logic;
		reset: in std_logic;
        wr: in std_logic;
        reg1_rd: in std_logic_vector(4 downto 0);
        reg2_rd: in std_logic_vector(4 downto 0);
        reg_wr: in std_logic_vector(4 downto 0);
        data_wr: in std_logic_vector(31 downto 0);
        
        data1_rd: out std_logic_vector(31 downto 0);
        data2_rd: out std_logic_vector(31 downto 0)
		);
	end component;
    
    component CU Port (
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
  	end component;
    
    component Alu
    Port(
        a: in std_logic_vector(31 downto 0);
        b: in std_logic_vector(31 downto 0);
        control: in std_logic_vector(2 downto 0);
        zero: out std_logic;
        result: out std_logic_vector(31 downto 0)
    );
    end component;
    
    component FU Port(
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
    end component;
--------------------------------------------------

	--PC register
    signal PC_reg: std_logic_vector(31 downto 0);
    signal PC_Inc4 : std_logic_vector(31 downto 0);
    signal PC_input : std_logic_vector(31 downto 0);
    
    --IF/ID register signals
	signal IFID_Instr : std_logic_vector(31 downto 0);
    signal IFID_PCInc4 : std_logic_vector(31 downto 0);
    signal IFID_Flush : std_logic;
    
    --register bank signals
    signal br_output1: std_logic_vector(31 downto 0);
    signal br_output2: std_logic_vector(31 downto 0);
    
    --Control unit signals
    signal CU_RegDst: std_logic;
    signal CU_Branch: std_logic;
    signal CU_MemRead: std_logic;
    signal CU_MemToReg: std_logic;
    signal CU_MemWrite: std_logic;
    signal CU_AluSrc: std_logic;
    signal CU_RegWrite: std_logic;
    signal CU_AluOp: std_logic_vector(1 downto 0);
    
    --ID/EX register signals
    signal IDEX_data1rd: std_logic_vector(31 downto 0);
    signal IDEX_data2rd: std_logic_vector(31 downto 0);
    signal IDEX_RegDst: std_logic;
    signal IDEX_MemRead: std_logic;
    signal IDEX_MemToReg: std_logic;
    signal IDEX_MemWrite: std_logic;
    signal IDEX_AluSrc: std_logic;
    signal IDEX_RegWrite: std_logic;
    signal IDEX_AluOp: std_logic_vector(1 downto 0);
    signal IDEX_regDstAddr1: std_logic_vector(4 downto 0);
    signal IDEX_regDstAddr2: std_logic_vector(4 downto 0);
    signal IDEX_signExt: std_logic_vector(31 downto 0);
    
    --ID branch signals
    signal ID_signExt : std_logic_vector(31 downto 0);
    signal ID_regOffset : std_logic_vector(31 downto 0);
    signal ID_beqResult: std_logic;
    signal PCSrc : std_logic;
    signal ID_jumpAddr : std_logic_vector(31 downto 0);
    
    --EX_MEM register signals
    signal EXMEM_MemToReg: std_logic;
    signal EXMEM_MemWrite: std_logic;
    signal EXMEM_MemRead: std_logic;
    signal EXMEM_regDest: std_logic_vector(4 downto 0);
    signal EXMEM_RegRd: std_logic_vector(4 downto 0);
    signal EXMEM_AluInput1: std_logic_vector(31 downto 0);
    signal EXMEM_AluInput2: std_logic_vector(31 downto 0);
    signal EXMEMAlu_result: std_logic_vector(31 downto 0);
    signal EXMEM_writeData: std_logic_vector(31 downto 0);
    signal EXMEM_RegWrite: std_logic;
    
    --Alu control signals
    signal AluCU_control: std_logic_vector(2 downto 0);
    signal EXMEM_zero: std_logic;
    signal Alu_result: std_logic_vector(31 downto 0);
    
    --MEM_WB register signals
    signal MEMWB_MemToReg: std_logic;
    signal MEMWB_regDest: std_logic_vector(4 downto 0);
    signal MEMWB_writeData: std_logic_vector(31 downto 0);
    signal MEMWB_readData: std_logic_vector(31 downto 0);
    signal MEMWB_RegWrite: std_logic;
    
    --WB stage signals
    signal WB_writeData: std_logic_vector(31 downto 0);
    
    --Forwarding signals
    signal IDEX_RegRs: std_logic_vector(4 downto 0);
    signal IDEX_RegRt: std_logic_vector(4 downto 0);
    signal forwardA: std_logic_vector(1 downto 0);
    signal forwardB: std_logic_vector(1 downto 0);
    signal forwardB_result: std_logic_vector(31 downto 0);
begin
----------------------------------------------------
-- IF stage
----------------------------------------------------
	--PC input multiplexor
	PC_input <= PC_Inc4 when (PCSrc = '0') else
    	ID_jumpAddr;
        
    --increment PC
    PC_Inc4 <= (PC_reg + x"00000004");
    
    --instruction fetching
    I_Addr <= PC_reg;
    I_RdStb <= '1';
    I_WrStb <= '0';

	--PC register
	PC_write : process(Clk,Reset)
    begin
    	if(Reset = '1') then
        	PC_reg <= (others => '0');
        elsif (rising_edge(Clk)) then
        	PC_reg <= PC_input;
        end if;
    end process;

	--IF_ID segmentation register
    PipeIF_ID : process(Clk,Reset)
    begin
    	if(Reset = '1') then
        	IFID_Instr <= (others => '0');
            IFID_PCInc4 <= (others => '0');
        elsif (rising_edge(Clk)) then
        	--register flush
        	if(IFID_Flush = '1') then
            	IFID_Instr <= (others => '0');
            	IFID_PCInc4 <= (others => '0');
            else
            -- instruction fetched from memory
                IFID_Instr <= I_DataIn;
                IFID_PCInc4 <= PC_Inc4;
             end if;
        end if;
    end process;
    
----------------------------------------------------
-- ID stage
----------------------------------------------------
	--bank register instantiation
    bancoRegistros:Registers port map(
    	clk => Clk,
        reset => Reset,
        wr => MEMWB_RegWrite,
        reg1_rd => IFID_Instr(25 downto 21),
        reg2_rd => IFID_Instr(20 downto 16),
        reg_wr => MEMWB_regDest,
        data_wr => WB_writeData,
        data1_rd => br_output1,
        data2_rd => br_output2
    );
    
    --control unit instantiation
    unidadControl: CU port map(
    	instr => IFID_Instr(31 downto 26),
        RegDst => CU_RegDst,
        Branch => CU_Branch,
        MemRead => CU_MemRead,
        MemToReg => CU_MemToReg,
        MemWrite => CU_MemWrite,
        AluSrc => CU_AluSrc,
        RegWrite => CU_RegWrite,
        AluOp => CU_AluOp
    );
    
    --ID_EX segmentation register
    PipeID_EX : process(Clk,Reset)
    begin
    	if(Reset = '1') then
            IDEX_data1rd <= x"00000000";
            IDEX_data2rd <= x"00000000";
            IDEX_RegDst <= '0';
            IDEX_MemRead <= '0';
            IDEX_MemToReg <= '0';
            IDEX_MemWrite <= '0';
            IDEX_AluSrc <= '0';
            IDEX_RegWrite <= '0';
            IDEX_AluOp <= "00";
            IDEX_regDstAddr1 <= "00000";
            IDEX_regDstAddr2 <= "00000";
            IDEX_signExt <= x"00000000";
            IDEX_RegRs <= "00000";
            IDEX_RegRt <= "00000";
        elsif (rising_edge(Clk)) then
            IDEX_data1rd <= br_output1;
            IDEX_data2rd <= br_output2;
            IDEX_RegDst <= CU_RegDst;
            IDEX_MemRead <= CU_MemRead;
            IDEX_MemToReg <= CU_MemToReg;
            IDEX_MemWrite <= CU_MemWrite;
            IDEX_AluSrc <= CU_AluSrc;
            IDEX_RegWrite <= CU_RegWrite;
            IDEX_AluOp <= CU_AluOp;
            IDEX_regDstAddr1 <= IFID_Instr(20 downto 16);
            IDEX_regDstAddr2 <= IFID_Instr(15 downto 11);
            IDEX_signExt <= ID_signExt;
            IDEX_RegRs <= IFID_Instr(25 downto 21);
            IDEX_RegRt <= IFID_Instr(20 downto 16);
        end if;
    end process;
    
    --sign extension to 32 bits
    ID_signExt <= (x"FFFF" & IFID_Instr(15 downto 0)) when (IFID_Instr(15) = '1')
    	else (x"0000" & IFID_Instr(15 downto 0));
    
    --beq condition evaluation
    ID_beqResult <= '1' when
    	(br_output1 = br_output2) else '0';
       
    PCSrc <= ID_beqResult and CU_Branch;
    
    IFID_Flush <= PCSrc;
    
    ID_regOffset <= (ID_signExt(29 downto 0) & "00");
    
    ID_jumpAddr <= (IFID_PCInc4 + ID_regOffset);
----------------------------------------------------
-- EX stage
----------------------------------------------------
	--Forwarding unit instantiation
    unidadForwarding: FU Port map(
    	clk => Clk,
    	ForwardA => forwardA,
        ForwardB => forwardB,
        IDEX_regRs => IDEX_RegRs,
        IDEX_regRt => IDEX_RegRt,
        EXMEM_regRd => EXMEM_regDest,
        MEMWB_regRd => MEMWB_regDest,
        EXMEM_regWrite => EXMEM_RegWrite,
        MEMWB_regWrite => MEMWB_RegWrite
    );

	--EX_MEM segmentation register
    PipeEX_MEM : process(Clk,Reset)
    begin
    	if(Reset = '1') then
        	EXMEM_MemToReg <= '0';
           	EXMEM_MemWrite <= '0';
    		EXMEM_MemRead <= '0';
            EXMEM_regDest <= "00000";
            EXMEMAlu_result <= x"00000000";
            EXMEM_writeData <= x"00000000";
            EXMEM_RegWrite <= '0';
        elsif (rising_edge(Clk)) then
        	EXMEM_MemToReg <= IDEX_MemToReg;
            EXMEM_MemWrite <= IDEX_MemWrite;
    		EXMEM_MemRead <= IDEX_MemRead;
            EXMEM_regDest <= EXMEM_RegRd;
            EXMEMAlu_result <= Alu_result;
            EXMEM_writeData <= forwardB_result;
            EXMEM_RegWrite <= IDEX_RegWrite;
        end if;
    end process;
    
    EXMEM_RegRd <= IDEX_regDstAddr1 when(IDEX_RegDst = '0')
    	else IDEX_regDstAddr2;
        
    --Alu inputs with forwarding
    EXMEM_AluInput1 <= EXMEMAlu_result when(forwardA = "10")
    	else WB_writeData when(forwardA = "01")
    	else IDEX_data1rd;
        
    forwardB_result <= EXMEMAlu_result when(forwardB = "10")
        	else WB_writeData when(forwardB = "01")
        	else IDEX_data2rd;
        
    EXMEM_AluInput2 <= forwardB_result when (IDEX_AluSrc = '0')
    	else IDEX_signExt;
        
    aluMips: Alu
    Port map(
        a => IDEX_data1rd,
        b => EXMEM_AluInput2,
        control => AluCU_control,
        zero => EXMEM_zero,
        result => Alu_result
    );
        
    AluControl:
    process(IDEX_signExt(5 downto 0), IDEX_AluOp(1 downto 0))
    begin
    	case(IDEX_AluOp) is
          when "11" => --type R
              case(IDEX_signExt(5 downto 0)) is
                  when "100000" => AluCU_control <= "000"; --add
                  when "100010" => AluCU_control <= "001"; --sub
                  when "100100" => AluCU_control <= "010"; --and
                  when "100101" => AluCU_control <= "011"; --or
                  when "101010" => AluCU_control <= "100"; --slt
                  when others =>
              end case;
          when "00" => AluCU_control <= "000";--mem
          when "10" => AluCU_control <= "101";--lui
          when others => AluCU_control <= "000";--beq
        end case;
    end process;
    
----------------------------------------------------
-- MEM stage
----------------------------------------------------
    -- data memory write address
    D_Addr <= EXMEMAlu_result;
    --data to write
    D_DataOut <= EXMEM_writeData;
    --write and read enable signals
    D_RdStb <= EXMEM_MemRead;
    D_WrStb <= EXMEM_MemWrite;

	PipeMEM_WB : process(Clk,Reset)
    begin
    	if(Reset = '1') then
        	MEMWB_MemToReg <= '0';
            MEMWB_regDest <= "00000";
            MEMWB_writeData <= x"00000000";
            MEMWB_readData <= x"00000000";
            MEMWB_RegWrite <= '0';
       elsif (rising_edge(Clk)) then
        	MEMWB_MemToReg <= EXMEM_MemToReg;
            MEMWB_regDest <= EXMEM_regDest;
            MEMWB_writeData <= EXMEMAlu_result;
            MEMWB_readData <= D_DataIn;
            MEMWB_RegWrite <= EXMEM_RegWrite;
        end if;
    end process;
    
----------------------------------------------------
-- WB stage
----------------------------------------------------
	WB_writeData <= MEMWB_readData when (MEMWB_MemToReg = '1')
    	else MEMWB_writeData;
end processor_arq;
