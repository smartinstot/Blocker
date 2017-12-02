############################
### Generic AVR Makefile ###
###  By: David Bascelli  ###
############################

############################
#        How to use        #
############################
# This makefile is preconfigured to work with the programmer that CURC has. You must simply
# set you configuration parameters then run make to compile. 
# Typing "make" will simply compile your code. There are two possible build targets 
# isp     : for the atmel ice programmer that we have to load onto a fresh atmel chip
#           type "make isp" to load chip through programmer
# Arduino : if you have an Arduino chip, this will program it like the ide does. It is
#           limited by the bootloader (ie it cannot change fuses)
#           type "make arduino" to load code onto arduino
# fuse    : The avr chips have certain fuses that can change configuration parameters of
#           the chip. They need only be set once. Their are three fuses, a good calculator
#           to figure out what their values are is :
#           http://www.engbedded.com/fusecalc/
#           however you can also just read the datasheet.
#           Be very careful, wrong fuse configurations can permanently destroy the chip
#           (ie one of the fuses disables programming).
#           This will only work with the programmer
#           type "make fuse" to set fuses. You only need to type this when you change fuse values


############################
# Configuration Parameters #
############################
DEVICE_COMPILE = atmega644
DEVICE_ISP     = m644
PROGRAMMER     = usbasp
NAME = main
F_CPU = 16000000 #16 MHz clock
############################


############################
#        Fuse Values       #
############################
LFUSE  = lfuse:w:0x62:m
HFUSE  = hfuse:w:0xdf:m
EFUSE  = efuse:w:0xff:m
############################



############################
###    Build Targets     ###
############################

all: ${NAME}.hex

SOURCES =  $(wildcard *.c)
SOURCES += $(wildcard freeRTOS/*.c)
SOURCES += $(wildcard lcd/*.c)
OBJECTS =  $(patsubst %.c,%.o,${SOURCES})
INCLUDE =  -IfreeRTOS -Ilcd

%.o : %.c
	avr-gcc -g -std=c99 -Os -mmcu=${DEVICE_COMPILE} -DF_CPU=${F_CPU} ${INCLUDE} -c $*.c -o $*.o
   
${NAME}.elf : ${OBJECTS}
	avr-gcc -g -mmcu=${DEVICE_COMPILE} -o ${NAME}.elf ${OBJECTS} 

${NAME}.hex : ${NAME}.elf
	avr-objcopy -O ihex ${NAME}.elf ${NAME}.hex

.phoney : isp
isp: ${NAME}.hex
	avrdude -P usb -v -c ${PROGRAMMER} -p ${DEVICE_ISP} -U flash:w:${NAME}.hex -F

.phoney : fuse
fuse :
	avrdude -P usb -c ${PROGRAMMER} -p ${DEVICE_ISP} -U ${LFUSE} -U ${HFUSE} -U ${EFUSE}

.phoney : arduino
arduino : ${NAME}.hex
	avrdude -P /dev/ttyACM0 -c arduino -p ${DEVICE_ISP} -U flash:w:${NAME}.hex -b115200 -D

.phoney : clean 
clean:
	rm -f *.hex *.o *.elf freeRTOS/*.o lcd/*.o
