# Segmented-Mips-Processor
The denomination MIPS refers to a family of RISC processors developed by MIPS Technologies. The following project will be based on the version detailed by David A. Patterson and John L. Hennessy in the book "Computer Organization and Design".

## Characteristics:
The segmented version of the MIPS processor is based in the technique known as "pipelining" whose carachteristic is to divide its execution process in stages that are common to all instructions in order to: allow the execution of several instructions concurrently and avoid having idle components.
Specifically this instance of the MIPS processor consists of 5 stages and a Harvard architecture (separate storage and signal pathways for data and instructions).

### Segmentation Stages:
- Instruction Fetching (IF): next instruction to execute is fetched from memory, which is pointed by the Progam Counter (PC).
- Instruction Decoding (ID):
- Execution (EX):
- Memory Access (MEM):
- Write Back (WB):
