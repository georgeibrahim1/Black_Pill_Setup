    AREA MYCODE, CODE, READONLY
    IMPORT CONFIGURE_PORTS
    IMPORT TFT_WriteCommand
    IMPORT TFT_WriteData
    IMPORT TFT_Init
    IMPORT  TFT_DrawImage
    IMPORT  TFT_Filldraw4INP
    IMPORT  GET_state
    IMPORT  delay

__main FUNCTION

    BL CONFIGURE_PORTS
    BL TFT_Init

    ;WRITE YOUR CODE HERE

    ;-----------------------
    ; Test Code SNIPPT
    ;
    ; CMP R10 , #X
    ; BL TEST1
    ;
    ; CMP R10 , #Y
    ; BL TEST2
    ;
    ; CMP R10 , #Z
    ; BL TEST3
    ;
    ;
    ;TEST1
    ;
    ;
    ;TEST2
    ;
    ;
    ;TEST3
    ;
    ;-----------------------

    BL GET_state

    CMP R10 , #1




    ENDFUNC
	
	END