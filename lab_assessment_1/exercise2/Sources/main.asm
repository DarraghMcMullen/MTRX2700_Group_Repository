; export symbols
  XDEF Entry, _Startup            ; export 'Entry' symbol
  ABSENTRY Entry        ; for absolute assembly: mark this as application entry point

  INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

  ORG RAMStart

; Insert here your data definition.
 
;look-up table for ASCII from $20 to $7E
ASCII_SSEG_LUT:    dc.b   %00000000,%00000110,%01000010,%10101101,%11101101,%10101101,%10101101,%00000010,%00111001,%00001111,%11100011,%11000110,%00000100,%01000000,%10000000,%00000110,%00111111,%00000110,%01011011,%01001111,%01100110,%01101101,%01111101,%00000111,%01111111,%01100111,%10000110,%10000110,%01000110,%01001000,%01110000,%11101101,%01011111,%01110111,%01111100,%01111001,%01011110,%01111001,%01110001,%01101111,%01110100,%00110000,%00011110,%01110101,%00111000,%01011101,%01010100,%01011100,%01110011,%01100111,%01010000,%01101101,%01111000,%00111110,%00011100,%01101010,%01110111,%01101110,%01011011,%00111001,%00000110,%00001111,%00100011,%00001000,%10001000,%01110111,%01111100,%01111001,%01011110,%01111001,%01110001,%01101111,	%01110100,%00110000,%00011110,%01110101,%00111000,%01011101,%01010100,%01011100,%01110011,%01100111,%01010000,%01101101,%01111000,%00111110,%00011100,%01101010,%01110111,%01101110,%01011011,%00111001,%00000110,%00001111,%11000000

;lut for display masks from 1 to 4 (left to right)
DISPLAY_INDEX_LUT:    dc.b   %00001110,%00001101,%00001011,%00000111

;memory allocation for string
STRING:   fcc  "test string 0123456789-"
;STRING:   fcc   "1234"

;length of string
STRING_LEN: rmb 1
  
;memory allocation for currently displayed string (4 ASCII char)
DISP_STRING:  fcc "1234"
  
;counter for current location in display sequence
DISP_STRING_COUNTER:  rmb  1 
  
;coutner for current location in string
STRING_COUNTER:   rmb  1

;counter for number of loops before rotating string
LOOPS:  ds.w 1
  
;boolean value for input detection
BUTTON_PRESSED:   rmb  1

;boolean value to select auto scroll mode, or button scroll mode
SCROLL_MODE: dc.w 1 ;1=auto, 0=button, button is still active in auto mode

; code section
  ORG   ROMStart

Entry:

  _Startup:
    LDS   #RAMEnd+1       ; initialize the stack pointer
    CLI                   ; enable interrupts
      
      
;port setup
  movb #$FF, DDRB ;portB as output
  movb #$FF, DDRP ;portP as output
  movb #$FF, DDRJ ;portJ as output
  movb #$00, DDRH ;portH as input
  movb #$00, PTJ  ;enable LEDs

; init. string counter and string length
  movb #0, STRING_COUNTER
  movb #22, STRING_LEN
  ;movb #4, STRING_LEN
  ;movb #7, STRING_LEN
  
; main loop  
main:
  bsr checkButton ;check if SW2 is pressed (with debounce)
     
  bsr mPlex ;multiplex displays to write 4 character display string to displays
  
  ; autoscroll counter routine
  ldd LOOPS
  addd SCROLL_MODE ;if autoscroll enabled, loop will inc., else, loop will remain 0
  std LOOPS
  subd #60
  bne main
  
  bsr rotateString  ;rotate currently displayed string left, adding next character from string to right
  
  bra main  ;loop forever
        

; convert ASCII code to LUT index      
ASCIILUT:

  suba #$20
  ldx #ASCII_SSEG_LUT
  tab
  ldaa b,x
  
  rts
     

; multiplex displays to write currently displayed string to displays      
mPlex:

  movb #0, DISP_STRING_COUNTER ;set counter
  
  mPlexLoop:
  
    ;disp character 
    ldx #DISP_STRING
    ldab DISP_STRING_COUNTER                 
    ldaa b,x
    bsr ASCIILUT
    staa PORTB
    
    ;select display 
    ldx #DISPLAY_INDEX_LUT
    ldab DISP_STRING_COUNTER
    ldaa b,x                     
    staa PTP
    jsr sml_delay
    ldaa #%00001111
    staa PTP
    

    ;inc counter and loop
    ldaa DISP_STRING_COUNTER
    inca
    staa DISP_STRING_COUNTER
    suba #4
    bne mPlexLoop
     
    rts


;rotate currently displayed string left, adding next character from string to right     
rotateString:

  ; rotate current string left
  ldx #DISP_STRING
  ldaa 1,x
  staa 0,x
  ldaa 2,x
  staa 1,x
  ldaa 3,x
  staa 2,x

  ; add next character in string to end of display string
  ldx #STRING
  ldab STRING_COUNTER
  ldaa b,x
  ldx #DISP_STRING
  staa 3,x
  
  ; reset string counter at end of string 
  ldab STRING_COUNTER
  incb
  stab STRING_COUNTER
  ldaa STRING_LEN
  sba
  beq resetStringCounter

  rts
  
; resets string counter to 0
resetStringCounter:

  ldaa #0
  staa STRING_COUNTER
  
  rts


; check if SW2 is pressed, if so, rotate string and set BUTTON_PRESSED = 1          
checkButton:

  movb #0,BUTTON_PRESSED  ; initialise BUTTON_PRESSED to 0
  
  ;11110111 on PTH for SW2 pressed
  captureInitialPress:
    ldaa PTH
    anda #$08 ;mask all inputs but SW2
    cmpa #$08 ;z=1 if not pressed, z=0 if pressed
    beq exit        ;if not pressed, exit
  
   ;debounce routine
  checkIfStillPressed:
    ;delay for 100ms
    ldy #100
    jsr delay1ms
    ldaa PTH
    anda #%00010000 ;mask all inputs but SW2
    cmpa #%00010000 ;z=1 if not pressed, z=0 if pressed
    beq exit ;if not still pressed after 20ms, exit
  
   ; if pressed, rotate string and set register = true
   movb #1, BUTTON_PRESSED  ;set button pressed register = 1 if pressed
   bsr rotateString
  
  exit:
    rts
      

;delay by 1ms * number in y register      
delay1ms:
  pshx
  LDY #100
  outerLoop: 
    ldx #1000
    innerLoop: 
      psha ; 2 cycles
      pula ; 3 cycles
      psha ; 2 cycles
      pula ; 3 cycles
      psha ; 2 cycles
      pula ; 3 cycles
      psha ; 2 cycles
      pula ; 3 cycles
      nop ; 1 cycle
      nop ; 1 cycle
      nop ; 1 cycle
      nop ; 1 cycle
    dbne x,innerLoop
  dbne y,outerLoop
  pulx
  
  rts        
          
sml_delay:

  LDY #10
  sml:
  dbne y, sml
  
  rts                
         

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector

