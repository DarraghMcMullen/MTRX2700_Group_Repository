# MTRX2700 Assignment 1 - Group 2
Chester Burns<br/>Greta Bennett<br/>Wei Ming<br/>Darragh McMullen

## Roles & Responsibilities

### Chester:
- Exercise 3 (with Greta)
- README info for exercise 3 & 4
- Exercise 4 - parts 1-3
- Testing code on hardware
- Compiling README file

### Greta:
- Exercise 3 (with Chester)
- Exercise 4 - part 4
- Keeping minutes + agendas for all meetings

### Wei:
- Exercise 1
- README info for Exercise 1

### Darragh:
- Exercise 2
- GitHub repository hosting & management
- README info for Exercise 2

## Exercise 1
**Code Info**\
For exercise 1, the code can be broken down into multiple parts:
1.	Finding the input string length
2.	Locating the task which the program is currently performing
3.	task 1 criteria, implementation (print out the output to all lower cases)
4.	task 2 criteria, implementation (print out the output to all upper cases)
5.	task 3 criteria, implementation (print out letters before space and first letter to upper cases)
6.	task 4 criteria, implementation (print out first letter from the string to upper cases)
7.	making letters to upper cases
8.	making letters to lower cases
9.	printout letter without any changes

**User Instructions**\
The program will automatically print out all four tasks when you run it, which is stored, starts from address 1000. User must type in spc$1000 to view it.

**Testing Procedures**
Testing is done by running the program and observe if the program did what is expected. Else, if the program isn’t doing what is expected to do, step through it and observe which part did it went wrong and change accordingly.

- Test different strings, change punctuation, case and length of strings to test all functionalities.



## Exercise 2

**Code Info**\
The program for exercise 2 scrolls a string of ASCII text across the Dragon12's 7-segment displays based on an automatic timer or user input depending on the value of SCROLL_MODE
The program can display all ASCII characters from $20 "space" to $7E "~"
Input SW2 is polled at a rate of 10kHz. SW2 is polled using a debounce routine

For exercise 2, the code consists of 4 basic functions, each composed of many smaller routines
1. driving the 7-segment displays
2. converting ASCII codes into 7-segment display digits using a look-up table
3. detecting user input on SW2 (PORT H)
4. scrolling a string across the display


1. The 4 7-segment displays are written to sequentially using multiplexing to display 4 characters at once.
   The characters to display on the displays are stored in a 4-element memory vector which is iterated over and written to the display continuously.
   The displays are masked sequentially during the multiplexing process based on values stored in a 4-element look-up table.

2. Strings are stored as vectors containing ASCII codes, these are converted into LUT locations using an offset of $20, as this corresponds to the 1st entry of the LUT.
   The LUT contains the data to be written to the display to produce the ASCII character

3. User input is available on SW2 via Port H. The program checks if the switch is pressed, if so, it waits 20ms and checks if it is still pressed.
   This provides a rudimentary debouncing routine.

4. A longer string of text may be scrolled across the displays based on a timer or user input, this can be changed by altering the value of "SCROLL_MODE" variable
   The currently displayed string to moved left across the display, and the next character of the longer string is moved in from the right



**User Instructions**\
Before running the program, ensure that the DIP switches on PORTH are all off
With SCROLL_MODE set to 0, the user can scroll a string (stored in the memory location STRING) of text across the displays 1 character at a time by pressing SW2
With SCROLL_MODE set to 1, the program will automatically scroll the string across the displays at a set rate, in this mode, SW2 will still work to scroll the text manually
The string can be changed by editing STRING in the code, ensure you also change STRING_LEN to match the length of the new string


**Testing Procedures**\
If the string is scrolling too fast it will appear illegible, this may be due to SW2 being closed, ensure SW2 and relevant DIP switch are set open
If the string does not scroll, the program may have halted or the input on SW2 is not being detected, ensure SCROLL_MODE is set correctly for the test case, and ensure the program hasn't halted or hung

## Exercise 3
**Code Info**\
The program will perform one of two functions, depending on user input.

1. Transmit a string in memory to the serial interface at a rate of 1 word/second
2. Receive a string from the serial interface, and transmit that string back to the serial
DIP Switch PH0 determines task type in subroutine 'task_number'

- When PH0 is set (up) --> prints word in memory to serial 1 at ~1 second intervals
  1. Each character in string is loaded into A register
  2. Characters are loaded into the SCI1 data register
  3. This process stops once a null character is encountered
  4. 1 second delay triggered, and the program goes back to the beginning


- When PH0 is not set (down) --> characters are inputted through serial 1, and repeated back out of the serial interface as 'enter' is received
  1. The RDRF register is polled
  2. When RDRF is set, the character in the data register is sent to the A register
  3. This character is then stored at the memory location pointed to by the X index
  4. This sequence will loop until a carriage return character is encountered
  5. The string will have a newline and null character added to the end
  6. The recently received (now complete) string will then be transmitted back to the serial interface following the procedure from the first task (see above)

**User Instructions**
1. Run the program
2. Establish connection to serial interface 1 with baud rate 9600 (flow control: none)
3. Set DIP switch PH0 to achieve desired function, up (set) will print a string to the serial interface at 1 second intervals.  If the switch is down, the program will function as follows:
  - Enter characters into serial interface
  - Press enter when your desired string is finished
  - Repeat once your previous string is printed back



**Testing Procedures**
- Monitor the input string memory location through the debugger terminal with the following command, as you type into the serial monitor in mode 2 (PH0 not set), the letters should appear in that memory location.
      spc READ

- To ensure the first function is correct (printing a word at an interval), run the following command, and compare the transmitted string to that in the memory location.
      spc WORD

- Test different types of strings, i.e. test with different capitalisations, punctuations and other characters.


## Exercise 4
**Code Info**\
The program will accept a string through serial interface 1, and convert it according to the state of DIP switch PH0.\
In the down position, the program will convert all characters to uppercase.  In the up position, the program will convert the character immediately following a space into uppercase, and all other characters lowercase.

There are 4 primary subroutines/functions of this program:
1. Receive data from serial interface 1, and write data to memory
2. Take a pointer to a memory location containing a string, and make adjustments to it
3. Use an external input (DIP switch) to determine the type of adjustments
4. Transmit the newly edited string back into the serial interface.

This code integrates parts of each exercise into one program.\
The functions for receiving and transmitting serial data can be found in exercise 3, the functions for adjusting the strings can be found in exercise 1, and the function for addressing the DIP switch can be found in exercise 2.

**User Instructions**
1. Run the program
2. Establish connection to serial interface 1 with baud rate 9600 (flow control: none)
3. Enter characters into serial interface.  Set DIP switch PH0 to up/down to achieve desired functions


**Testing Procedures**
- Test different types of strings, i.e. test with different capitalisations, punctuations and other characters.
- Locate memory for input and output by running the following commands in the debugger
        spc READ
        spc WRITE
