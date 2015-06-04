.PHNOY: fuel-plugins

FP_EQLX_REPO?=https://github.com/eayunstack/fuel-plugin-cinder-eqlx.git
FP_FWAAS_REPO?=https://github.com/eayunstack/fuel-plugin-neutron-fwaas.git
FP_LBAAS_REPO?=https://github.com/eayunstack/fuel-plugin-neutron-lbaas.git
FP_VPNAAS_REPO?=https://github.com/eayunstack/fuel-plugin-neutron-vpnaas.git
FP_QOS_REPO?=https://github.com/eayunstack/fuel-plugin-neutron-qos.git

FP_EQLX_COMMIT?=HEAD
FP_FWAAS_COMMIT?=HEAD
FP_LBAAS_COMMIT?=HEAD
FP_VPNAAS_COMMIT?=HEAD
FP_QOS_COMMIT?=HEAD

$(BUILD_DIR)/fuel-plugins/fuel-plugins.done:
	mkdir -p $(BUILD_DIR)/fuel-plugins
	$(ACTION.TOUCH)


# Usage:
# (eval (call build_fuel_plugin,fuel_plugin_name))
define build_fuel_plugin
$(BUILD_DIR)/fuel-plugins/fuel-plugins.done: $(BUILD_DIR)/fuel-plugins/$1.done

$(BUILD_DIR)/fuel-plugins/$1.done: \
		$(BUILD_DIR)/repos/$1.done
	fpb --build $(BUILD_DIR)/repos/$1/
	mkdir -p $(BUILD_DIR)/fuel-plugins
	cp $(BUILD_DIR)/repos/$1/*.fp $(BUILD_DIR)/fuel-plugins
	touch $(BUILD_DIR)/fuel-plugins/$1.done
endef

ifeq ($(EAYUNSTACK_BUILD),true)
$(eval $(call build_repo,fuel-plugin-cinder-eqlx,$(FP_EQLX_REPO),$(FP_EQLX_COMMIT),none,none))
$(eval $(call build_repo,fuel-plugin-neutron-fwaas,$(FP_FWAAS_REPO),$(FP_FWAAS_COMMIT),none,none))
$(eval $(call build_repo,fuel-plugin-neutron-lbaas,$(FP_LBAAS_REPO),$(FP_LBAAS_COMMIT),none,none))
$(eval $(call build_repo,fuel-plugin-neutron-vpnaas,$(FP_VPNAAS_REPO),$(FP_VPNAAS_COMMIT),none,none))
$(eval $(call build_repo,fuel-plugin-neutron-qos,$(FP_QOS_REPO),$(FP_QOS_COMMIT),none,none))
$(eval $(call build_fuel_plugin,fuel-plugin-cinder-eqlx))
$(eval $(call build_fuel_plugin,fuel-plugin-neutron-fwaas))
$(eval $(call build_fuel_plugin,fuel-plugin-neutron-lbaas))
$(eval $(call build_fuel_plugin,fuel-plugin-neutron-vpnaas))
$(eval $(call build_fuel_plugin,fuel-plugin-neutron-qos))
endif

$(BUILD_DIR)/iso/isoroot-fuel-plugins.done: \
		$(BUILD_DIR)/fuel-plugins/fuel-plugins.done
	mkdir -p $(ISOROOT)/fuel-plugins
	rsync -rp $(BUILD_DIR)/fuel-plugins/*.fp $(ISOROOT)/fuel-plugins/
	$(ACTION.TOUCH)
