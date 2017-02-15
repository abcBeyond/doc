
TAR_BOOT:=boot.bin
SOU_BOOT:=boot.asm
TAR_LOADER:=loader.bin
SOU_LOADER:=loader.asm

.PHONY:all clean umount

all:$(TAR_BOOT) $(TAR_LOADER)
	dd if=$(TAR_BOOT) of=a.img bs=512 count=1 conv=notrunc
	mount -o loop a.img /mnt/floppy/
	cp $(TAR_LOADER) /mnt/floppy/
	umount /mnt/floppy

$(TAR_BOOT):$(SOU_BOOT)
	nasm $< -o $@

$(TAR_LOADER):$(SOU_LOADER)
	nasm $< -o $@

clean:
	#umount /mnt/floppy
	rm *.bin	
umount:
	umount /mnt/floppy
