# Makefile — Mot-Zaique (Flutter)
# Usage : make <cible>   (make help pour la liste)

APK_RELEASE := build/app/outputs/flutter-apk/app-release.apk
APK_DEBUG   := build/app/outputs/flutter-apk/app-debug.apk
AAB_RELEASE := build/app/outputs/bundle/release/app-release.aab

.DEFAULT_GOAL := help
.PHONY: help release apk debug bundle install test analyze l10n deps clean check

help: ## Affiche cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

release: apk ## Alias de `apk`

apk: deps ## Compile l'APK release (build/app/outputs/flutter-apk/app-release.apk)
	flutter build apk --release
	@echo ""
	@echo ">> APK release : $(APK_RELEASE)"
	@ls -lh $(APK_RELEASE) 2>/dev/null | awk '{print ">> Taille      : " $$5}'

debug: deps ## Compile l'APK debug
	flutter build apk --debug
	@echo ">> APK debug : $(APK_DEBUG)"

bundle: deps ## Compile l'App Bundle (.aab) release pour Google Play
	flutter build appbundle --release
	@echo ">> AAB release : $(AAB_RELEASE)"

install: ## Installe l'APK release sur l'appareil/emulateur connecte
	flutter install --release

check: analyze test ## Analyse + tests (comme la CI, avant un release)

test: ## Lance la suite de tests
	flutter test

analyze: ## Analyse statique
	flutter analyze

l10n: ## Regenere les traductions (gen-l10n)
	flutter gen-l10n

deps: ## Recupere les dependances
	flutter pub get

clean: ## Nettoie le build
	flutter clean
