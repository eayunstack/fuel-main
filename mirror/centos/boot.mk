ISOLINUX_FILES:=boot.msg grub.conf initrd.img isolinux.bin memtest vesamenu.c32 vmlinuz
IMAGES_FILES:=efiboot.img
PXE_IMAGES_FILES:=initrd.img upgrade.img vmlinuz
EFI_FILES:=BOOTX64.efi MokManager.efi grub.cfg grubx64.efi
EFI_FONTS:=unicode.pf2
LIVEOS_IMAGE:=squashfs.img
ISO_DOTFILES:=.discinfo .treeinfo

# centos isolinux files
$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/isolinux/,$(ISOLINUX_FILES)):
	@mkdir -p $(@D)
	wget -nv -O $@ $(MIRROR_CENTOS_KERNEL_BASEURL)/isolinux/$(@F)

# centos EFI boot images
$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/EFI/BOOT/,$(EFI_FILES)):
	@mkdir -p $(@D)
	wget -nv -O $@ $(MIRROR_CENTOS_KERNEL_BASEURL)/EFI/BOOT/$(@F)

# centos EFI fonts
$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/EFI/BOOT/fonts/,$(EFI_FONTS)):
	@mkdir -p $(@D)
	wget -nv -O $@ $(MIRROR_CENTOS_KERNEL_BASEURL)/EFI/BOOT/fonts/$(@F)

# centos boot images
$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/images/,$(IMAGES_FILES)):
	@mkdir -p $(@D)
	wget -nv -O $@ $(MIRROR_CENTOS_KERNEL_BASEURL)/images/$(@F)

# centos PXE boot images
$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/images/pxeboot/,$(PXE_IMAGES_FILES)):
	@mkdir -p $(@D)
	wget -nv -O $@ $(MIRROR_CENTOS_KERNEL_BASEURL)/images/pxeboot/$(@F)

# centos LiveOS image
$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/LiveOS/,$(LIVEOS_IMAGE)):
	@mkdir -p $(@D)
	wget -nv -O $@ $(MIRROR_CENTOS_KERNEL_BASEURL)/LiveOS/$(@F)

# centos ISO dotfiles
$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/,$(ISO_DOTFILES)):
	wget -nv -O $@ $(MIRROR_CENTOS_KERNEL_BASEURL)/$(@F)

$(BUILD_DIR)/mirror/centos/boot.done: \
		$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/images/,$(IMAGES_FILES)) \
		$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/EFI/BOOT/,$(EFI_FILES)) \
		$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/isolinux/,$(ISOLINUX_FILES)) \
		$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/EFI/BOOT/fonts/,$(EFI_FONTS)) \
		$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/images/pxeboot/,$(PXE_IMAGES_FILES)) \
		$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/LiveOS/,$(LIVEOS_IMAGE)) \
		$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/,$(ISO_DOTFILES))
	$(ACTION.TOUCH)
