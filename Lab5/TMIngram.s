@ Filename: TMIngram.s
@ Author:   John Ingram
@ Purpose:  This program will simulate the one-day operation of a simple teller machine. The teller will dispense, upon request, $20, and $10 bills up to $200 total per customer. 
@The software will perform the following:
@Display a welcome message and instructions on how to make a valid withdraw. 
@Reject any invalid withdraw requests. Examples: must be a multiple of 10, and must not be greater than $200. Assume the customer can only enter numbers on a 10-digit keypad (0-9). 
@When filling a valid withdraw request disperse $20 bills first.
@When all the $20 bills are gone disperse $10 bills to fulfill the request.
@Limit the total number of withdraws to 10. Invalid requests do not count as a transaction. 
@If there are insufficient funds on hand for a withdraw inform the customer and ask them to enter a lower request. 
@Initial inventory of bills is 50 of each type (50 - $20 bills and 50 - $10 bills). Once the inventory of bills is depleted or maximum withdraws is reached display an ending message and stop the program.
@When the program ends print out: Total number of valid transactions, Number of $20s distributed, Number of $10s distributed, total amount of money distributed, remaining funds on hand. 
@The program will allow the entry of a secret code "-9" that when entered will display the following data:
@Inventory of $20 and $10 bills
@Remaining balance on hand
@Current number of transactions
@Total distributions made so far. 



@ 
@ History: 
@    Date       Purpose of change
@    ----       ----------------- 
@   4-Jul-2019  Changed this code from using the stack pointer to a 
@               locally declared variable. 
@  15-Sep-2019  Moved some code around to make it clearer on how to 
@               get the input value into a register. 
@   1-Oct-2019  Added code to check for user input errors from the 
@               scanf call.   
@  21-Feb-2019  Added comments about "%c" vs " %c" related to scanf.

@  For further History, find this file on https://github.com/John-Ingram/CS309
@
@ Use these commands to assemble, link, run and debug this program:
@    as -o TMIngram.o TMIngram.s
@    gcc -o TMIngram TMIngram.o
@    ./TMIngram ;echo $?
@    gdb --args ./TMIngram 

@ ***********************************************************************
@ The = (equal sign) is used in the ARM Assembler to get the address of a
@ label declared in the .data section. This takes the place of the ADR
@ instruction used in the textbook. 
@ ***********************************************************************

.equ READERROR, 0 @Used to check for scanf read error. 

.global main @ Have to use main because of C library uses. 

main:

startup:

@initialize remaining20s (r4) and remaining10s (r5) to 50.
@initialize totalTransactions (r6) to 0.
@initialize r8 to 10
@initialize r9 to 20

mov r4, #50
mov r5, #50
mov r6, #0
mov r8, #10
mov r9, #20

@*******************
prompt:
@*******************

@ Ask the user to enter a number.
 
   ldr r0, =strInputPrompt @ Put the address of my string into the first parameter
   bl  printf              @ Call the C printf to display input prompt. 

@*******************
get_input:
@*******************

@ Set up r0 with the address of input pattern.
@ scanf puts the input value at the address stored in r1. We are going
@ to use the address for our declared variable in the data section - intInput. 
@ After the call to scanf the input is at the address pointed to by r1 which 
@ in this case will be intInput. 

   ldr r0, =numInputPattern @ Setup to read in one number.
   ldr r1, =intInput        @ load r1 with the address of where the
                            @ input value will be stored. 
   bl  scanf                @ scan the keyboard.
   cmp r0, #READERROR       @ Check for a read error.
   beq readerror            @ If there was a read error go handle it. 
   ldr r1, =intInput        @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             @ Read the contents of intInput and store in r1 so that
                            @ it can be printed. 

@ Print the input out as a number.
@ r1 contains the value input to keyboard. 
confirm_number:

   @if thre number is -9 then go display the data.

   cmp r1, #-9
   beq display_data

   cmp r1, #0
   blt invalid_number        @ If the number is less than 0, go handle it.

   cmp r1, #200
   bgt invalid_number        @ If the number is greater than 200, go handle it.

   @ Check to see if there is enough money on hand to dispense the requested amount.
   mov r2, r5
   mul r2, r8, r2
   mov r3, r4
   mul r3, r9, r3
   add r2, r3
   cmp r1, r2
   bgt insufficient_funds    @ If there is not enough money on hand, go handle it.


   @ Check to see if the number is a multiple of 10.
      mov r2, r1 @ move the number into r2 so that I can be destructive.
   mod_loop:
      sub r2, r2, #10 @ subtract 10 from the r2.
      cmp r2, #0
      beq calculate_20s
      bgt mod_loop
      blt invalid_number

calculate_20s:
   @Calculate the number of $20 bills to dispense.
   mov r2, #0   @ r2 will be used to store the number of $20 bills to dispense.
   @r3 contains the amount of money on hand in 20$ bills.
   mov r3, r4
   mul r3, r9, r3
   twenty_loop:
      cmp r3, #0 @if the of 20$ bills is 0, then we are move to calculate the number of $10 bills.
      beq calculate_10s
      cmp r1, #20  @if the amount to dispense is less than 20$ move to calculate the number of $10 bills.
      blt calculate_10s
      sub r3, #20  @subtract 20$ from the amount of money on hand.
      sub r1, #20  @subtract 20$ from the amount to dispense.
      sub r4, #1   @subtract 1 $20 bill from the amount of $20 bills on hand.
      add r2, #1   @add 1 $20 bill to the number of $20 bills to dispense.
      b twenty_loop
      
      

calculate_10s:
   @calculate the number of $10 bills to dispense
   mov r7, #0   @r6 will be used to store the number of $10 bills to dispense.
   ten_loop:
      cmp r1, #0   @if the amount to dispense is 0, then we are done.
      beq successfull_withdrawl
      sub r1, #10  @subtract 10$ from the amount to dispense.
      sub r4, #1   @subtract 1 $10 bill from the amount of $10 bills on hand.
      add r7, #1   @add 1 $10 bill to the number of $10 bills to dispense.
      b ten_loop


successfull_withdrawl:
   @add 1 to the total number of transactions.
   add r6, #1
   @display the number of $20 and $10 bills dispensed.
   ldr r0, =strWithdrawal 
   mov r1, r2 @move the number of $20 bills to dispense to r1.
   mov r2, r7 @move the number of $10 bills to dispense to r2.

   bl printf  @call the C printf to display the number of $20 and $10 bills dispensed.

end_or_not:
   @if there is no more money on hand, then end the program.
   mov r1, r5
   mul r1, r9, r1
   mov r2, r4
   mul r2, r8,r1
   add r1, r1, r2
   cmp r1, #0
   beq display_data

   @if there have been 10 transactions, then end the program.
   cmp r6, #10
   beq display_data

  

@*******************
display_data:
@*******************
@Display Inventory of $20 and $10 bills.
   ldr r0, =strNumberOfBillsPattern
   mov r1, r4
   mov r2, r5
   bl  printf
 
@Display Remaining balance on hand.
   ldr r0, =strRemainingBalancePattern
   mov r1, r5
   mul r1, r9,r1
   mov r2, r4
   mov r10, r2
   mul r2, r8, r2
   add r1, r1, r2
   mov r7, r1   @ r7 contains the value of the remaining balance for later use in the total distributions.
   bl  printf

@Display Current number of transactions.
   ldr r0, =strNumberOfTransactionsPattern
   mov r1, r6
   bl  printf

@Display Total distributions made so far.
   ldr r0, =strTotalDistributionsPattern
   mov r1, #1500
   sub r1, r1, r7
   bl  printf

@if there is no more money on hand, then end the program.
   cmp r7, #0
   beq myexit

@if there have been 10 transactions, then end the program.
   cmp r6, #10
   beq myexit

@Go back to the prompt.
   b   prompt


@*******************
invalid_number:
@*******************
   ldr r0, =strInvalidNumber
   bl  printf
   b   prompt

@*******************
insufficient_funds:
@*******************
   ldr r0, =strInsufficientFunds
   bl  printf
   b   prompt



@***********
readerror:
@***********
@ Got a read error from the scanf routine. Clear out the input buffer then
@ branch back for the user to enter a value. 
@ Since an invalid entry was made we now have to clear out the input buffer by
@ reading with this format %[^\n] which will read the buffer until the user 
@ presses the CR. 

   ldr r0, =strInputPattern
   ldr r1, =strInputError   @ Put address into r1 for read.
   bl scanf                 @ scan the keyboard.
@  Not going to do anything with the input. This just cleans up the input buffer.  
@  The input buffer should now be clear so get another input.

   b prompt

@*******************
myexit:
@*******************
@ End of my code. Force the exit and return control to OS

   mov r7, #0x01 @ SVC call to exit
   svc 0         @ Make the system call. 

.data

@ Declare the strings and data needed

.balign 4
strInputPrompt: .asciz "Welcome to the TMIngram program!\nEnter how much you want to withdraw. Note that the amount must be a multiple of 10 under 200: "

.balign 4
strInvalidNumber: .asciz "The amount requested is invalid. Please enter a positive number divisible by 10 and less than 200.\n"

.balign 4
strInsufficientFunds: .asciz "There is not enough money on hand to dispense the requested amount. Please try withdrawing less money.\n"

.balign 4
strWithdrawal: .asciz "\n\nYou have withdrawn %d $20 bills and %d $10 bills\n"

.balign 4
strNumberOfBillsPattern: .asciz "Number of $10 bills: %d\nNumber of $20 bills: %d\n"

.balign 4
strRemainingBalancePattern: .asciz "Remaining balance on hand: $%d\n"

.balign 4
strNumberOfTransactionsPattern: .asciz "Number of transactions: %d\n"

.balign 4
strTotalDistributionsPattern: .asciz "Total distributions made so far: $%d\n\n"


@ Format pattern for scanf call.

.balign 4
numInputPattern: .asciz "%d"  @ integer format for read. 

.balign 4
strInputPattern: .asciz "%[^\n]" @ Used to clear the input buffer for invalid input. 

.balign 4
strInputError: .skip 100*4  @ User to clear the input buffer for invalid input. 

.balign 4
intInput: .word 0   @ Location used to store the user input. 

@ Let the assembler know these are the C library functions. 

.global printf
@  To use printf:
@     r0 - Contains the starting address of the string to be printed. The string
@          must conform to the C coding standards.
@     r1 - If the string contains an output parameter i.e., %d, %c, etc. register
@          r1 must contain the value to be printed. 
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed. 

.global scanf
@  To use scanf:
@      r0 - Contains the address of the input format string used to read the user
@           input value. In this example it is numInputPattern.  
@      r1 - Must contain the address where the input value is going to be stored.
@           In this example memory location intInput declared in the .data section
@           is being used.  
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed.
@ Important Notes about scanf:
@   If the user entered an input that does NOT conform to the input pattern, 
@   then register r0 will contain a 0. If it is a valid format
@   then r0 will contain a 1. The input buffer will NOT be cleared of the invalid
@   input so that needs to be cleared out before attempting anything else.
@
@ Additional notes about scanf and the input patterns:
@    1. If the pattern is %s or %c it is not possible for the user input to generate
@       and error code. Anything that can be typed by the user on the keyboard
@       will be accepted by these two input patterns. 
@    2. If the pattern is %d and the user input 12.123 scanf will accept the 12 as
@       valid input and leave the .123 in the input buffer. 
@    3. If the pattern is "%c" any white space characters are left in the input
@       buffer. In most cases user entered carrage return remains in the input buffer
@       and if you do another scanf with "%c" the carrage return will be returned. 
@       To ignore these "white" characters use " $c" as the input pattern. This will
@       ignore any of these non-printing characters the user may have entered.
@

@ End of code and end of file. Leave a blank line after this.
