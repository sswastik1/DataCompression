#
# CMPUT 229 Student Submission License
# Version 1.0
# Copyright 2021 <Swastik Sharma>
#
# This software is distributed to students in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the disclaimer below in the documentation
#    and/or other materials provided with the distribution.
#
# 2. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
#          cmput229@ualberta.ca
#
#---------------------------------------------------------------
# CCID:                 < swastik >
# Lecture Section:      < A1 >
# Instructor:           < J. Nelson Amaral  >
# Lab Section:          < D01  >
# Teaching Assistant:   < Siva Chowdeswar Nandipati, Islam Ali >
#---------------------------------------------------------------
# 

.include "common.s"

#----------------------------------
#        STUDENT SOLUTION
#----------------------------------


#---------------------------------------------------------------------------------------------
# buildTables
#
# Arguments:
#	a0: the address of the contents of a valid input file in memory terminated by the end-of-file sentinel word.
#	a1: the address of pre-allocated memory in which to store the wordTable.
#	a2: the address of pre-allocated memory in which to store the countTable.
#
# Return Values:
#	a0: the number of words in the wordTable (is equivalent to the number of counts in the countTable)
#
# Generates a wordTable alongside a correlated countTable
#---------------------------------------------------------------------------------------------
buildTables:
	lw t0, 0(a0) 				# loading the first word of input to t0
	beq t0, zero, Exit1			# exiting if their is no input 
	sw t0, 0(a1)				# storing word to wordTable
	li t3, 1				# keeping the record of number of words counted
	sb t3, 0(a2)  				# increse the count table count for first element
	
	newInput:
		mv t1, a1			# moving address of wordtable to t1
		mv t2, a2			# moving address of countTable to t2
		addi a0, a0, 4			# incresing the address of input file
		lw t0, 0(a0)			# loading the updated word to t0
		beq t0, zero, Exit1 		# exiting if their is no next word in input file
		li t6, 1 			# counting the bracket value
	
	makeTable:
		bgt t6, t3, newWord		# If limit reached of the wordTable (t3 = unique word count); add a new word in it
		lw t5, 0(t1) 			# storing word in t5 but not in t1 because if iterated again it would not be able to access t1's memory address because it has cahnged to value at t1		
		beq t5, t0, oldWord  		# If found a word equal to something in wordTable just increase count of it
		addi t1, t1, 4
		addi t2, t2, 1
		addi t6, t6, 1			# keeping record of the words in wordTable 
		jal zero, makeTable		# looping again
	
	newWord: 
		sw t0, 0(t1)			# storing the loaded word in wordCount as it is a new word
		addi t3, t3, 1			# increasing count of t3 (unique words)
		addi t4, zero, 1		# t4 = total number of words counted
		sb t4, 0(t2) 			# putting count of the new word = 1
		jal zero, newInput		# loop back to newInput
	
	oldWord: 
		sw t0, 0(t1)			# storing the word in word table at the same place it exists
		lb t4, 0(t2)			# putting t4 = value stored at respective countTable of the element in word table
		addi t4, t4, 1
		sb t4, 0(t2) 
		jal zero, newInput	
	

	Exit1:
		add a0, t3, zero		# putting the value to t3 in a0 and exiting
	
		# TODO: replace this instruction with the correct output when implementing your solution
	ret

#---------------------------------------------------------------------------------------------
# encode
#
# Arguments:
#	a0: the address to the contents of a valid input file in memory.
#	a1: the address of a dictionary table in memory.
#	a2: the number of words in the dictionary.
#	a3: the address of pre-allocated memory in which to store the output.
#	a7: Storing the size of the output
#
# Return Values:
#	a0: the size of the output in bytes (not including the end-of-file sentinel word at the end).
#
# Compresses the contents of an input file
#---------------------------------------------------------------------------------------------
encode:
	li t3, 0 
	li a7, 0
	DictAddi:
		mv t1, a1     			# moving address of a1 to t1
		lw t2, 0(t1)
		sw t2, 0(a3)
		addi t3, t3, 1
		addi a3, a3, 4
		addi t1, t1, 4
		addi a1, a1, 4
		addi a7, a7, 4
		beq t3, a2, Loop1		# checking if reached the number of words in dict.  then shift to Loop1
		jal zero, DictAddi		# initiating loop
		
	Loop1:	
		addi a3, a3, 1	
		addi a7, a7, 1			# decresing by 3 bytes because we need to store byte just 1 byte of null
		addi t3, zero, 0
		sb t3, 0(a3)
		jal zero, ReadInput		# start reading input
		
	ReadInput:
		mv t1, a1			# storing read value in t0 and address of dict. in t1
		lw t0, 0(a0)
		beq t0, zero, Exit2 		# exit if no new word
		li t6, 1  

	Loop2:
		bgt t6, a2, AddWord		# Go to Addword if it is not in the Dict.
		lw t5, 0(t1) 			# storing word in t5 but not in t1 because if iterated again it would not be able to access t1's memory address because it has cahnged to value at t1		
		beq t5, t0, SameWord  
		addi t1, t1, 4
		addi t6, t6, 1 
		jal zero, Loop2
		
	AddWord:
		lb t2, 0(a0) 			# Adding the word byte by byte in reverse order
		sb t2, 0(a3)
		srli t2, t2, 8			# shifting right by 8 bits to store new byte
		sb t2, 1(a3)
		srli t2, t2, 8
		sb t2, 2(a3)
		srli t2, t2, 8
		sb t2, 3(a3)
		addi a0, a0, 4			# Increseing the address of input file by 4
		addi a7, a7, 4			# Increasing the register value by 4 which is storing count
		jal zero, ReadInput		# Looping back to read all the input words
	
	SameWord:
		lb t2, 0(a0)			
		sb t2, 3(a3)
		srli t2, t2, 8
		sb t2, 2(a3)
		srli t2, t2, 8
		sb t2, 1(a3)
		srli t2, t2, 8
		sb t2, 0(a3)
		addi a0, a0, 4			# Increseing the address of input file by 4
		addi a7, a7, 4			# Increasing the register value by 4 which is storing count
		jal zero, ReadInput		# Looping back to read all the input words
				
	Exit2:	
	

		addi a0, a7, 0	# Finally putting back the value of a7 in a0 
		ret
	
#------------------     end of student solution     ----------------------------------------------------------------------------



#-------------------------------------------------------------------------------------------------------------------------------
# buildDictionary
#
# Arguments:
#	a0: pointer to a wordTable in memory.
#	a1: pointer to a corresponding countTable in memory.
#	a2: the number of elements in either table.
#	a3: pointer to pre-allocated memory in which to store dictionary table.
#
# Return Values:
#	a0: the number of word elements in the dictionary.
#
# Generates a dictionary table.
#-------------------------------------------------------------------------------------------------------------------------------
buildDictionary: # provided to students
	addi sp, sp, -32
	sw ra, 0(sp)	# storing registers
	sw s0, 4(sp) 
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)
	sw s4, 20(sp)
	sw s5, 24(sp)
	sw s6, 28(sp)


	mv s0, a0	# s0 <- address to wordTable
	mv s1, a1	# s1 <- address to countTable
	mv s2, a2	# s2 <- number of elements in wordTable or countTable
	li s3, 0	# s3 <- tableIndex
	mv s4, a3	# s4 <- dictPos
	li s5, 2	# s5 <- threshold
	mv s6, a3	# s6 <- dictStart
	
	tableIteration:
		bge s3, s2, endOfTable	# if reached the end of the tables
		add t0, s1, s3	# t0 <- address of count in countTable at index tableIndex
		lbu t1, 0(t0)	# t1 <- count
		bge t1, s5, addToDict	# if a count is >= threshold, add the corresponding word to the dictionary
		
		addi s3, s3, 1	# updating tableIndex
		
		j tableIteration
		
		addToDict:
			slli t0, s3, 2	# t0 <- s3 * 4 = word offset corresponding to tableIndex
			add t0, s0, t0	# t0 <- address of word in wordTable at index tableIndex
			lw t1, 0(t0)	# t1 <- word
			
			addi s3, s3, 1	# updating tableIndex
			
			sw t1, 0(s4)	# store the word in the dictionary
			addi s4, s4, 4	# update dictPos
			
			j tableIteration
		
	endOfTable:
		
		sub t0, s4, s6	# t0 <- size of dictionary
		srli a0, t0, 2	# a1 <- t0 / 4 = number of words in dictionary
		
		lw ra, 0(sp)	# restoring registers
		lw s0, 4(sp) 
		lw s1, 8(sp)
		lw s2, 12(sp)
		lw s3, 16(sp)
		lw s4, 20(sp)
		lw s5, 24(sp)
		lw s6, 28(sp)
		addi sp, sp, 32
		
		ret