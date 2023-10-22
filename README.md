# Assemble Stopwatch Project

## Authors

- Darren Luck (A00964037)
- Eric Hemming (A01290673)
- Kiefer Thom (A01284069)

## Project Description

This project implements a simple stopwatch program written in x86 assembly language and was created for our Computer Organization and Architecture course. The stopwatch program records and displays the elapsed time in seconds between the start of the program and each lap time. Additionally, it keeps track of the total number of laps and displays the fastest lap recorded during the program's execution.

## How to Compile

1. Ensure you have NASM (Netwide Assembler) and LD (Linker) installed on your system.
2. Open a terminal or command prompt in the directory containing the `timer2.asm` file.
3. Compile the assembly code using the following command: `nasm -f elf timer2.asm`

Note: On 64-bit systems, you may need to add the `-m elf_i386` option after `ld` to generate a 32-bit executable.

4. Link the compiled object file using the following command: `ld -m elf_i386 timer2.o -o timer`


## How to Run

After successful compilation, you can execute the stopwatch program using the following command: `./timer`


## Function Explanation

### `iprint` Function

The `iprint` function is an integer printing function that converts a given integer to its ASCII representation and prints it character by character.

### `slen` Function

The `slen` function calculates the length of a given null-terminated string (C-style string) and returns the length as an integer.

### `sprint` Function

The `sprint` function is a string printing function that takes a null-terminated string as input and prints it character by character.

## Program Flow

1. The program starts by displaying a start message and the instructions to use the stopwatch.

2. The stopwatch loop is then initiated, which waits for user input. If the user inputs 'l', it records a lap time by capturing the current timestamp and calculates the time difference since the last lap. The total number of laps is also incremented.

3. If the user inputs 'q', the program exits and displays the total time elapsed, the total number of laps, and the fastest lap recorded during the program's execution.

4. The program uses system calls to interact with the kernel for reading user input, obtaining timestamps, and printing messages.

## Data Section

The data section contains various constant strings used in the program, including start messages, lap messages, exit messages, and others. It also reserves memory space (using `.bss`) to store user input, timestamps, total laps, and the fastest lap recorded during the program's execution.

## Running the Program

1. Upon running the program, the stopwatch will display a start message and the instructions to use the stopwatch.

2. Press 'l' to record a lap time. The program will calculate and display the time since the last lap and the total number of laps recorded.

3. Press 'q' to exit the program. The program will display the total time elapsed, the total number of laps, and the fastest lap recorded.

## Note

Please ensure you have a 32-bit x86 architecture system to run this program successfully. If you are using a 64-bit system, you may need to modify the `ld` command to include the `-m elf_i386` option to generate a 32-bit executable.
