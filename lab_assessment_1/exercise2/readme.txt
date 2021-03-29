The program for exercise 2 scrolls a string of ASCII text across the Dragon12's 7-segment displays based on an automatic timer or user input depending on the value of SCROLL_MODE
The program can display all ASCII characters from $20 "space" to $7E "~"
Input SW2 is polled at a rate of 10kHz. SW2 is polled using a debounce routine

For exerice 2, the code consists of 4 basic functions, each composed of many smaller routines
1. driving the 7-segment displays
2. converting ASCII codes into 7-segment display digits using a look-up table
3. detecing user input on SW2 (PORT H)
4. scrolling a string across the display

1. The 4 7-segment displays are written to sequentially using multiplexing to display 4 characters at once.
   The characters to display on the displays are stored in a 4-element memory vector which is iterated over and written to the display continuously.
   The displays are masked sequentially during the multiplexing process based on values stored in a 4-element look-up table.

2. Strings are stored as vectors containing ASCII codes, these are converted into LUT locations using an offset of $20, as this corresponds to the 1st entry of the LUT.
   The LUT contains the data to be written to the display to produce the ASCII character

3. User input is available on SW2 via Port H. The program checks if the switch is pressed, if so, it waits 20ms and checks if it is still pressed.
   This provides a rudimentary deboucing routine.

4. A longer string of text may be scrolled across the displays based on a timer or user input, this can be changed by altering the value of "SCROLL_MODE" variable
   The currently displayed string to moved left across the display, and the next character of the longer string is moved in from the right



USAGE

Before running the program, ensure that the DIP switches on PORTH are all off
With SCROLL_MODE set to 0, the user can scroll a string (stored in the memory location STRING) of text across the displays 1 character at a time by pressing SW2
With SCROLL_MODE set to 1, the program will automatically scroll the string across the displays at a set rate, in this mode, SW2 will still work to scroll the text manually
The string can be changed by editing STRING in the code, ensure you also change STRING_LEN to match the length of the new string



TESTING

If the string is scrolling too fast it will appear illegible, this may be due to SW2 being closed, ensure SW2 and relevant DIP switch are set open
If the string does not scroll, the program may have halted or the input on SW2 is not being detected, ensure SCROLL_MODE is set correctly for the test case, and ensure the program hasn't halted or hung
