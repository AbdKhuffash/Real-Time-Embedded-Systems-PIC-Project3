;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	MASTER-CPU.ASM	MPB	Ver 1.0		2/15/2024
;
;	Simple Multiplication Calculator 
;	Double digits input, Tri digits results
;	Integer handling only  
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PROCESSOR 16F877
;	Clock = XT 4MHz, standard fuse settings
	__CONFIG 0x3731	; 00011011100110001

;	LABEL EQUATES	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INCLUDE "P16F877A.INC"	

COUNT EQU 0x20          ; Define variable for blink repeat count
DELAY_COUNTER1 EQU 0x21  ; Define a memory location for the delay counter
DELAY_COUNTER2 EQU 0x22  ; Define a memory location for the delay counter
TENS1 EQU 0x23 
UNITS1 EQU 0x24
TENS2 EQU 0x25 
UNITS2 EQU 0x26
TEMPNUM EQU 0x27
DELAY_COUNTER3 EQU 0x28
RESULT EQU 0x29
FIRSTNUM EQU 0x30
MASTER_RESULT EQU 0x32
AUX_RESULT EQU 0x33
TEMPNUM2 EQU 0x34
BUTTON_LIMIT EQU 0x35
MOST_DIGITS EQU 0x36
LEAST_DIGIT EQU 0x37

; Program begins ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ORG	0		; Default start address 
	NOP			; required for ICD mode

	BANKSEL	TRISB		; Select bank 1
	MOVLW	B'00000001'	; PUSH Button as Input 
	MOVWF	TRISB		;  
	
	CLRF	TRISD		; Display port is output


	BANKSEL PORTD		; Select bank 0
	CLRF	PORTD		; Clear display outputs
	CALL	inid		; Initialise the display
	
	MOVLW 3             ; Repeat the blink three times
    MOVWF COUNT         ; Store the repeat count

	MOVLW 0
	MOVWF TENS1
	
	MOVLW 0
	MOVWF UNITS1
	
	MOVLW 0
	MOVWF TENS2

	MOVLW 0
	MOVWF UNITS2

	MOVLW 0
	MOVWF TEMPNUM
	
	CALL welcomeLCD


start 
	  CALL numberOne
	  CALL numberTwo

	  BANKSEL TRISC      ; Select bank 1 for TRISC
	  CLRF TRISC         ; Clear TRISC to make Port C output

	  CALL sendFirst
	  CALL Delay1SecR
	  CALL Delay1SecR
	  CALL Delay1SecR
	  CALL sendSecond  ;	  

	  BANKSEL TRISC      ; Select bank 1 for TRISC
	  MOVLW 0xFF         ; Set all bits to 1 for input
	  MOVWF TRISC        ; Move the value to TRISC register to configure Port C as input
	  
	  MOVF TENS1, W     ;
	  ADDWF UNITS1, F  ; 
	  MOVWF FIRSTNUM
	  

	  CALL MUL_LOOP		;
	
	  CALL Delay1SecR
	  CALL Delay1SecR
	  CALL Delay1SecR

	  
	  CALL getMost 		;

	  CALL Delay1SecR
	  CALL Delay1SecR
	  CALL Delay1SecR

	  CALL getLeast		;

	  CALL getAux		;

	  CALL FinalResult ;

	  CALL DisplayResult 	;


welcomeLCD	BCF		Select,RS	; set display command mode
			MOVLW	0x01			; code to Clear Display
			CALL	send

			MOVLW	0x80			; code to home cursor
			CALL	send		; output it to display
			BSF		Select,RS	; and restore data mode
	
			MOVLW	'W'			; 
			CALL	send		;
			MOVLW	'e'			; 
			CALL	send		; 
			MOVLW	'l'			; 
			CALL	send		; 
			MOVLW	'c'			; 
			CALL	send		; 
			MOVLW	'o'			; 
			CALL	send		; 
			MOVLW	'm'			; 
			CALL	send		; 
			MOVLW	'e'			; 
			CALL	send		; 
			MOVLW	' '			; 
			CALL	send		; 
			MOVLW	't'			; 
			CALL	send		; 
			MOVLW	'o'			; 
			CALL	send		; 
			
			BCF		Select,RS	; set display command mode
			MOVLW	0xC0		; code to Second Line cursor
			CALL	send		; output it to display
			BSF		Select,RS	; and restore data mode
	
			MOVLW	'm'			; 
			CALL	send		; 
			MOVLW	'u'			; 
			CALL	send		; 
			MOVLW	'l'			; 
			CALL	send		; 
			MOVLW	't'			; 
			CALL	send		; 
			MOVLW	'i'			; 
			CALL	send		; 
			MOVLW	'p'			; 
			CALL	send		; 
			MOVLW	'l'			; 
			CALL	send		; 
			MOVLW	'i'			; 
			CALL	send		; 
			MOVLW	'c'			; 
			CALL	send		; 
			MOVLW	'a'			; 
			CALL	send		; 
			MOVLW	't'			; 
			CALL	send		; 
			MOVLW	'i'			; 
			CALL	send		; 
			MOVLW	'o'			; 
			CALL	send		; 	
			MOVLW	'n'			; 
			CALL	send		; 
			
			
			DECFSZ COUNT, F     ; Decrement repeat count and check if zero
    		GOTO Delay1Sec     ; If not zero, repeat the loop(BLINK)
			RETURN				; done



numberOne 	BCF		Select,RS	; set display command mode
			MOVLW	0x01			; code to Clear Display
			CALL	send

			MOVLW	0x80			; code to home cursor
			CALL	send		; output it to display
			BSF		Select,RS	; and restore data mode
	
			MOVLW	'N'			; 
			CALL	send		;
			MOVLW	'u'			; 
			CALL	send		; 
			MOVLW	'm'			; 
			CALL	send		; 
			MOVLW	'b'			; 
			CALL	send		; 
			MOVLW	'e'			; 
			CALL	send		; 
			MOVLW	'r'			; 
			CALL	send		; 
			MOVLW	' '			; 
			CALL	send		; 
			MOVLW	'1'			; 
			CALL	send		; 
			
			BCF		Select,RS	; set display command mode
			MOVLW	0xC0		; code to Second line cursor
			CALL	send		; output it to display
			BSF		Select,RS	; and restore data mode


			MOVLW 0
			MOVWF TEMPNUM
			CALL Delay2Sec		; GET FIRST TENS NUMBER
			
			MOVF  TEMPNUM, W
			MOVWF TENS1


			MOVF TEMPNUM, W
			CALL send			; Display TENS1 to LCD

			MOVLW 0
			MOVWF TEMPNUM
			CALL Delay2Sec		; GET FIRST UNITS NUMBER
			

			MOVF  TEMPNUM, W	
			MOVWF UNITS1		

			MOVF TEMPNUM, W
			CALL send			; Display UNITS1 to LCD

			MOVLW ' '
			CALL send

			MOVLW 'X'
			CALL send
			
			MOVLW ' '
			CALL send

			RETURN

numberTwo 	BCF		Select,RS	; set display command mode
			MOVLW	0x80			; code to home cursor
			CALL	send		; output it to display
			BSF		Select,RS	; and restore data mode
	
			MOVLW	'N'			; 
			CALL	send		;
			MOVLW	'u'			; 
			CALL	send		; 
			MOVLW	'm'			; 
			CALL	send		; 
			MOVLW	'b'			; 
			CALL	send		; 
			MOVLW	'e'			; 
			CALL	send		; 
			MOVLW	'r'			; 
			CALL	send		; 
			MOVLW	' '			;  
			CALL	send		; 
			MOVLW	'2'			; 
			CALL	send		; 
			
			BCF		Select,RS	; set display command mode
			MOVLW	0xC6		; code to continue cursor
			CALL	send		; output it to display
			BSF		Select,RS	; and restore data mode


			MOVLW 0
			MOVWF TEMPNUM
			CALL Delay2Sec		; GET SECOND TENS2 NUMBER
			
			MOVF  TEMPNUM, W
			MOVWF TENS2	

			MOVF TEMPNUM, W
			CALL send			; Display TENS2 to LCD

			MOVLW 0
			MOVWF TEMPNUM
			CALL Delay2Sec		; GET SECOND UNITS2 NUMBER
			

			MOVF TEMPNUM, W
			MOVWF UNITS2

			MOVF TEMPNUM, W
			CALL send			; Display UNITS2 to LCD

			MOVLW ' '
			CALL send

			MOVLW '='
			CALL send

			RETURN


Delay1Sec MOVLW D'250'   ; Approximate value for 1 second delay 
    	  MOVWF DELAY_COUNTER1
		  CALL DELAY_LOOP1
		  GOTO welcomeLCD
		  

DELAY_LOOP1 DECFSZ DELAY_COUNTER1, F
		   	GOTO DELAY_LOOP1
		   	RETURN


Delay2Sec MOVLW D'500'   ; Approximate value for 2 second delay 
    	  MOVWF DELAY_COUNTER2
		  CALL DELAY_LOOP2
		  RETURN
		  

DELAY_LOOP2 DECFSZ DELAY_COUNTER2, F
			GOTO DELAY_LOOP2

			GOTO checkButton
			RETURN


checkButton BTFSS       PORTB, 0        ; Check if RB0 (button P) is pressed
           	RETURN     	; Loop until button pressed

			MOVLW   TEMPNUM    ; Load the address of the number into W register
		    MOVWF   FSR            ; Set the File Select Register to point to the memory location
		    
		    MOVLW   1              ; Load 1 into W register for incrementing
		    ADDWF   INDF, F 

			MOVWF   TEMPNUM       ; 
			MOVF  	TEMPNUM2, W		
			
			MOVLW  D'9'
			MOVWF  BUTTON_LIMIT
				
			MOVWF 	TEMPNUM2
		    SUBWF   BUTTON_LIMIT, W     ; Substract W from BUTTON_LIMIT that is CURRENT_NUMBER - 9 
		    BTFSC   STATUS, C       ; if its negative then the carry is one thus the value is < 9 we continue 
									; if there is   carry then the value is > 9 
			
			
			MOVLW D'0'				; So we set the value to zero again 
			MOVWF TEMPNUM			;
			
			CALL 	Delay2Sec 		; Repeat


sendFirst MOVF TENS1, W     ;
		  ADDWF UNITS1, F  ; 
		                    
		  MOVWF PORTC       ; Move the value from W to PORTC
		  RETURN


sendSecond MOVF  UNITS2, W     ;
		                    
		   MOVWF PORTC       ; Move the value from W to PORTC
		   RETURN


Delay1SecR MOVLW D'250'   ; Approximate value for 1 second delay 
    	   MOVWF DELAY_COUNTER3
		   CALL DELAY_LOOP3
		   RETURN
		  

DELAY_LOOP3 DECFSZ DELAY_COUNTER3, F
		   	GOTO DELAY_LOOP3
		   	RETURN

MUL_LOOP	MOVF    FIRSTNUM, W            ; Move first number to WREG
			ADDWF   MASTER_RESULT                    ; Add to the Result 

			DECFSZ  TENS2, F    ; Decrement the second_number_units and check if it's zero
			GOTO    MUL_LOOP                ;If not zero, repeat the addition

			RETURN


getMost		MOVFW PORTC
			MOVWF MOST_DIGITS
			RETURN

getLeast	MOVFW PORTC
			MOVWF LEAST_DIGIT
			RETURN


getAux 		MOVF MOST_DIGITS, W     ;
		    ADDWF LEAST_DIGIT, F  ; 
		                    
		    MOVWF AUX_RESULT       ; 
		    RETURN


FinalResult  MOVF MASTER_RESULT, W     ;
		     ADDWF AUX_RESULT, F  ; 
		                    
		     MOVWF RESULT       ; Move the value from W to PORTC
		     RETURN



DisplayResult BCF		Select,RS	; set display command mode
			  MOVLW	0x01			; code to Clear Display
			  CALL	send

			  MOVLW	0x80			; code to home cursor
			  CALL	send		; output it to display
			  BSF	Select,RS	; and restore data mode
	
			  MOVLW	'R'			; 
			  CALL	send		;
			  MOVLW	'e'			; 
			  CALL	send		; 
			  MOVLW	's'			; 
			  CALL	send		; 
			  MOVLW	'u'			; 
			  CALL	send		; 
			  MOVLW	'l'			; 
			  CALL	send		; 
			  MOVLW	't'			; 
			  CALL	send		; 

			  BCF	Select,RS	; set display command mode
			  MOVLW	0xC0		; code to Second Line cursor
			  CALL	send		; output it to display
			  BSF	Select,RS	; and restore data mode

			  MOVF RESULT, W
			  CALL send 

			  CALL FinalLoop



FinalLoop BTFSS PORTB,0       ; Check if RB0 (button P) is pressed
          GOTO FinalLoop     	; Loop until button pressed
		  GOTO start
		  


	INCLUDE "LCDIS.INC"

	END ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



