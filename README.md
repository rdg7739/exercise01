exercise01
==========

#nasm exercise

This is a simple ISBN error-detecting program.
The 10-digit ISBN number is a simple example of an error-detecting code. 
(ISBN stands for "International Standard Book Number" and is used as a unique identifier for books.) 
Not all 10-digit numbers are valid ISBN numbers. 

If a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, is a valid ISBN number, 
then the digits must satisfy the condition that 
 10*a0 + 9*a1 + 8*a2 + 7*a3 + 6*a4 + 5*a5 + 4*a6 + 3*a7 + 2*a8 + a9
is divisible by 11. 

For example, 3201541974 is a valid ISBN number because
10*3 + 9*2 + 8*0 + 7*1 + 6*5 + 5*4 + 4*1 + 3*9 + 2*7 + 4 = 154
and 154 = 11 * 14. 

On the other hand, 0457773706 is not a valid ISBN number because
10*0 + 9*4 + 8*5 + 7*7 + 6*7 + 5*7 + 4*3 + 3*7 + 2*0 + 6 = 241
and 241 is not divisible by 11.

