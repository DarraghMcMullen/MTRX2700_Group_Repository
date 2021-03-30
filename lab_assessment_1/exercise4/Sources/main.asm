;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

 ifdef _HCS12_SERIALMON
            ORG $3FFF - (RAMEnd - RAMStart)
 else
            ORG RAMStart
 endif
 ; Insert here your data definition.
Counter     DS.W 1
FiboRes     DS.W 1

;---Reserved memory for input strings---
NUL EQU $0                            ; null character
LF EQU $A                             ; line feed character
CR EQU $D                             ; carriage return character
SPC EQU $20                           ; space character

                                      
TASKFLAG FCB 0                        ; task flag, used to determine desired function
SPACEFLAG FCB 0                       ; space flag, used to flag that previous character was a space
READ RMB 80                           ; memory for storing received serial data
WRITE RMB 80                          ; memory for storing transformed and ready to transmit data

; code section
            ORG   ROMStart


Entry:
_Startup:
            ; remap the RAM &amp; EEPROM here. See EB386.pdf
 ifdef _HCS12_SERIALMON
            ; set registers at $0000
            CLR   $11                  ; INITRG= $0
            ; set ram to end at $3FFF
            LDAB  #$39
            STAB  $10                  ; INITRM= $39

            ; set eeprom to end at $0FFF
            LDAA  #$9
            STAA  $12                  ; INITEE= $9


            LDS   #$3FFF+1        ; See EB386.pdf, initialize the stack pointer
 else
            LDS   #RAMEnd+1       ; initialize the stack pointer
 endif

            CLI                     ; enable interrupts



mainLoop: 
  
  MOVB #156, SCI1BDL                  ; set baud rate to 9600
  LDX #READ                           ; loads word address into X register
                         
  bsr readSCI1                        ; read string from serial data register
    

send_str:
    LDAA 1,X+                         ; loads value at X into accumulator A & increment
    BEQ mainLoop                      ; delay when null character is found (end of string)
    
    bsr loadSCI1                      ; load character to serial 1 data register
    bra send_str                      ; return to beginning of subroutine


; -- Loads Character in A register to Serial 1 Data Register --
loadSCI1:                
    MOVB #mSCI1CR2_TE, SCI1CR2        ; set control register to transmit data
    brclr SCI1SR1,mSCI1SR1_TDRE,*     ; waits for TDRE to be set
    staa SCI1DRL                      ; loads character from A register to data register
    rts
    
    
; -- Read incoming characters from Serial 1 Data Register, loop until return character encountered -- 
readSCI1:                 
    MOVB #mSCI1CR2_RE, SCI1CR2        ; set control register to receive data
    brclr SCI1SR1, mSCI1SR1_RDRF,*    ; poll RDRF register
    LDAA SCI1DRL                      ; load value from data register to A register
    STAA 1,X+                         ; store value from A to X index 
    CMPA #CR                          ; check if character in A register is the return character
    BEQ complete_string               ; branch to complete_string subroutine if return character encountered
    bra readSCI1                      ; otherwise, continue looping

; -- Adds carriage return and null character to end of string at address pointed by X index --
complete_string:
    LDAA #LF                          ; load carriage return character to A register
    STAA 1,X+                         ; store byte in A register to address pointed by X index
    LDAA #NUL                         ; load null character to A register
    STAA 1,X+                         ; store byte in A register to address pointed by X index
    LDX #READ                         ; return X index to beginning of string
    bra task_number                   ; send string to serial interface

; Subroutine takes approx 1 second to complete using nested loops, returns to beginning of code after execution 
delay_reset:   
  LDX #60000                          ; load 60000 into X  
  LOOP1:
    LDY #100                          ; load 100 into Y
    LOOP2:
      DBNE Y, LOOP2                   ; decrement Y, branch to LOOP2 if not 0
    DBNE X, LOOP1                     ; decremeny X, branch to LOOP1 if not 0
               
  bra mainLoop


task_number:                          
  MOVB #$0,DDRH                       ; set port H data direction register to input
  LDAB PTH                            ; store value of port H in B register
  LDX #TASKFLAG
  STAB 0,X
  LDX #READ
  LDY #WRITE
  LDAB 0
  
change_str:                           ; subroutine for altering the input string
  
  LDAA TASKFLAG                       
  
  CMPA #$1                            ; comparing task flag with 1 to determine string alteration type
  BEQ space_upper_loop
  BNE all_upper_loop
  
  all_upper_loop:
      LDAA 1,X+                       ; load value at X into A register and increment
      CMPA #CR                        ; check if carriage return character
      BEQ finish
      CMPA #$61                       ; check case of character in A
      BGE make_upper                  ; make it upper case if it's lower
      BLO next
  
  space_upper_loop:                    
      LDAA 1,X+                       ; load value at X into A register and increment
      CMPA #CR                        ; check if carriage return character
      BEQ finish
      CMPA #SPC                       ; comparte A value with space character
      BEQ space
      CMPB #$0                        ; check if previous character was a space
      BEQ before_space
      BNE after_space   
  
  before_space:    
      CMPA #$61                       ; makes all characters before/not directly after a space lower case
      BLO make_lower
      BGE next
  
  after_space:
      LDAB #0                         ; makes character immediately following a space upper case
      CMPA #$61
      BGE make_upper
      BLO next
 
  space:
      LDAB #1                         ; load 1 into B to flag previous character was a space
      bra next
      
  next:  
    STAA  1,Y+                        ;store into output
    bra change_str
  
  make_upper:
    SUBA  #$20                        ;lower case is 32 characters above it's corresponding uppercase                         
    bra next  
  
  make_lower:
    ADDA #$20                         ;upper case is 32 characters below it's corresponding lowercase
    bra next
  
  finish:
    STAA  1,Y+
    LDAA #$A                          ; load carriage return character to A register
    STAA 1,Y+                         ; store byte in A register to address pointed by X index
    LDAA #00                          ; load null character to A register
    STAA 1,Y+                         ; store byte in A register to address pointed by X index
    LDX #WRITE
    LBRA send_str    
    
    
    
                    

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
