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
