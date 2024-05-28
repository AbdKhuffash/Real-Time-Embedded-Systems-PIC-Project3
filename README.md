# Simple Calculator 
This project aims to create a simple calculator capable of performing multiplication operations on integer numbers, with each number limited to two digits (ranging from 0 to 99). The hardware setup involves two PIC microcontrollers (16F877A), a push button (P) for input, and a 16×2 character LCD. The primary microcontroller is referred to as the master CPU, while the secondary microcontroller is the auxiliary CPU or co-processor. The push button and LCD are connected to the master CPU.

## System Behavior
Upon powering up, the LCD displays the message "Welcome to" on the first line and "multiplication" on the second line. This message blinks three times with a 1-second delay between blinks. After 3 seconds, the system proceeds to the next step.

The LCD prompts the user to enter the first number. The user increments the tenth part of the number by clicking the push button (P). Each click increments the tenth part by one until it reaches 9. After 2 seconds of inactivity, the tenth part becomes fixed, and the unit part of the first number is entered similarly.

After entering the unit value, if there's 2 seconds of inactivity, the first number becomes fixed, and the LCD displays the multiplication symbol "X".

The LCD prompts the user to enter the second number.

The user enters the second number in the same manner as the first, by incrementing the tenth part first, followed by the unit part.

Once the second number is entered, the system displays the "=" sign and proceeds to execute the multiplication operation

The master CPU sends the first number (tenth and unit parts) to the co-processor, followed by the unit digit of the second number. The co-processor performs the multiplication operation, ensuring there's no overflow. It returns the result (3 digits) to the master CPU in two steps: first the two most significant digits, then the least significant digit. Meanwhile, the master CPU multiplies the first number with the tenth digit of the second number. Upon receiving the output from the co-processor, the master CPU performs the correct addition to obtain the final multiplication result, displayed on the LCD.

The result remains on the LCD until the push button (P) is clicked again, prompting the system to return to step 2.
