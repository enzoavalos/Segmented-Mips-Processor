# Segmented-Mips-Processor
The denomination MIPS refers to a family of RISC processors developed by MIPS Technologies. The following project will be based on the version detailed by David A. Patterson and John L. Hennessy in the book "Computer Organization and Design".

## About the project
This project consisted in the implementation of the MIPS processor using the hardware description language VHDL, and it was developed for "Computer Architecture 1" of Systems Engineering.

## How to run it
To execute the program, click the following [link](https://edaplayground.com/x/fTGt) which will redirect you to the Eda Playground website where the whole project is already laid out for you, everything left to do is press the ***Run*** button in the top left corner.   
Once the program is successfully compiled and executed, a new window will be prompted, giving you the possibility to inspect the values of all the signals involved in the processor and its components across the whole execution of the program.

## Characteristics
The segmented version of the MIPS processor is based in the technique known as "pipelining" whose characteristic is to divide its execution process in stages that are common to all instructions in order to: allow the execution of several instructions concurrently and avoid having idle components.
Specifically, this instance of the MIPS processor consists of 5 stages and a Harvard architecture (separate storage and signal pathways for data and instructions).

### Segmentation Stages
- Instruction Fetching (IF): next instruction to execute is fetched from memory, which is pointed by the Program Counter (PC). The next value of the PC will either be: the previous PC value + 0x4 (due to instructions being 4 bytes long) or a jump address calculated in the ID stage.
- Instruction Decoding (ID): the instruction fetched from memory is decoded, which consists in executing the following tasks in a combinational and concurrent manner: generation of the corresponding control signals, register file read, sign extension to 32 bits of the 16 bits immediate field coming from the instruction, evaluation of jump condition (beq instruction) and calculation of the effective jump address.
- Execution (EX): execution of the arithmetic-logic operations determined by the instruction, through the ALU (arithmetic logic unit), controlled by the ALU Control Unit and the "funct" field of the instruction (last 6 bits). The ALU input operands can be the following:
   - Input 1: data read from the register bank, data forwarded from the EX stage or data forwarded from the MEM stage.
   - Input 2: same as input 1, but it adds the possibility of the operand being an immediate value originally included in the instruction (last 16 bits), sign extended to 32 bits.
- Memory Access (MEM): access to the data memory both for writing (sw instructions) and reading (lw instructions).
- Write Back (WB): writings to the bank register are made in this stage, where the data to be written either comes from the result of an ALU operation, or from the data memory. The destination register is determined in the EX stage, discerning between the bits [20..16] or [15..11] of the instruction depending on its type (type R or I).

## Improvements
### Forwarding Unit
A problem brought by segmentation are data dependencies or hazards, in this case RAW (Read after Write) dependencies. In order to solve this, a technique called "operand forwarding" is applied.  

A Forwarding Unit (FU) was added for the detection and resolution of this type of dependencies, which scope is of 2 instructions with the current write configuration of the register bank (falling edge of clock signal). Because of this, RAW dependencies can occur in EX, MEM or both stages simultaneously. The FU verifies if the write destination register of the EX and MEM stages match any of the registers to be read in the ID stage, in which case, the data to be written is forwarded to the corresponding ALU entry. In the case that RAW dependencies occurred in both EX and MEM stages, the data present in the EX stage is prioritized, given that it belongs to the immediately preceding instruction.  

The application of this improvement results in a gain of 2 clock cycles, because in the presence of a data dependency without this strategy, the pipeline should be stopped during 2 cycles to allow the required data to reach the WB stage in order to have the data available in the corresponding register.   
Nevertheless, there is a special case where forwarding cannot help eliminate hazards, and that is when an instruction tries to read a register following a load instruction that writes the same register. In this case, the loss of 1 cycle is unavoidable because to have the data available for forwarding, the instruction must reach the MEM stage.

### Branch execution in ID stage
Conditional jump instructions generate control hazards and for better dealing with them, all the execution process of the branch instruction was moved from the MEM to the ID stage, thus fewer instructions need to be flushed.

The process is as it follows: the corresponding control signals are generated and concurrently the condition of the jump instruction (comparing both register bank outputs) and the effective jump address are calculated. Then with a logic And gate that receives as input the result of the comparison and a branch control signal, the next instruction to be fetched is determined between the calculated jump address and the next current instruction. When the jump is effective, the instruction already loaded in the IF stage is incorrect, thus it needs to be discarded and the segmentation register flushed, losing in this process 1 clock cycle.

With this configuration change, a gain of 2 clock cycles is obtained, because with the previous configuration (Branch execution in MEM stage), if the jump turned out to be effective, a loss of 3 cycles was made.

## Final Implementation
![image](https://user-images.githubusercontent.com/82390064/177582632-18d01d1b-b003-4eaa-abf4-4f2c5df3067b.png)
