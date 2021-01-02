define BuildPackage1
  $(eval $(Package/Default))
  $(eval $(Package/$(1)))

  $(if $(DUMP), \
    $(if $(CHECK),,$(Dumpinfo/Package)), \
    $(foreach target, \
      $(if $(Package/$(1)/targets),$(Package/$(1)/targets), \
        $(if $(PKG_TARGETS),$(PKG_TARGETS), ipkg) \
      ), $(BuildTarget/$(target)) \
    ) \
  )
endef

LUCI_NAME?=$(notdir ${CURDIR})
LUCI_TYPE?=$(word 2,$(subst -, ,$(LUCI_NAME)))
LUCI_BASENAME?=$(patsubst luci-$(LUCI_TYPE)-%,%,$(LUCI_NAME))
LUCI_LANGUAGES:=$(sort $(filter-out templates,$(notdir $(wildcard ${CURDIR}/po/*))))
LUA_LIBRARYDIR = /usr/lib/lua
LUCI_LIBRARYDIR = $(LUA_LIBRARYDIR)/luci

LUCI_LANG.bg=български (Bulgarian)
LUCI_LANG.ca=Català (Catalan)
LUCI_LANG.cs=Čeština (Czech)
LUCI_LANG.de=Deutsch (German)
LUCI_LANG.el=Ελληνικά (Greek)
LUCI_LANG.en=English
LUCI_LANG.es=Español (Spanish)
LUCI_LANG.fr=Français (French)
LUCI_LANG.he=עִבְרִית (Hebrew)
LUCI_LANG.hi=हिंदी (Hindi)
LUCI_LANG.hu=Magyar (Hungarian)
LUCI_LANG.it=Italiano (Italian)
LUCI_LANG.ja=日本語 (Japanese)
LUCI_LANG.ko=한국어 (Korean)
LUCI_LANG.mr=मराठी (Marathi)
LUCI_LANG.ms=Bahasa Melayu (Malay)
LUCI_LANG.nb_NO=Norsk (Norwegian)
LUCI_LANG.pl=Polski (Polish)
LUCI_LANG.pt_BR=Português do Brasil (Brazialian Portuguese)
LUCI_LANG.pt=Português (Portuguese)
LUCI_LANG.ro=Română (Romanian)
LUCI_LANG.ru=Русский (Russian)
LUCI_LANG.sk=Slovenčina (Slovak)
LUCI_LANG.sv=Svenska (Swedish)
LUCI_LANG.tr=Türkçe (Turkish)
LUCI_LANG.uk=Українська (Ukrainian)
LUCI_LANG.vi=Tiếng Việt (Vietnamese)
LUCI_LANG.zh_Hans=中文 (Chinese)
LUCI_LANG.zh_Hant=臺灣華語 (Taiwanese)

LUCI_LC_ALIAS.nb_NO=no
LUCI_LC_ALIAS.pt_BR=pt-br
LUCI_LC_ALIAS.zh_Hans=zh-cn
LUCI_LC_ALIAS.zh_Hant=zh-tw

ifeq ($(PKG_NAME),luci-base)
 define Package/luci-base/config

   menu "Translations"$(foreach lang,$(LUCI_LANGUAGES),

     config LUCI_LANG_$(lang)
	   tristate "$(shell echo '$(LUCI_LANG.$(lang))' | sed -e 's/^.* (\(.*\))$$/\1/') ($(lang))")

   endmenu
 endef
endif

define LuciTranslation
  define Package/luci-i18n-$(LUCI_BASENAME)-$(1)
    SECTION:=luci
    CATEGORY:=LuCI
    TITLE:=$(PKG_NAME) - $(1) translation
    HIDDEN:=1
    DEFAULT:=LUCI_LANG_$(2)||(ALL&&m)
    DEPENDS:=$(PKG_NAME)
    PKGARCH:=all
  endef

  define Package/luci-i18n-$(LUCI_BASENAME)-$(1)/description
    Translation for $(PKG_NAME) - $(LUCI_LANG.$(2))
  endef

  define Package/luci-i18n-$(LUCI_BASENAME)-$(1)/install
	$$(INSTALL_DIR) $$(1)/etc/uci-defaults
	echo "uci set luci.languages.$(subst -,_,$(1))='$(LUCI_LANG.$(2))'; uci commit luci" \
		> $$(1)/etc/uci-defaults/luci-i18n-$(LUCI_BASENAME)-$(1)
	$$(INSTALL_DIR) $$(1)$(LUCI_LIBRARYDIR)/i18n
	$(foreach po,$(wildcard ${CURDIR}/po/$(2)/*.po), \
		po2lmo $(po) \
			$$(1)$(LUCI_LIBRARYDIR)/i18n/$(basename $(notdir $(po))).$(1).lmo;)
  endef

  define Package/luci-i18n-$(LUCI_BASENAME)-$(1)/postinst
	[ -n "$$$${IPKG_INSTROOT}" ] || {
		(. /etc/uci-defaults/luci-i18n-$(LUCI_BASENAME)-$(1)) && rm -f /etc/uci-defaults/luci-i18n-$(LUCI_BASENAME)-$(1)
		exit 0
	}
  endef

  LUCI_LANG_PACKAGES := luci-i18n-$(LUCI_BASENAME)-$(1)

endef

  $(foreach lang,$(LUCI_LANGUAGES),$(eval $(call LuciTranslation,$(firstword $(LUCI_LC_ALIAS.$(lang)) $(lang)),$(lang))))
  $(foreach pkg,$(LUCI_LANG_PACKAGES),$(eval $(call BuildPackage1,$(pkg))))
