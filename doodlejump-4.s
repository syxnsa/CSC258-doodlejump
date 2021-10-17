#####################################################################
#
# CSC258H5S Fall 2020 Assembly Final Project
# University of Toronto, St. George
#
# Student: Xinkai Jiang 1006037290
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission? 
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
# 4
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any) Scoreboard / score count
# 2. (fill in the feature, if any) Game over / retry
# 3. (fill in the feature, if any) notification
# ... (add more if necessary) sound effects
# lethal creature
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.data
	displayAddress: .word 0x10008000
	beep1: .byte 72
	beep2: .byte 71
	beep4: .byte 64
	beep3: .byte 63
	duration: .byte 1000
	instrument: .byte 24
	volume: .byte 127
.text	
	lw $t0, displayAddress
	li $t1, 0xffffff
	li $t2, 0x53c653
	li $k0, 0xffff0000
	add $t4, $zero,$zero	
	add $t9,$t9,$zero
	add $s5,$zero,$zero
setting:add $s5,$zero,$zero	
	lw $t0, displayAddress
	add $t4, $zero,$zero
	jal PaintAllWhite
	jal random
	add $s0,$a0,$zero
	add $t9,$t0,$a0
	addi $t9,$t9,3592
	jal drawDoodle
	addi $t5,$zero,3968
	jal drawplat
	jal random
	add $s1,$a0,$zero	
	addi $t5,$zero,2688
	jal drawplat
	jal random
	add $s2,$a0,$zero
	addi $t5,$zero,1408
	jal drawplat
	jal random
	add $s3,$a0,$zero
	addi $t5,$zero,768
	jal drawplat


		
			
start:	lw $t8,0($k0)
	beq $t8,1,keyboard_input
	j start
keyboard_input:
	lw $t7,4($k0)
	add $s7, $zero,$zero
	beq $t7,0x73,respond_to_s	
	j start
rejump:	add $s7,$zero,$zero
	jal notification
	jal jumpsound
	j respond_to_s
new:	jal PaintAllWhite
	jal createmonster
	addi $s5,$s5,1
respond_to_s:
	jal check_hurt
	add $t6,$zero,$t9
	beq $s7,2,clean	
continue:	
	beq $s7,15,check_collision
	addi $s7,$s7,1
	jal jump
	j check_top
clean:	jal clear
	j continue
movement:	
	lw $t7,4($k0)	
	beq $t7,0x6a,respond_to_j
	beq $t7,0x6b,respond_to_k
	beq $t7,0x72,setting
	j redraw_the_screen
respond_to_j:
	jal moveright
	j redraw_the_screen 
respond_to_k:
	jal moveleft
	j redraw_the_screen
	
redraw_the_screen:	
	add $t7,$zero,$zero
	sw $t7,4($k0)
	jal removeDoodle
	jal drawDoodle
	jal countfirst
	jal countlast
	jal drawmonster
	jal redrawplat
	j sleep
sleep:	li $v0,32
	li $a0,100
	syscall
	j respond_to_s

check_collision:
	add $t0,$zero,$t9
	addi $t0,$t0,384
	lw $a1,($t0)
	lw $a2,8($t0)
	beq $a1,$t2,rejump
	beq $a2,$t2,rejump
	jal drop
	j check_dead
	
check_dead:
	lw $t0, displayAddress
	addi $t0,$t0,3840
	slt $at, $t9,$t0
	beq $at,$zero, DEAD
	j movement
	
check_top:
	lw $t0, displayAddress
	addi $t0,$t0,124	
	slt $at, $t0, $t9
	beq $at,$zero, new_page
	j movement
new_page:	
	addi $t9,$t9,3968
	jal createplat
	j new
	
createmonster:	
	add $t3,$zero,$zero
	li $v0, 42
	li $a0,0
	li $a1,4
	syscall
	beq $a0,0,monster
	jr $ra
monster:	
	li $v0, 42
	li $a0,0
	li $a1,23
	syscall
	mul $a0,$a0,4
	add $t3,$t3,$a0
	li $v0, 42
	li $a0,0
	li $a1,18
	syscall
	mul $a0,$a0,128
	add $t3,$t3,$a0
	lw $t0, displayAddress
	add $t3,$t3,$t0
	jr $ra
	
drawmonster:	
	bgtz $t3, draw
	jr $ra
draw:	li $t1 0x000001
	sw $t1, 0($t3)
	sw $t1, 4($t3)
	sw $t1, 8($t3)
	sw $t1, 12($t3)
	sw $t1, 16($t3)
	sw $t1, 128($t3)
	sw $t1,136($t3)
	sw $t1, 144($t3)
	sw $t1, 256($t3)
	sw $t1, 260($t3)
	sw $t1, 264($t3)
	sw $t1, 268($t3)
	sw $t1, 272($t3)
	li $t1, 0xff0000
	sw $t1,132($t3)
	sw $t1,140($t3)
	li $t1,0xffffff
	jr $ra
				
jumpsound:
	li $v0,31
	lb $a0,beep1
	lb $a1,duration
	lb $a2,instrument
	lb $a3,volume
	syscall
	li $v0,32
	li $a0,150
	syscall
	li $v0,31
	lb $a0,beep2
	lb $a1,duration
	lb $a2,instrument
	lb $a3,volume
	syscall
	li $v0,32
	li $a0,150
	syscall
	jr $ra
deadsound:
	li $v0,31
	lb $a0,beep3
	lb $a1,duration
	lb $a2,instrument
	lb $a3,volume
	syscall
	li $v0,32
	li $a0,150
	syscall
	li $v0,31
	lb $a0,beep4
	lb $a1,duration
	lb $a2,instrument
	lb $a3,volume
	syscall
	jr $ra

random:
	li $v0, 42
	li $a0,0
	li $a1,23
	syscall
	mul $a0,$a0,4
	jr $ra
	
drawDoodle: 	
	lw $t0, displayAddress
	li $t1 0xff7f00
	add $t0, $t9,$zero 
	sw $t1, 0($t0)
	sw $t1,4($t0)
	sw $t1,8($t0)
	sw $t1,128($t0)
	sw $t1,132($t0)
	sw $t1,136($t0)
	sw $t1,256($t0)
	sw $t1,264($t0)
	li $t1 0xffffff
	jr $ra		
PaintAllWhite:	
	beq $t4, 1024, endpaint
	addi $t4,$t4,1
	sw $t1, ($t0)
	addi $t0, $t0, 4
	j PaintAllWhite	
endpaint: 	
	lw $t0, displayAddress
	jr $ra		
			
drawplat:	
	lw $t0, displayAddress	
	add $t4, $zero,$zero
	add $a0,$a0,$t5
	add $t0,$t0,$a0
loop1:	beq $t4, 7, end1
	addi $t4,$t4,1
	sw $t2,($t0)
	addi $t0,$t0,4
	j loop1
end1:	jr $ra	
			
redrawplat:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	add $a0,$s0,$zero
	addi $t5,$zero,3968
	jal drawplat
	add $a0,$s1,$zero
	addi $t5,$zero,2688
	jal drawplat
	add $a0,$s2,$zero
	addi $t5,$zero,1408
	jal drawplat
	add $a0,$s3,$zero
	addi $t5,$zero,768
	jal drawplat	
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra	
	
drop:	addi $t9,$t9,128
	jr $ra																										
jump:	addi $t9,$t9,-128
	jr $ra
moveright:
	addi $t9,$t9,-4
	jr $ra
moveleft:	
	addi $t9,$t9,4	
	jr $ra
removeDoodle:
	lw $t0, displayAddress
	add $t0, $t6,$zero
	sw $t1, 0($t0)
	sw $t1,4($t0)
	sw $t1,8($t0)
	sw $t1,128($t0)
	sw $t1,132($t0)
	sw $t1,136($t0)
	sw $t1,256($t0)
	sw $t1,264($t0)	
	jr $ra
createplat:	
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal random
	add $s0,$a0,$zero
	jal random
	add $s1,$a0,$zero
	jal random
	add $s2,$a0,$zero
	jal random
	add $s3,$a0,$zero
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
	
removenote:	
	beq $t4, 160, endremove
	addi $t4,$t4,1
	sw $t1, ($t0)
	addi $t0, $t0, 4
	j removenote
endremove:
	jr $ra		
		
notification:	
	add $t4,$zero,$zero
	li $v0, 42
	li $a0,0
	li $a1,3
	syscall	
	beq $a0,0,pogger
	beq $a0,1,awesome
	beq $a0,2,wow
pogger:	lw $t0, displayAddress
	li $t1, 0x0000ff
	sw $t1,1676($t0)
	sw $t1,1804($t0)
	sw $t1,1932($t0)
	sw $t1,2060($t0)
	sw $t1,2188($t0)
	sw $t1,1680($t0)
	sw $t1,1684($t0)
	sw $t1,1812($t0)
	sw $t1,1940($t0)
	sw $t1,1936($t0)
	sw $t1,1692($t0)
	sw $t1,1820($t0)
	sw $t1,1948($t0)
	sw $t1,2076($t0)
	sw $t1,2204($t0)
	sw $t1,2208($t0)
	sw $t1,2212($t0)
	sw $t1,2084($t0)
	sw $t1,1956($t0)
	sw $t1,1828($t0)
	sw $t1,1700($t0)
	sw $t1,1696($t0)
	sw $t1,1708($t0)
	sw $t1,1836($t0)
	sw $t1,1964($t0)
	sw $t1,2092($t0)
	sw $t1,2220($t0)
	sw $t1,2224($t0)
	sw $t1,2228($t0)
	sw $t1,2100($t0)
	sw $t1,1972($t0)
	sw $t1,1712($t0)
	sw $t1,1716($t0)
	sw $t1,1724($t0)
	sw $t1,1852($t0)
	sw $t1,1980($t0)
	sw $t1,2108($t0)
	sw $t1,2236($t0)
	sw $t1,2240($t0)
	sw $t1,2244($t0)
	sw $t1,2116($t0)
	sw $t1,1988($t0)
	sw $t1,1728($t0)
	sw $t1,1732($t0)
	sw $t1,1740($t0)
	sw $t1,1744($t0)
	sw $t1,1748($t0)
	sw $t1,1868($t0)
	sw $t1,1996($t0)
	sw $t1,2124($t0)
	sw $t1,2000($t0)
	sw $t1,2004($t0)
	sw $t1,2252($t0)
	sw $t1,2256($t0)
	sw $t1,2260($t0)
	sw $t1,1756($t0)
	sw $t1,1884($t0)
	sw $t1,2012($t0)
	sw $t1,2140($t0)
	sw $t1,2268($t0)
	sw $t1,1760($t0)
	sw $t1,1764($t0)
	sw $t1,1768($t0)
	sw $t1,1896($t0)
	sw $t1,2024($t0)
	sw $t1,2020($t0)
	sw $t1,2016($t0)
	sw $t1,2148($t0)
	sw $t1,2280($t0)
	sw $t1,2288($t0)
	sw $t1,2032($t0)
	sw $t1,1904($t0)
	sw $t1,1776($t0)
	li $t1, 0xffffff
	jr $ra	
	
awesome:lw $t0, displayAddress
	li $t1, 0x0000ff	
	sw $t1,1680($t0)
	sw $t1,1804($t0)
	sw $t1,1812($t0)
	sw $t1,1932($t0)
	sw $t1,2060($t0)
	sw $t1,2188($t0)
	sw $t1,1940($t0)
	sw $t1,2068($t0)
	sw $t1,2196($t0)
	sw $t1,1936($t0)
	sw $t1,1692($t0)
	sw $t1,1820($t0)
	sw $t1,1948($t0)
	sw $t1,2076($t0)
	sw $t1,2204($t0)
	sw $t1,2080($t0)
	sw $t1,1956($t0)
	sw $t1,2088($t0)
	sw $t1,1964($t0)
	sw $t1,2092($t0)
	sw $t1,2220($t0)
	sw $t1,1836($t0)
	sw $t1,1708($t0)
	sw $t1,1716($t0)
	sw $t1,1844($t0)
	sw $t1,1972($t0)
	sw $t1,1976($t0)
	sw $t1,1980($t0)
	sw $t1,2100($t0)
	sw $t1,2228($t0)
	sw $t1,1720($t0)
	sw $t1,2232($t0)
	sw $t1,2236($t0)
	sw $t1,1980($t0)
	sw $t1,1724($t0)
	sw $t1,1732($t0)
	sw $t1,1860($t0)
	sw $t1,1988($t0)
	sw $t1,1992($t0)
	sw $t1,1996($t0)
	sw $t1,1736($t0)
	sw $t1,1740($t0)
	sw $t1,2124($t0)
	sw $t1,2252($t0)
	sw $t1,2248($t0)
	sw $t1,2244($t0)
	sw $t1,2260($t0)
	sw $t1,2264($t0)
	sw $t1,2268($t0)
	sw $t1,2140($t0)
	sw $t1,2012($t0)
	sw $t1,1884($t0)
	sw $t1,1756($t0)
	sw $t1,1752($t0)
	sw $t1,1748($t0)
	sw $t1,1876($t0)
	sw $t1,2004($t0)
	sw $t1,2132($t0)
	sw $t1,1764($t0)
	sw $t1,1892($t0)
	sw $t1,2020($t0)
	sw $t1,2276($t0)
	li $t1, 0xffffff
	jr $ra	
	
wow:	lw $t0, displayAddress
	li $t1, 0x0000ff
	sw $t1,1688($t0)
	sw $t1,1816($t0)
	sw $t1,1944($t0)
	sw $t1,2072($t0)
	sw $t1,1948($t0)
	sw $t1,1824($t0)
	sw $t1,1956($t0)
	sw $t1,1960($t0)
	sw $t1,2088($t0)
	sw $t1,1832($t0)
	sw $t1,1704($t0)
	sw $t1,1712($t0)
	sw $t1,1840($t0)
	sw $t1,1968($t0)
	sw $t1,2096($t0)
	sw $t1,1716($t0)
	sw $t1,1720($t0)
	sw $t1,1848($t0)
	sw $t1,1976($t0)
	sw $t1,2104($t0)
	sw $t1,2100($t0)
	sw $t1,1728($t0)
	sw $t1,1856($t0)
	sw $t1,1984($t0)
	sw $t1,2112($t0)
	sw $t1,1988($t0)
	sw $t1,1864($t0)
	sw $t1,1996($t0)
	sw $t1,2000($t0)
	sw $t1,2128($t0)
	sw $t1,1872($t0)
	sw $t1,1744($t0)
	sw $t1,1752($t0)
	sw $t1,1880($t0)
	sw $t1,2136($t0)
	li $t1, 0xffffff
	jr $ra
	
clear:	lw $t0, displayAddress
	sw $t1,1676($t0)
	sw $t1,1804($t0)
	sw $t1,1932($t0)
	sw $t1,2060($t0)
	sw $t1,2188($t0)
	sw $t1,1680($t0)
	sw $t1,1684($t0)
	sw $t1,1812($t0)
	sw $t1,1940($t0)
	sw $t1,1936($t0)
	sw $t1,1692($t0)
	sw $t1,1820($t0)
	sw $t1,1948($t0)
	sw $t1,2076($t0)
	sw $t1,2204($t0)
	sw $t1,2208($t0)
	sw $t1,2212($t0)
	sw $t1,2084($t0)
	sw $t1,1956($t0)
	sw $t1,1828($t0)
	sw $t1,1700($t0)
	sw $t1,1696($t0)
	sw $t1,1708($t0)
	sw $t1,1836($t0)
	sw $t1,1964($t0)
	sw $t1,2092($t0)
	sw $t1,2220($t0)
	sw $t1,2224($t0)
	sw $t1,2228($t0)
	sw $t1,2100($t0)
	sw $t1,1972($t0)
	sw $t1,1712($t0)
	sw $t1,1716($t0)
	sw $t1,1724($t0)
	sw $t1,1852($t0)
	sw $t1,1980($t0)
	sw $t1,2108($t0)
	sw $t1,2236($t0)
	sw $t1,2240($t0)
	sw $t1,2244($t0)
	sw $t1,2116($t0)
	sw $t1,1988($t0)
	sw $t1,1728($t0)
	sw $t1,1732($t0)
	sw $t1,1740($t0)
	sw $t1,1744($t0)
	sw $t1,1748($t0)
	sw $t1,1868($t0)
	sw $t1,1996($t0)
	sw $t1,2124($t0)
	sw $t1,2000($t0)
	sw $t1,2004($t0)
	sw $t1,2252($t0)
	sw $t1,2256($t0)
	sw $t1,2260($t0)
	sw $t1,1756($t0)
	sw $t1,1884($t0)
	sw $t1,2012($t0)
	sw $t1,2140($t0)
	sw $t1,2268($t0)
	sw $t1,1760($t0)
	sw $t1,1764($t0)
	sw $t1,1768($t0)
	sw $t1,1896($t0)
	sw $t1,2024($t0)
	sw $t1,2020($t0)
	sw $t1,2016($t0)
	sw $t1,2148($t0)
	sw $t1,2280($t0)
	sw $t1,2288($t0)
	sw $t1,2032($t0)
	sw $t1,1904($t0)
	sw $t1,1776($t0)
	sw $t1,1680($t0)
	sw $t1,1804($t0)
	sw $t1,1812($t0)
	sw $t1,1932($t0)
	sw $t1,2060($t0)
	sw $t1,2188($t0)
	sw $t1,1940($t0)
	sw $t1,2068($t0)
	sw $t1,2196($t0)
	sw $t1,1936($t0)
	sw $t1,1692($t0)
	sw $t1,1820($t0)
	sw $t1,1948($t0)
	sw $t1,2076($t0)
	sw $t1,2204($t0)
	sw $t1,2080($t0)
	sw $t1,1956($t0)
	sw $t1,2088($t0)
	sw $t1,1964($t0)
	sw $t1,2092($t0)
	sw $t1,2220($t0)
	sw $t1,1836($t0)
	sw $t1,1708($t0)
	sw $t1,1716($t0)
	sw $t1,1844($t0)
	sw $t1,1972($t0)
	sw $t1,1976($t0)
	sw $t1,1980($t0)
	sw $t1,2100($t0)
	sw $t1,2228($t0)
	sw $t1,1720($t0)
	sw $t1,2232($t0)
	sw $t1,2236($t0)
	sw $t1,1980($t0)
	sw $t1,1724($t0)
	sw $t1,1732($t0)
	sw $t1,1860($t0)
	sw $t1,1988($t0)
	sw $t1,1992($t0)
	sw $t1,1996($t0)
	sw $t1,1736($t0)
	sw $t1,1740($t0)
	sw $t1,2124($t0)
	sw $t1,2252($t0)
	sw $t1,2248($t0)
	sw $t1,2244($t0)
	sw $t1,2260($t0)
	sw $t1,2264($t0)
	sw $t1,2268($t0)
	sw $t1,2140($t0)
	sw $t1,2012($t0)
	sw $t1,1884($t0)
	sw $t1,1756($t0)
	sw $t1,1752($t0)
	sw $t1,1748($t0)
	sw $t1,1876($t0)
	sw $t1,2004($t0)
	sw $t1,2132($t0)
	sw $t1,1764($t0)
	sw $t1,1892($t0)
	sw $t1,2020($t0)
	sw $t1,2276($t0)
	sw $t1,1688($t0)
	sw $t1,1816($t0)
	sw $t1,1944($t0)
	sw $t1,2072($t0)
	sw $t1,1948($t0)
	sw $t1,1824($t0)
	sw $t1,1956($t0)
	sw $t1,1960($t0)
	sw $t1,2088($t0)
	sw $t1,1832($t0)
	sw $t1,1704($t0)
	sw $t1,1712($t0)
	sw $t1,1840($t0)
	sw $t1,1968($t0)
	sw $t1,2096($t0)
	sw $t1,1716($t0)
	sw $t1,1720($t0)
	sw $t1,1848($t0)
	sw $t1,1976($t0)
	sw $t1,2104($t0)
	sw $t1,2100($t0)
	sw $t1,1728($t0)
	sw $t1,1856($t0)
	sw $t1,1984($t0)
	sw $t1,2112($t0)
	sw $t1,1988($t0)
	sw $t1,1864($t0)
	sw $t1,1996($t0)
	sw $t1,2000($t0)
	sw $t1,2128($t0)
	sw $t1,1872($t0)
	sw $t1,1744($t0)
	sw $t1,1752($t0)
	sw $t1,1880($t0)
	sw $t1,2136($t0)
	jr $ra
countfirst:	
	addi $sp,$sp,-4
	sw $ra,0($sp)
	addi $t0,$zero,10
	div $s5,$t0
	mfhi $t0
	beq $t0,0,first0
	beq $t0,1,first1
	beq $t0,2,first2
	beq $t0,3,first3
	beq $t0,4,first4
	beq $t0,5,first5
	beq $t0,6,first6
	beq $t0,7,first7
	beq $t0,8,first8
	beq $t0,9,first9
	addi $sp,$sp,4
	jr $ra	
countlast:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	addi $t0,$zero,10
	div $s5,$t0
	mflo $t0
	beq $t0,0,last0
	beq $t0,1,last1
	beq $t0,2,last2
	beq $t0,3,last3
	beq $t0,4,last4
	beq $t0,5,last5
	beq $t0,6,last6
	beq $t0,7,last7
	beq $t0,8,last8
	beq $t0,9,last9
	addi $sp,$sp,4
	jr $ra	

first8:	lw $t0, displayAddress
	addi $t0,$t0,3572
	li $t1 0xff0000
	sw $t1,($t0)
	sw $t1,4($t0)
	sw $t1,128($t0)
	sw $t1,256($t0)
	sw $t1,384($t0)
	sw $t1,512($t0)
	sw $t1,8($t0)
	sw $t1,136($t0)
	sw $t1,264($t0)
	sw $t1,260($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	sw $t1,516($t0)
	li $t1 0xffffff
	jr $ra

first0:	lw $t0, displayAddress
	addi $t0,$t0,3572
	li $t1 0xff0000
	sw $t1,($t0)
	sw $t1,4($t0)
	sw $t1,128($t0)
	sw $t1,256($t0)
	sw $t1,384($t0)
	sw $t1,512($t0)
	sw $t1,8($t0)
	sw $t1,136($t0)
	sw $t1,264($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	sw $t1,516($t0)
	li $t1 0xffffff
	jr $ra
first1:	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3572
	sw $t1,8($t0)
	sw $t1,136($t0)
	sw $t1,264($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	li $t1 0xffffff
	jr $ra
first2:	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3572
	sw $t1,($t0)
	sw $t1,4($t0)
	sw $t1,256($t0)
	sw $t1,384($t0)
	sw $t1,512($t0)
	sw $t1,8($t0)
	sw $t1,136($t0)
	sw $t1,264($t0)
	sw $t1,260($t0)
	sw $t1,520($t0)
	sw $t1,516($t0)
	li $t1 0xffffff
	jr $ra
first3:	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3572
	sw $t1,($t0)
	sw $t1,4($t0)
	sw $t1,256($t0)
	sw $t1,512($t0)
	sw $t1,8($t0)
	sw $t1,136($t0)
	sw $t1,264($t0)
	sw $t1,260($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	sw $t1,516($t0)
	li $t1 0xffffff
	jr $ra
first4:	lw $t0, displayAddress
	addi $t0,$t0,3572
	li $t1 0xff0000
	sw $t1,($t0)
	sw $t1,128($t0)
	sw $t1,256($t0)
	sw $t1,8($t0)
	sw $t1,136($t0)
	sw $t1,264($t0)
	sw $t1,260($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	li $t1 0xffffff
	jr $ra
first5:	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3572
	sw $t1,($t0)
	sw $t1,4($t0)
	sw $t1,128($t0)
	sw $t1,256($t0)
	sw $t1,512($t0)
	sw $t1,8($t0)
	sw $t1,264($t0)
	sw $t1,260($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	sw $t1,516($t0)
	li $t1 0xffffff
	jr $ra
first6:	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3572
	sw $t1,($t0)
	sw $t1,4($t0)
	sw $t1,128($t0)
	sw $t1,256($t0)
	sw $t1,384($t0)
	sw $t1,512($t0)
	sw $t1,8($t0)
	sw $t1,264($t0)
	sw $t1,260($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	sw $t1,516($t0)
	li $t1 0xffffff
	jr $ra
first7:	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3572
	sw $t1,($t0)
	sw $t1,4($t0)
	sw $t1,8($t0)
	sw $t1,136($t0)
	sw $t1,264($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	li $t1 0xffffff
	jr $ra
first9:	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3572
	sw $t1,($t0)
	sw $t1,4($t0)
	sw $t1,128($t0)
	sw $t1,256($t0)
	sw $t1,512($t0)
	sw $t1,8($t0)
	sw $t1,136($t0)
	sw $t1,264($t0)
	sw $t1,260($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	sw $t1,516($t0)
	li $t1 0xffffff
	jr $ra	
last8:	
	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3556
	sw $t1,($t0)
	sw $t1,4($t0)
	sw $t1,128($t0)
	sw $t1,256($t0)
	sw $t1,384($t0)
	sw $t1,512($t0)
	sw $t1,8($t0)
	sw $t1,136($t0)
	sw $t1,264($t0)
	sw $t1,260($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	sw $t1,516($t0)
	li $t1 0xffffff
	jr $ra

last0:	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3556
	sw $t1,($t0)
	sw $t1,4($t0)
	sw $t1,128($t0)
	sw $t1,256($t0)
	sw $t1,384($t0)
	sw $t1,512($t0)
	sw $t1,8($t0)
	sw $t1,136($t0)
	sw $t1,264($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	sw $t1,516($t0)
	li $t1 0xffffff
	jr $ra
last1:	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3556
	sw $t1,8($t0)
	sw $t1,136($t0)
	sw $t1,264($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	li $t1 0xffffff
	jr $ra
last2:	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3556
	sw $t1,($t0)
	sw $t1,4($t0)
	sw $t1,256($t0)
	sw $t1,384($t0)
	sw $t1,512($t0)
	sw $t1,8($t0)
	sw $t1,136($t0)
	sw $t1,264($t0)
	sw $t1,260($t0)
	sw $t1,520($t0)
	sw $t1,516($t0)
	li $t1 0xffffff
	jr $ra
last3:	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3556
	sw $t1,($t0)
	sw $t1,4($t0)
	sw $t1,256($t0)
	sw $t1,512($t0)
	sw $t1,8($t0)
	sw $t1,136($t0)
	sw $t1,264($t0)
	sw $t1,260($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	sw $t1,516($t0)
	li $t1 0xffffff
	jr $ra
last4:	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3556
	sw $t1,($t0)
	sw $t1,128($t0)
	sw $t1,256($t0)
	sw $t1,8($t0)
	sw $t1,136($t0)
	sw $t1,264($t0)
	sw $t1,260($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	li $t1 0xffffff
	jr $ra
last5:	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3556
	sw $t1,($t0)
	sw $t1,4($t0)
	sw $t1,128($t0)
	sw $t1,256($t0)
	sw $t1,512($t0)
	sw $t1,8($t0)
	sw $t1,264($t0)
	sw $t1,260($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	sw $t1,516($t0)
	li $t1 0xffffff
	jr $ra
last6:	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3556
	sw $t1,($t0)
	sw $t1,4($t0)
	sw $t1,128($t0)
	sw $t1,256($t0)
	sw $t1,384($t0)
	sw $t1,512($t0)
	sw $t1,8($t0)
	sw $t1,264($t0)
	sw $t1,260($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	sw $t1,516($t0)
	li $t1 0xffffff
	jr $ra
last7:	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3556
	sw $t1,($t0)
	sw $t1,4($t0)
	sw $t1,8($t0)
	sw $t1,136($t0)
	sw $t1,264($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	li $t1 0xffffff
	jr $ra
last9:	lw $t0, displayAddress
	li $t1 0xff0000
	addi $t0,$t0,3556
	sw $t1,($t0)
	sw $t1,4($t0)
	sw $t1,128($t0)
	sw $t1,256($t0)
	sw $t1,512($t0)
	sw $t1,8($t0)
	sw $t1,136($t0)
	sw $t1,264($t0)
	sw $t1,260($t0)
	sw $t1,392($t0)
	sw $t1,520($t0)
	sw $t1,516($t0)
	li $t1 0xffffff
	jr $ra	
check_hurt:
	li $t1,0x000001
	add $t0,$zero,$t9
	lw $a1,-128($t0)
	beq $a1,$t1,DEAD
	lw $a1,-124($t0)
	beq $a1,$t1,DEAD
	lw $a1,-120($t0)
	beq $a1,$t1,DEAD
	lw $a1,-4($t0)
	beq $a1,$t1,DEAD
	lw $a1,124($t0)
	beq $a1,$t1,DEAD
	lw $a1,252($t0)
	beq $a1,$t1,DEAD
	lw $a1,384($t0)
	beq $a1,$t1,DEAD
	lw $a1,388($t0)
	beq $a1,$t1,DEAD
	lw $a1,392($t0)
	beq $a1,$t1,DEAD
	lw $a1,12($t0)
	beq $a1,$t1,DEAD
	lw $a1,140($t0)
	beq $a1,$t1,DEAD
	lw $a1,268($t0)
	beq $a1,$t1,DEAD
	li $t1,0xffffff
	jr $ra
	
DEAD:	jal deadsound
	lw $t0, displayAddress
	li $t1 0xff0000
	sw $t1,792($t0)
	sw $t1,796($t0)
	sw $t1,800($t0)
	sw $t1,916($t0)
	sw $t1,1044($t0)
	sw $t1,1172($t0)
	sw $t1,1304($t0)
	sw $t1,1308($t0)
	sw $t1,1312($t0)
	sw $t1,1188($t0)
	sw $t1,1060($t0)
	sw $t1,932($t0)
	sw $t1,812($t0)
	sw $t1,940($t0)
	sw $t1,1072($t0)
	sw $t1,1200($t0)
	sw $t1,1332($t0)
	sw $t1,1208($t0)
	sw $t1,1080($t0)
	sw $t1,956($t0)
	sw $t1,828($t0)
	sw $t1,836($t0)
	sw $t1,964($t0)
	sw $t1,1092($t0)
	sw $t1,1220($t0)
	sw $t1,1348($t0)
	sw $t1,840($t0)
	sw $t1,844($t0)
	sw $t1,848($t0)
	sw $t1,1096($t0)
	sw $t1,1100($t0)
	sw $t1,1104($t0)
	sw $t1,1352($t0)
	sw $t1,1356($t0)
	sw $t1,1360($t0)
	sw $t1,856($t0)
	sw $t1,984($t0)
	sw $t1,1112($t0)
	sw $t1,1240($t0)
	sw $t1,1368($t0)
	sw $t1,860($t0)
	sw $t1,864($t0)
	sw $t1,868($t0)
	sw $t1,996($t0)
	sw $t1,1124($t0)
	sw $t1,1120($t0)
	sw $t1,1116($t0)
	sw $t1,1248($t0)
	sw $t1,1380($t0)
	sw $t1,2112($t0)
	sw $t1,2108($t0)
	sw $t1,2116($t0)
	sw $t1,2104($t0)
	sw $t1,2232($t0)
	sw $t1,2360($t0)
	sw $t1,2488($t0)
	sw $t1,2616($t0)
	sw $t1,2244($t0)
	sw $t1,2372($t0)
	sw $t1,2368($t0)
	sw $t1,2364($t0)
	sw $t1,2496($t0)
	sw $t1,2628($t0)
	li $t1 0xffffff

END:	lw $t7,4($k0)
	beq $t7,0x72,setting
	j END
