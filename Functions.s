    AREA MYDATAS, DATA, READONLY
RCC_BASE        EQU     0x40023800
RCC_AHB1ENR     EQU     RCC_BASE + 0x30

GPIOA_BASE     EQU     0x40020000
GPIOA_MODER    EQU     GPIOA_BASE + 0x00
GPIOA_SPEEDR   EQU     GPIOA_BASE + 0x08
GPIOA_OTYPER   EQU     GPIOA_BASE + 0x04
GPIOA_PUPDR    EQU     GPIOA_BASE + 0x0C
GPIOA_IDR      EQU     GPIOA_BASE + 0x10
GPIOA_ODR      EQU     GPIOA_BASE + 0x14

GPIOB_BASE     EQU     0x40020400
GPIOB_MODER    EQU     GPIOB_BASE + 0x00
GPIOB_SPEEDR   EQU     GPIOB_BASE + 0x08
GPIOB_OTYPER   EQU     GPIOB_BASE + 0x04
GPIOB_PUPDR    EQU     GPIOB_BASE + 0x0C
GPIOB_IDR      EQU     GPIOB_BASE + 0x10
GPIOB_ODR      EQU     GPIOB_BASE + 0x14

GPIOC_BASE     EQU     0x40020800
GPIOC_MODER    EQU     GPIOC_BASE + 0x00
GPIOC_SPEEDR   EQU     GPIOC_BASE + 0x08
GPIOC_OTYPER   EQU     GPIOC_BASE + 0x04
GPIOC_PUPDR    EQU     GPIOC_BASE + 0x0C
GPIOC_IDR      EQU     GPIOC_BASE + 0x10
GPIOC_ODR      EQU     GPIOC_BASE + 0x14

INTERVAL       EQU     0x566004

;--- TFT control-line masks ---
TFT_RST        EQU     (1 << 8)
TFT_RD         EQU     (1 << 10)
TFT_WR         EQU     (1 << 11)
TFT_DC         EQU     (1 << 12)
TFT_CS         EQU     (1 << 15)

    AREA MYCODE, CODE, READONLY
    EXPORT CONFIGURE_PORTS
    EXPORT TFT_WriteCommand
    EXPORT TFT_WriteData
    EXPORT TFT_Init
    EXPORT  TFT_DrawImage
    EXPORT  TFT_Filldraw4INP
    EXPORT  GET_state
    EXPORT  delay


;-----------------------------------------
; Initially call in main function
;-----------------------------------------
CONFIGURE_PORTS FUNCTION
    PUSH{R0-R1,LR}
    
    ;SET the clock of  C B A  PORTS
    LDR R0, =RCC_AHB1ENR
    LDR R1, [R0]
    ORR R1, R1 , #0x07 ;00000111 -> HGFEDCBA 
    STR R1, [R0]

;-----------------------------------------
; PART A
;-----------------------------------------

    ;SET THE PORT A AS OUTPUT 
    LDR R0, =GPIOA_MODER
    LDR R1, =0x55555555  ;0101010101---01 -> OUTPUT ;WHY LDR NOT MOV ? MOV CAN'T MOVE LARGER THAN NON-ZERO 16 BITS 
    STR R1, [R0]
    
    ;SET THE SPEED OF THE PORT A as HIGH SPEED
    LDR R0, =GPIOA_SPEEDR
    LDR R1, =0xFFFFFFFF  ;1111111--11 -> High Speed
    STR R1, [R0]

    ;PUSH/PULL
	LDR R0, =GPIOA_OTYPER
	MOV R1, #0x00000000
	STR R1, [R0]

    ;SET THE PUPDR OF THE PORT A as PULL-UP
 	LDR R0, =GPIOA_PUPDR
 	LDR R1, =0x55555555
 	STR R1, [R0]

;-----------------------------------------
; PART B
;-----------------------------------------

    ;SET THE PORT B AS INPUT  
 	LDR R0, =GPIOB_MODER             
 	MOV R1, #0x00000000    ;00000--00 -> INPUT
 	STR R1, [R0]

    ;SET THE SPEED OF THE PORT B as HIGH SPEED
 	LDR R0, =GPIOB_SPEEDR
 	LDR R1, =0xFFFFFFFF
 	STR R1, [R0]

	;SET THE TYPE OF PORT B AS PUSH-PULL
 	LDR R0, =GPIOB_OTYPER
 	MOV R1, #0x00000000
 	STR R1, [R0]

	;SET THE PUPDR OF THE PORT B as PULL-UP
 	LDR R0, =GPIOB_PUPDR
 	LDR R1, =0x55555555
 	STR R1, [R0]

;-----------------------------------------
; PART C
;-----------------------------------------

    ;SET THE PORT C AS OUTPUT 
    LDR R0, =GPIOC_MODER
    LDR R1, =0x55555555  ;0101010101---01 -> OUTPUT 
    STR R1, [R0]

    ;SPEED PORT C
	LDR R0, =GPIOC_SPEEDR
	LDR R1, =0xFFFFFFFF
	STR R1, [R0]

    ;PUSH/PULL
	LDR R0, =GPIOC_OTYPER
	MOV R1, #0x00000000
	STR R1, [R0]

    ;SET THE PUPDR OF THE PORT C as PULL-UP
 	LDR R0, =GPIOC_PUPDR
 	LDR R1, =0x55555555
 	STR R1, [R0]

    POP{R0-R1,PC}
    ENDFUNC



;-----------------------------------------
; R0 CINTAINS THE COMMAND
;-----------------------------------------
TFT_WriteCommand FUNCTION
	PUSH {R1-R2,LR}

	; Set CS low
	LDR R1, =GPIOA_ODR
	LDR R2, [R1]
	BIC R2, R2, #TFT_CS ;BIC CLEARS THE COORESPONDING ONE BITS IN #TFT_CS  
	STR R2, [R1]

	; Set DC RS low for command
	BIC R2, R2, #TFT_DC
	STR R2, [R1]

	; Set RD high not used in write operation
	ORR R2, R2, #TFT_RD
	STR R2, [R1]

	; Send command R0 contains command
	BIC R2, R2, #0xFF   ; Clear data bits PA0-PA7
	AND R0, R0, #0xFF   ; Ensure only 8 bits
	ORR R2, R2, R0      ; Combine with control bits
	STR R2, [R1]


	; Generate WR pulse low > high
	BIC R2, R2, #TFT_WR
	STR R2, [R1]
	ORR R2, R2, #TFT_WR
	STR R2, [R1]

	; Set CS high
	ORR R2, R2, #TFT_CS
	STR R2, [R1]

	POP {R1-R2,PC}
	ENDFUNC

;-----------------------------------------
; TFT Write Data R0 = data
;-----------------------------------------
TFT_WriteData FUNCTION
	PUSH {R1-R2,LR}


	; Set CS low
	LDR R1, =GPIOA_ODR
	LDR R2, [R1]
	BIC R2, R2, #TFT_CS
	STR R2, [R1]

	; Set DC RS high for data
	ORR R2, R2, #TFT_DC
	STR R2, [R1]

	; Set RD high not used in write operation
	ORR R2, R2, #TFT_RD
	STR R2, [R1]
	; Send data R0 contains data
	BIC R2, R2, #0xFF   ; Clear data bits PE0-PE7
	AND R0, R0, #0xFF   ; Ensure only 8 bits
	ORR R2, R2, R0      ; Combine with control bits
	STR R2, [R1]

	; Generate WR pulse
	BIC R2, R2, #TFT_WR
	STR R2, [R1]
	ORR R2, R2, #TFT_WR
	STR R2, [R1]
	; Set CS high
	ORR R2, R2, #TFT_CS
	STR R2, [R1]

	POP {R1-R2, PC}
	BX LR
	ENDFUNC

;-----------------------------------------
; TFT INIT
;-----------------------------------------
TFT_Init FUNCTION
	PUSH {R0-R2,LR}


	LDR R1, =GPIOA_ODR
	LDR R2, [R1]

	; Reset low
	BIC R2, R2, #TFT_RST
	STR R2, [R1]
	BL delay

	; Reset high
	ORR R2, R2, #TFT_RST
	STR R2, [R1]
	BL delay


	; Set Pixel Format (16-bit)
	MOV R0, #0x3A
	BL TFT_WriteCommand
	MOV R0, #0x55
	BL TFT_WriteData
;-----------------------------------------
; USED TO LINK LINK THE UPPER PART OT THE CODE TO ITS BOTTOM
; USED IF THERE ARE A LOT OF LINES OF CODES
	BL HIj
	LTORG
HIj	
;-----------------------------------------

	; Set Contrast VCOM
	MOV R0, #0xC5
	BL TFT_WriteCommand
	MOV R0, #0x54  ;SET VCOMH TO BIG VALUE
	BL TFT_WriteData
	MOV R0, #0x00  ;SET VCOML TO SMALL VALUE
	BL TFT_WriteData


	;Set screen orientation
	MOV R0,#0x36
	BL TFT_WriteCommand
	

	;RGB/BGR sequence
	MOV R0,#0x08
	BL TFT_WriteData

	; Sleep Out
	MOV R0, #0x11
	BL TFT_WriteCommand
	BL delay

	; WAKE UP (LISTEN TO RUN/JOJI 3:18) -> PLEASE WAKE UP , HOW DO YOU FEEL ? 
	MOV R0, #0x29
	BL TFT_WriteCommand

	POP {R0-R2,PC}
	BX LR
	ENDFUNC

;-----------------------------------------
; TFT Draw Image (R1 = X, R2 = Y, R3 = Image Address)
;-----------------------------------------
TFT_DrawImage FUNCTION
	PUSH {R0-R12,LR}


	; Load image width and height
	LDR R4, [R3], #4  ; Load width  (R3 = Width)
	LDR R5, [R3], #4  ; Load height (R4 = Height)

	; =====================
	; Set Column Address (X Start, X End)
	; =====================
	MOV R0, #0x2A
	BL TFT_WriteCommand
	MOV R0,R1,LSR #8
	BL TFT_WriteData
	UXTB R0,R1
	;MOV R0, R1  ; X Start
	BL TFT_WriteData
	ADD R0, R1, R4
	SUB R0, R0, #1  ; X End = X + Width - 1	
	MOV R0,R0,LSR #8
	BL TFT_WriteData
	ADD R0, R1, R4
	SUB R0, R0, #1  ; X End = X + Width - 1
	BL TFT_WriteData

; =====================
; Set Page Address (Y Start, Y End)
; =====================
	MOV R0, #0x2B
	BL TFT_WriteCommand
	MOV R0,R2,LSR #8
	BL TFT_WriteData
	UXTB R0,R2
	;MOV R0, R1  ; X Start
	BL TFT_WriteData
	ADD R0, R2, R5
	SUB R0, R0, #1  ; X End = X + Width - 1	
	MOV R0,R0,LSR #8
	BL TFT_WriteData
	ADD R0, R2, R5
	SUB R0, R0, #1  ; X End = X + Width - 1
	BL TFT_WriteData

; =====================
; Start Writing Pixels
; =====================
	MOV R0, #0x2C
	BL TFT_WriteCommand	

; =====================
; Send Pixel Data (BGR565)
; =====================
	MUL R6, R4, R5  ; Total pixels = Width × Height
TFT_ImageLoop
	LDRH R0, [R3], #2 ; Load one pixel (16-bit BGR565)
	MOV R1, R0, LSR #8 ; Extract high byte
	AND R2, R0, #0xFF ; Extract low byte


	MOV R0, R1         ; Send High Byte first
	BL TFT_WriteData
	MOV R0, R2         ; Send Low Byte second
	BL TFT_WriteData

	SUBS R6, R6, #1
	BNE TFT_ImageLoop

	POP {R0-R12,PC}
	BX LR
	ENDFUNC

;-----------------------------------------
; TFT_Filldraw4INP  color-R0  R6,R7-column start/end   R8,R9-page start/end
;-----------------------------------------
TFT_Filldraw4INP    FUNCTION
    PUSH {R1-R5,R10,R11,R12,LR}
    
    ; Save color
    MOV R5, R11

    ; Set PAGE Address (0-239)
    MOV R0, #0x2A
    BL TFT_WriteCommand
  
  ;start row
	MOV R10,R6
	MOV R10,R10,LSR #8
	
	MOV R0,R10		
    BL TFT_WriteData
    MOV R0,R6		
    BL TFT_WriteData
	
  ;end row
  	MOV R10,R7
	MOV R10,R10,LSR #8
	MOV R0, R10 		; High byte of 0x013F (319)
    BL TFT_WriteData
    MOV R0, R7      ; low byte of 0x013F (319)
    BL TFT_WriteData
	
	



    ; Set COL Address (0-319)
    MOV R0, #0x2B
    BL TFT_WriteCommand	
	MOV R10,R8
	MOV R10,R10,LSR #8
    ;start col
	MOV R0, R10
    BL TFT_WriteData
    MOV R0, R8
    BL TFT_WriteData
    ;end col
	MOV R10,R9
	MOV R10,R10,LSR #8
	MOV R0, R10      ; High byte of 0x01DF (479)
    BL TFT_WriteData
    MOV R0, R9      ; Low byte of 0x01DF (479)
    BL TFT_WriteData

    ; Memory Write
    MOV R0, #0x2C
    BL TFT_WriteCommand

    ; Prepare color bytes
    MOV R1, R5, LSR #8     ; High byte
    AND R2, R5, #0xFF      ; Low byte
	SUB	R11,R7,R6
	ADD R11,#10
	SUB	R12,R9,R8
	ADD R12,#10
    ; Fill screen with color (320x480 = 153600 pixels)
    MUL R3,R11,R12
FillLoopdraw4INP
    ; Write high byte
    MOV R0, R1
    BL TFT_WriteData
    
    ; Write low byte
    MOV R0, R2
    BL TFT_WriteData
    
    SUBS R3, R3, #1
    BNE FillLoopdraw4INP

    POP {R1-R5,R10,R11,R12,LR}
    BX LR
	ENDFUNC


;-----------------------------------------
; GET_state
; Get output in R10
;-----------------------------------------
GET_state FUNCTION
	PUSH {R0-R1,LR}
	MOV R10,#0
	LDR R0, =GPIOB_IDR   ; Load address of input data register
	LDR R10, [R0]         
    ; Read GPIOB input register   
    ; Shift right to get PC8 at bit 0 and PC9 at bit 1 and PC10 at bit 2 and PC11 at bit 3
	BL delay
	POP {R0-R1,PC}
	ENDFUNC	
	
	

;-----------------------------------------
; delay
;-----------------------------------------
delay    FUNCTION
    PUSH    {R0-R11,LR}
	LDR		R1,=INTERVAL
	
DelayInner_Loop
    SUBS    R1, R1 , #1
    CMP     R1, #0
    BGT     DelayInner_Loop
    POP     {R0-R11,PC}
	ENDFUNC