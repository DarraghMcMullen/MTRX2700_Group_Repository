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

            ORG RAMStart
 ; Insert here your data definition.
Counter     DS.W 1
FiboRes     DS.W 1


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts


SSEG0 equ $3F ;0
SSEG1 equ $06 ;1
SSEG2 equ $5B ;2
SSEG3 equ $4F ;3
SSEG4 equ $66 ;4
SSEG5 equ $6D ;5
SSEG6 equ $7D ;6
SSEG7 equ $07 ;7
SSEG8 equ $7F ;8
SSEG9 equ $67 ;9

DISP1 equ %00001110 ;7 seg display 1
DISP2 equ %00001101 ;7 seg display 2
DISP3 equ %00001011 ;7 seg display 3
DISP4 equ %00000111 ;7 seg display 4


      ldaa #$FF
      staa DDRB ;portB as output
      staa DDRP ;portP as output
      staa DDRJ ;portJ as output
      ldaa #$00
      staa PTJ  ;enable LEDs
      
  
start:
      ldaa #SSEG4
      staa PORTB  ;send to port B
      ldaa #DISP1 ;select digit 0
      staa PTP
      
      bsr delay1ms
      
      ldaa #SSEG3
      staa PORTB
      ldaa #DISP2
      staa PTP
      
      bsr delay1ms
      
      ldaa #SSEG2
      staa PORTB
      ldaa #DISP3
      staa PTP
      
      bsr delay1ms
      
      ldaa #SSEG1
      staa PORTB
      ldaa #DISP4
      staa PTP
     
      bsr delay1ms
     
      bra start
      
      
delay1s:  
          LDX #60000
          LOOPs:
          LDAA #100
          LOPs:
          NOP
          DBNE A, LOPs
          DBNE X, LOOPs
        
          
          rts		; return from subroutine
          
delay1ms:  
          LDX #60
          LOOPms:
          LDAA #100
          LOPms:
          NOP
          DBNE A, LOPms
          DBNE X, LOOPms
        
          
          rts		; return from subroutine

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector

