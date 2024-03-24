;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;CO-Processer.ASM MPB Ver 1.0 15/2/2024
;
; Simple calculator 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PROCESSOR 16F877
; Clock = XT 4MHz, standard fuse settings
	__CONFIG 0x3F31  ; 0001111110011001, adjust these settings as needed
	INCLUDE "P16F877A.INC"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables
FIRST_NUM 		   EQU 0x40   ; Memory location for the first number
SECOND_NUMBER_UNIT EQU 0x41   ; Memory location for the units of the second number 
RESULT             EQU 0x42   ; Memory location for the result
MSB				   EQU 0x43
LSB                EQU 0x45
MSB_TMP            EQU 0x44
TMP_REG			   EQU 0x46
DIVISOR 		   EQU 0x47	
DELAY_COUNTER1	   EQU 0x48
CHECKING           EQU 0x49

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ORG 0x00           ; Set the origin to the reset vector
    NOP                ; Required for ICD mode

    BANKSEL TRISC 
    MOVLW   0xFF       ; Load value with all bits set to 1
    MOVWF   TRISC      ; Set all Port C pins as input

    BANKSEL PORTC      ; Select bank 0 
    CLRF    PORTC  

;;;;;;;;;; receiving numbers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Main_LOOP:
	
	MOVF    PORTC, CHECKING 
	MOVF	0x00,W 
	SUBWF   W, CHECKING 		
    BTFSC   STATUS, C				; Check if borrow occurred
    GOTO    Main_LOOP			

	MOVF    PORTC, W   ; Move the content of PORTC to WREG
	MOVWF   FIRST_NUM  ; Store the received
    
	CALL Delay1Sec
	CALL Delay1Sec
	CALL Delay1Sec

    CLRF    PORTC 
	MOVF    PORTC, W                
	MOVWF   SECOND_NUMBER_UNIT

start CALL Multiplication
	CALL SPLIT_DIGITS

	BANKSEL TRISC 
    CLRF   	TRISC 
    BANKSEL PORTC      
    CLRF    PORTC  
 
	CALL send

	BANKSEL TRISC 
    MOVLW   0xFF       ; Load value with all bits set to 1
    MOVWF   TRISC      ; Set all Port C pins as input

    BANKSEL PORTC      ; Select bank 0 
    CLRF    PORTC  
	GOTO 	Main_LOOP
	

;;;;;;;;; Multiplication ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
Multiplication 
	CLRF    RESULT					; Clear the result register

Adding_LOOP:
	MOVF    FIRST_NUM, W			; Move first number to WREG
	ADDWF   RESULT					; Add to the Result 
    ;GOTO    Check_Result			; If Carry is set, saturate the result

    DECFSZ  SECOND_NUMBER_UNIT, F	; Decrement the second_number_units and check if it's zero
    GOTO    Adding_LOOP				;If not zero, repeat the addition
	
    RETURN

;;;;;;;;;;;;;;;Splitting ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPLIT_DIGITS:
    MOVLW   10              		; Load divisor (10) into WREG
    MOVWF   DIVISOR         		; Store the divisor in DIVISOR variable
    MOVF    RESULT, W         		; Move the result to WREG
    CALL    DIVIDE_BY_TEN   
  

    MOVLW   RESULT              	
    MOVWF   MSB_TMP   			
    SUBWF   MSB_TMP, LSB
    MOVF    MSB_TMP, W     			; Move the result back to WREG
    MOVWF   MSB_TMP       				;Store the MSB digits
	  		
    RETURN


;;;;;;;;;;;;;;;;;;;;Division;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DIVIDE_BY_TEN:
    MOVWF   TMP_REG					

DIV_LOOP:
    SUBWF   TMP_REG, DIVISOR		
    BTFSC   STATUS, C				; Check if borrow occurred
    GOTO    DIV_LOOP				;If no borrow, continue division

    MOVF    TMP_REG, W     			; Move the result back to WREG
    MOVWF   LSB       				;Store the least significant untis digit
    RETURN 
	           

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Sending;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
send:
	MOVF  MSB, W  
	MOVWF PORTC       ; Move the value from W to PORTC

	CALL Delay1Sec
	CALL Delay1Sec
	CALL Delay1Sec

	CLRF    PORTC 
	MOVF  LSB, W  
	MOVWF PORTC 

	RETURN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delay;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Delay1Sec MOVLW D'250'   ; Approximate value for 1 second delay 
	MOVWF DELAY_COUNTER1
	CALL DELAY_LOOP1
	RETURN
          

DELAY_LOOP1 DECFSZ DELAY_COUNTER1, F
	GOTO DELAY_LOOP1
	RETURN
	END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Check_Result:
 ;   MOVF    RESULT, W         ; Move the result to WREG
 ;   SUBWF   #255, W           ; Subtract 256 from the result
 ;   BTFSS   STATUS, Z         ; Check if the result is zero 
 ;   GOTO    Adding_LOOP		  ; If not zero, continue the addition

 ;   BSF     STATUS, C         ; Set the Carry flag (result > 255)
 ;   MOVLW   0xFF              ; Load 255 to WREG
 ;   MOVWF   RESULT            ; Set the result to 255
 ;	RETURN 
