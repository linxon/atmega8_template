# Author: Yury Martynov <email@linxon.ru>
# License: MIT

include Makefile.cfg

ifndef DEVICE
DEVICE     = atmega8
endif

ifndef CLOCK
CLOCK      = 16000000L
endif

ifndef PROGRAMMER
PROGRAMMER = -p atmega8 -c usbasp -P usb
endif

ifndef SOURCES
SOURCES = main.c
endif

ifndef OBJECTS
OBJECTS    = main.o
endif

ifndef FUSES
FUSES      = -U lfuse:w:0xFF:m -U hfuse:w:0xC4:m #-U efuse:w:0xFF:m
endif

ifndef COMPILE_PARAMS
COMPILE_PARAMS   = -Wall -w -Wl,--gc-sections -ffunction-sections -fdata-sections -Os -std=gnu11 -I.
endif

FLASH_HEXFILE    = flash.hex
FLASH_BINFILE    = flash.bin
EEPROM_BINFILE   = eeprom.bin

HFUSE_FILE       = hfuse.hex
LFUSE_FILE       = lfuse.hex
EFUSE_FILE       = efuse.hex

ifndef AVRDUDE
AVRDUDE = avrdude $(PROGRAMMER) -p $(DEVICE)
endif

######################################################################
######################################################################

COMPILE = avr-gcc $(COMPILE_PARAMS) -DF_CPU=$(CLOCK) -mmcu=$(DEVICE)

all:	main.hex

.c.o:
	$(COMPILE) -c $< -o $@

.S.o:
	$(COMPILE) -x assembler-with-cpp -c $< -o $@

.c.s:
	$(COMPILE) -S $< -o $@

flash:	all
	$(AVRDUDE) -U flash:w:main.hex:i

erase:
	$(AVRDUDE) -e

flash-eeprom:
	$(AVRDUDE) -U eeprom:w:$(EEPROM_BINFILE):r

get-flash-bin:
	$(AVRDUDE) -U flash:r:$(FLASH_BINFILE):r

get-flash-hex:
	$(AVRDUDE) -U flash:r:$(FLASH_HEXFILE):i

get-eeprom-bin:
	$(AVRDUDE) -U eeprom:r:$(EEPROM_BINFILE):r

get-fuse:
	$(AVRDUDE) -U hfuse:r:$(HFUSE_FILE):r -U lfuse:r:$(LFUSE_FILE):r #-U efuse:r:$(EFUSE_FILE):r

fuse:
	$(AVRDUDE) $(FUSES)

install: flash fuse

clean:
	rm -f main.hex main.elf $(OBJECTS) $(FLASH_HEXFILE) $(FLASH_BINFILE) $(EEPROM_BINFILE) $(HFUSE_FILE) $(LFUSE_FILE) $(EFUSE_FILE)

_clean-after:
	rm -f $(OBJECTS) main.hex

main.elf: $(OBJECTS)
	$(COMPILE) -o main.elf $(OBJECTS)
	avr-strip -s main.elf

main.hex: main.elf _clean-after
	avr-objcopy --strip-all -j .text -j .data -O ihex main.elf main.hex
	avr-size -C --mcu=$(DEVICE) main.elf

disasm:	main.elf
	avr-objdump -d main.elf

cpp:
	$(COMPILE) -E $(SOURCES)
