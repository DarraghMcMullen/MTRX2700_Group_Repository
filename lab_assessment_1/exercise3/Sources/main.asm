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
WORD FCB "Memory"
SPECIAL_CHARS FCB $A,$D,$0
READ RMB 80

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

  bsr task_number
    

task1: LDX #WORD                      ; loads word address into X register  
    bsr send_str                      ; send string to serial data register
    

task2: LDX #READ                      ; loads word address into X register
    bsr readSCI1                      ; read string from serial data register
    

send_str:
    LDAA 1,X+                         ; loads value at X into accumulator A & increment
    CMPA #$00                         ; comparing value in A to 0 
    BEQ delay_reset                   ; delay when null character is found (end of string)
    
    bsr loadSCI1                      ; load character to serial 1 data register
    bra send_str                      ; return to beginning of subroutine


; -- Loads Character in A register to Serial 1 Data Register --
loadSCI1:
                
    MOVB #156, SCI1BDL                ; set baud rate to 9600       
    MOVB #$08, SCI1CR2                ; set control register values
    brclr SCI1SR1,mSCI1SR1_TDRE,*     ; waits for TDRE to be set
    staa SCI1DRL                      ; loads character from A register to data register
    rts
    
    
; -- Read incoming characters from Serial 1 Data Register, loop until return character encountered -- 
readSCI1:                 
    MOVB #156, SCI1BDL                ; set baud rate to 9600
    MOVB #mSCI1CR2_RE, SCI1CR2        ; set control register to read incoming signals
    brclr SCI1SR1, mSCI1SR1_RDRF,*    ; poll RDRF register
    LDAA SCI1DRL                      ; load value from data register to A register
    STAA 1,X+                         ; store value from A to X index 
    CMPA #$D                          ; check if character in A register is the return character
    BEQ complete_string               ; branch to complete_string subroutine if return character encountered
    bra readSCI1                      ; otherwise, continue looping

; -- Adds carriage return and null character to end of string at address pointed by X index --
complete_string:
    LDAA #$A                          ; load carriage return character to A register
    STAA 1,X+                         ; store byte in A register to address pointed by X index
    LDAA #00                          ; load null character to A register
    STAA 1,X+                         ; store byte in A register to address pointed by X index
    LDX #READ                         ; return X index to beginning of string
    bra send_str                      ; send string to serial interface

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
  MOVB #$0,DDRH
  LDAA PTH
  CMPA #$1
  BEQ task1
  BNE task2


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
