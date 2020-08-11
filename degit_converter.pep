BR  main      
mseg1: .ASCII "Enter a decimal number to be converted \n\x00"
mseg2: .ASCII "Enter a new base \n\x00"
mseg3: .ASCII "The answer is \n\x00"
null: .ASCII "\n\x00"
num:  .BLOCK 2  ; Input variable
base: .BLOCK 2 ; 
octal: .BLOCK 2 ; 
hexa: .BLOCK 2  ; 
count: .BLOCK 2  ; 2 - 2bit, 8 - 3bit, 16 - 4bit
flag: .BLOCK 2   ; C flag
check: .BLOCK 2  ; do not print front bit ( 00010 -> 10 )
first: .BLOCK 2   ; if tran to 8, first bit ignore (first bit note +/-, can ignore)
limit: .BLOCK 2   ; for 16bit, 16loop
main: STRO mseg1, d
      DECI num, d  ; 
      DECO num ,d
      STRO null, d
      STRO mseg2, d
      DECI base, d ; 
      DECO base ,d
      STRO null, d
      STRO mseg3, d
      LDA base, d
      CPA 2, i
      BREQ tranbin         
      LDA base, d
      CPA 8, i
      BREQ tranoct       
      LDA base, d
      CPA 16, i
      BREQ tranhexa        
      BR exit

tranbin: LDA 0, i ; Clear accumulator
binloop: LDA limit, d
      CPA 16, i
      BREQ exit 
      LDA num, d
      ASLA
      STA num, d
binif: MOVFLGA       ; verify carry bit
       BRC binelse
       LDA limit, d
       ADDA 1, i
       STA limit, d
       LDA check, d      ; if check 0, do not print
       CPA 0, i
       BREQ binloop   
       DECO 0, i
       BR binloop
binelse: DECO 1, i        
         LDA check, d    ; When meet 1, add check 1
         ADDA 1, i          
         STA check, d
         LDA limit, d
         ADDA 1, i
         STA limit, d
         BR binloop
 

tranoct: LDA 0, i
       LDA first, d         ; make 0 to first bit 
       LDA 0, i 
       STA first, d
octloop: LDA octal, d       ; make 0 to 8
      LDA 0, i               
      STA octal, d
      LDA first, d
      ADDA 1, i
      STA first, d
      LDA count, d          
      LDA 3, i 
      STA count, d

octif:  LDA  limit, d 
        CPA  16, i              
        BREQ exit 
        LDA  num, d
        ASLA
        STA  num, d
        MOVFLGA                
        BRC octelse
        LDA limit, d
        ADDA 1, i
        STA limit, d
        LDA first, d           
        CPA 1, i
        BREQ octloop            ; when meet first bit, ignore bit
        LDA count, d             
        SUBA 1, i  
        STA count, d
        LDA count, d
        CPA 0, i
        BRNE octif               
        LDA check, d             
        CPA 0, i
        BREQ octloop
        DECO octal, d   
        BR octloop

octelse:  LDA limit, d
          ADDA 1, i
          STA limit, d
          LDA first, d           ; when meet first bit, ignore bit
          CPA 1, i
          BREQ octloop
          LDA check, d
          ADDA 1, i
          STA check, d
          LDA count, d
          SUBA 1, i
          STA count, d
          LDA count, d
          CPA 2, i
          BREQ octbit1           ; if count = 2, bit 1
          LDA count, d
          CPA 1, i
          BREQ octbit2           ; if count = 1, bit 2
          LDA octal, d           ; if count = 0, bit 3 therefore add 1
          ADDA 1, i
          STA octal, d       
          BR octnext

octbit2:  LDA octal, d        ; bit 2, add 2
          ADDA 2, i
          STA octal, d
          BR octnext

octbit1:  LDA octal, d        ; bit 1, add 4
          ADDA 4, i
          STA octal, d

octnext:  LDA count, d
          CPA 0, i
          BRNE octif             
          DECO octal, d
          BR octloop

tranhexa: LDA 0, i

hexaloop: LDA hexa, d 
          LDA 0, i
          STA hexa, d
          LDA count, d ; tran to hexa, print to 4bit(ex)0000 0000 0000)
          LDA 4, i 
          STA count, d

hexaif:   LDA  limit, d 
          CPA  16, i  
          BREQ exit  
          LDA  num, d  
          ASLA    ; 
          STA  num, d  
          MOVFLGA    
          BRC  hexaelse  
          LDA  limit, d 
          ADDA 1, i 
          STA  limit, d 
          LDA count, d 
          SUBA 1 , i
          STA count, d
          LDA count, d 
          CPA 0, i
          BRNE hexaif     
          LDA check, d
          CPA 0, i
          BREQ hexaloop   
          LDA hexa, d
          CPA 10, i
          BRGE ascii  ; If hexa >= 10, must print ascii code
          DECO hexa,d ; hexa < 10, print number
          BR  hexaloop  

hexaelse: LDA  limit, d 
          ADDA 1, i  
          STA  limit, d 
          LDA check, d 
          ADDA 1, i
          STA check, d
          LDA count, d  
          SUBA 1 , i
          STA count, d
          LDA count, d           
          CPA 3, i
          BREQ hexabit1
          LDA count, d           
          CPA 2, i
          BREQ hexabit2
          LDA count, d           
          CPA 1, i
          BREQ hexabit3
          LDA hexa, d            
          ADDA 1, i
          STA hexa, d
          BR hexanext

hexabit3: LDA hexa, d
          ADDA 2, i              
          STA hexa, d
          BR hexanext

hexabit2: LDA hexa, d
          ADDA 4, i              
          STA hexa, d
          BR hexanext

hexabit1: LDA hexa, d
          ADDA 8 , i     
          STA hexa, d

hexanext: LDA count, d
          CPA 0, i
          BRNE hexaif               
          LDA hexa, d            
          CPA 10, i
          BRGE ascii
          DECO hexa, d           
          BR hexaloop

ascii:    LDA hexa, d           ; print hexa to ascii code
          CPA 10, i
          BREQ printA
          CPA 11, i
          BREQ printB
          CPA 12, i
          BREQ printC
          CPA 13, i
          BREQ printD
          CPA 14, i
          BREQ printE
          CPA 15, i
          BREQ printF       
          BR  hexaloop   



printA:  CHARO 'A', i
         BR hexaloop
printB:  CHARO 'B', i
         BR hexaloop
printC:  CHARO 'C', i
         BR hexaloop
printD:  CHARO 'D', i
         BR hexaloop
printE:  CHARO 'E', i
         BR hexaloop
printF:  CHARO 'F', i
         BR hexaloop


exit:    CHARO ' ', i  ; Outputs space 
         STOP       
         .END 