@ Filename: SBIngram.s
@ Author:   John Ingram
@ Author email: jsi0004@uah.edu
@ Course: CS309-01 Fall 2021
@ Purpose:  This program will Prompt for the user to enter a number (integer),
@           If the entered number is <100 print: "The input number is less than 100."
@           If the entered number is >=100 print: "The input number is greater than or equal to 100."
@           Prompt for the user to enter a single character. 
@           If the entered character is lower case (a..z) print: "Lower case letter entered."
@           If the entered character is upper case (A..Z) print: "Upper case letter entered."
@           Otherwise print: "Special character entered."
@           Return control to the operating system. 
@ Use these commands to assemble, link, run and debug this program:
@    as -o SBIngram.o SBIngram.s
@    gcc -o SBIngram SBIngram.o
@    ./SBIngram ;echo $?
@    gdb --args ./SBIngram 

.text
.balign 4
.equ READERROR, 0   @Used to check for scanf read error. 
.equ NUMBER, 1      @Used to check for number.
.equ CHARACTER, 2   @Used to check for character.

.global main        @ Have to use main because of C library uses. 

main:

@*******************
prompt:
@*******************

@ Ask the user to enter a number.
 
    ldr r0, =strNumInputPrompt   @ Put the address of my string into the first parameter
    bl  printf                   @ Call the C printf to display input prompt. 

@*******************
get_input:
@*******************

@ Set up r0 with the address of input pattern.
@ scanf puts the input value at the address stored in r1. We are going
@ to use the address for our declared variable in the data section - intInput. 
@ After the call to scanf the input is at the address pointed to by r1 which 
@ in this case will be intInput. 
    @ldr r5, #1          @ Set up r5 as a flag to indicate the type of input.

    ldr r0, =numInputPattern @ Setup to read in one number.
    ldr r1, =intInput        @ load r1 with the address of where the
                             @ input value will be stored. 
    bl  scanf                @ scan the keyboard.
    cmp r0, #READERROR       @ Check for a read error.
    beq readerror            @ If there was a read error go handle it. 
    ldr r1, =intInput        @ Have to reload r1 because it gets wiped out. 
    ldr r1, [r1]             @ Read the contents of intInput and store in r1 so that
                             @ it can be printed. 

@ Check if the number is less than 100.
@ r1 contains the value input to keyboard. 
    cmp r1, #100
    bge greater_than_100
    ldr r0, =strNumLessThan
    b   print_nums


@*******************
greater_than_100:
@*******************
    ldr r0, =strNumGreaterThan @ Load the address of the string to print.
    b   print_nums

@*******************
print_nums:
@*******************
    bl printf                    @ Call the C printf to display the string.

@*******************
char_prompt:
@*******************

@ Ask the user to enter a number.
 
    ldr r0, =strCharInputPrompt @ Put the address of my string into the first parameter
    bl  printf              @ Call the C printf to display input prompt. 

@*******************
get_char_input:
@*******************

@ Set up r0 with the address of input pattern.
@ scanf puts the input value at the address stored in r1. We are going 
@ to use the address for our declared variable in the data section - intInput. 
@ After the call to scanf the input is at the address pointed to by r1 which 
@ in this case will be intInput. 
    @ldr r5, #2         @ Set up r5 as a flag to indicate the type of input.

    ldr r0, =charInputPattern  @ Setup to read in one number.
    ldr r1, =intInput          @ load r1 with the address of where the
                               @ input value will be stored. 
    bl  scanf                  @ scan the keyboard.
    cmp r0, #READERROR         @ Check for a read error.
    beq readerror              @ If there was a read error go handle it. 
    ldr r1, =intInput          @ Have to reload r1 because it gets wiped out. 
    ldr r1, [r1]               @ Read the contents of intInput and store in r1 so that
                               @ it can be printed. 


@*******************
evaluate_char:
@*******************
@ If the value is smaller than 'A' 0x41 then it is a special character
    cmp r1, #0x41
    blt print_special
@ If the value is smaller than or equal to 'Z' 0x5A then it is an uppercase letter
    cmp r1, #0x5A
    ble print_uppercase
@ If the value is less than 'a' 0x61 then it is a special character
    cmp r1, #0x61
    blt print_special 
@ If the value is less than or equal to 'z' 0x7A then it is a lowercase letter
    cmp r1, #0x7A
    ble print_lowercase
@ If it made it here than it is a special character. 
    b print_special

@*******************
print_lowercase:
@*******************
    ldr r0, =strLowerCaseLetter
    b   print_chars

@*******************
print_uppercase:
@*******************
    ldr r0, =strUpperCaseLetter
    b   print_chars

@*******************
print_special:
@*******************
    ldr r0, =strSpecialChar
    b   print_chars

@*******************
print_chars:
@*******************
    bl printf
    b myexit

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

    cmp r5, #NUMBER          @ Check if the input was a number.
    beq get_input            @ If it was a number go get another number.

    b get_char_input         @ If it was a character go get another character.

@*******************
myexit:
@*******************
@ End of my code. Force the exit and return control to OS

    mov r7, #0x01 @ SVC call to exit
    svc 0         @ Make the system call. 

.data

@ Declare the strings and data needed

.balign 4
strNumInputPrompt: .asciz "Input the number: \n"

.balign 4
strCharInputPrompt: .asciz "Input the character: \n"

.balign 4
strNumLessThan: .asciz "The input number is less than 100.\n"   

.balign 4
strNumGreaterThan: .asciz "The input number is greater than or equal to 100.\n"

.balign 4
strLowerCaseLetter: .asciz "Lower case character entered.\n"

.balign 4
strUpperCaseLetter: .asciz "Upper case character entered.\n"

.balign 4
strSpecialChar: .asciz "Special character entered.\n"

@ Format pattern for scanf call.

.balign 4
numInputPattern: .asciz "%d"  @ integer format for read. 

.balign 4
charInputPattern: .asciz "%s"  @ character format for read.

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
