# makefile
#
# @since       2015-02-21
# @category    Library
# @package     Color
# @author      Nicola Asuni <info@tecnick.com>
# @copyright   2015-2015 Nicola Asuni - Tecnick.com LTD
# @license     http://www.gnu.org/copyleft/lesser.html GNU-LGPL v3 (see LICENSE.TXT)
# @link        https://github.com/tecnick.com/tc-lib-color
#
# This file is part of tc-lib-color software library.
# ----------------------------------------------------------------------------------------------------------------------

# List special make targets that are not associated with files
.PHONY: help all test docs phpcs phpcs_test phpcbf phpcbf_test phpmd phpmd_test phpcpd phploc phpdep report qa qa_test qa_all clean build build_dev update server install uninstall rpm deb dist

# Detect the type of package to build based on the current operating system
OSPKG=$(shell if [ -f "/etc/redhat-release" ]; then echo "rpm"; else echo "deb"; fi )

# Project version
VERSION=`cat VERSION`

# Project release number (packaging build number)
RELEASE=`cat RELEASE`

# Default installation path for code
LIBPATH=/usr/share/php/Com/Tecnick/Color/

# Default installation path for documentation
DOCPATH=/usr/share/doc/php-tc-lib-color/

# Installation path for the code
PATHINSTBIN=$(DESTDIR)$(LIBPATH)

# Installation path for documentation
PATHINSTDOC=$(DESTDIR)$(DOCPATH)

# Current directory
CURRENTDIR=`pwd`

# RPM Packaging path (where RPMs will be stored)
PATHRPMPKG=$(CURRENTDIR)/target/RPM

# DEB Packaging path (where DEBs will be stored)
PATHDEBPKG=$(CURRENTDIR)/target/DEB

# Default port number for the example server
PORT?=8000

# Composer executable (disable APC to as a work-around of a bug)
COMPOSER=$(shell which php) -d "apc.enable_cli=0" $(shell which composer)

# --- MAKE TARGETS ---

# Display general help about this command
help:
	@echo ""
	@echo "Welcome to tc-lib-color make."
	@echo "The following commands are available:"
	@echo ""
	@echo "    make qa          : Run the targets: test, phpcs and phpmd"
	@echo "    make qa_test     : Run the targets: phpcs_test and phpmd_test"
	@echo "    make qa_all      : Run the targets: qa and qa_all"
	@echo ""
	@echo "    make test        : Run the PHPUnit tests"
	@echo ""
	@echo "    make phpcs       : Run PHPCS on the source code and show any style violations"
	@echo "    make phpcs_test  : Run PHPCS on the test code and show any style violations"
	@echo ""
	@echo "    make phpcbf      : Run PHPCBF on the source code to fix style violations"
	@echo "    make phpcbf_test : Run PHPCBF on the test code to fix style violations"
	@echo ""
	@echo "    make phpmd       : Run PHP Mess Detector on the source code"
	@echo "    make phpmd_test  : Run PHP Mess Detector on the test code"
	@echo ""
	@echo "    make phpcpd      : Run PHP Copy/Paste Detector"
	@echo "    make phploc      : Run PHPLOC to analyze the structure of the project"
	@echo "    make phpdep      : Run JDepend static analysis and generate graphs"
	@echo "    make report      : Run the targets: phpcpd, phploc and phpdep"
	@echo ""
	@echo "    make docs        : Generate source code documentation"
	@echo ""
	@echo "    make clean       : Delete the vendor and target directory"
	@echo "    make build       : Clean and download the composer dependencies"
	@echo "    make build_dev   : Clean and download the composer dependencies including dev ones"
	@echo "    make update      : Update composer dependencies"
	@echo ""
	@echo "    make server     : Run the example server at http://localhost:"$(PORT)
	@echo ""
	@echo "    make install    : Install this library"
	@echo "    make uninstall  : Remove all installed files"
	@echo ""
	@echo "    make rpm        : Build an RPM package"
	@echo "    make dist       : Execute tests and build the RPM package"
	@echo ""

# alias for help target
all: help

# run the PHPUnit tests
test:
	./vendor/bin/phpunit test

# generate docs using phpDocumentor
docs:
	@rm -rf target/phpdocs && ./vendor/phpdocumentor/phpdocumentor/bin/phpdoc project:run --target="target/phpdocs/" --directory="src/" --ignore="vendor/" --encoding="UTF-8" --title="tc-lib-color" --parseprivate

# run PHPCS on the source code and show any style violations
phpcs:
	@./vendor/bin/phpcs --ignore="./vendor/" --standard=psr2 src

# run PHPCS on the test code and show any style violations
phpcs_test:
	@./vendor/bin/phpcs --standard=psr2 test

# run PHPCBF on the source code and show any style violations
phpcbf:
	@./vendor/bin/phpcbf --ignore="./vendor/" --standard=psr2 src

# run PHPCBF on the test code and show any style violations
phpcbf_test:
	@./vendor/bin/phpcbf --standard=psr2 tests

# Run PHP Mess Detector on the source code
phpmd:
	@./vendor/bin/phpmd src text codesize,unusedcode,naming,design --exclude vendor

# run PHP Mess Detector on the test code
phpmd_test:
	@./vendor/bin/phpmd test text unusedcode,naming,design

# run PHP Copy/Paste Detector
phpcpd:
	mkdir -p ./target/report/
	@./vendor/bin/phpcpd src --exclude vendor > ./target/report/phpcpd.txt

# run PHPLOC to analyze the structure of the project
phploc:
	mkdir -p ./target/report/
	@./vendor/bin/phploc src --exclude vendor > ./target/report/phploc.txt

# PHP static analysis
phpdep:
	mkdir -p ./target/report/
	@./vendor/bin/pdepend --jdepend-xml=./target/report/dependencies.xml --summary-xml=./target/report/metrics.xml --jdepend-chart=./target/report/dependecies.svg --overview-pyramid=./target/report/overview-pyramid.svg --ignore=vendor ./src

# run the targets: phpcpd, phploc and phpdep
report: phpcpd phploc phpdep

# alias to run targets: test, phpcs and phpmd
qa: test phpcs phpmd

# alias to run targets: phpcs_test and phpmd_test
qa_test: phpcs_test phpmd_test

# alias to run targets: qa and qa_test
qa_all: qa qa_test

# delete the vendor and target directory
clean:
	rm -rf ./vendor/

# clean and download the composer dependencies
build:
	rm -rf ./vendor/ && ($(COMPOSER) -n install --no-dev --no-interaction)

# clean and download the composer dependencies including dev ones
build_dev:
	rm -rf ./vendor/ && ($(COMPOSER) -n install --no-interaction)

# update composer dependencies
update:
	($(COMPOSER) -n update --no-interaction)

# Run the development server
server:
	php -t example -S localhost:$(PORT)

# Install this application
install: uninstall
	mkdir -p $(PATHINSTBIN)
	cp -rf ./src/* $(PATHINSTBIN)
	cp -rf ./vendor $(PATHINSTBIN)
	find $(PATHINSTBIN) -path $(PATHINSTBIN) -prune -o -type d -exec chmod 755 {} \;
	find $(PATHINSTBIN) -path $(PATHINSTBIN) -prune -o -type f -exec chmod 644 {} \;
	find $(PATHINSTBIN) -path $(PATHINSTBIN) -prune -o -type f -name '*.php' -exec chmod 755 {} \;
	mkdir -p $(PATHINSTDOC)
	cp -f ./LICENSE.TXT $(PATHINSTDOC)
	cp -f ./README.md $(PATHINSTDOC)
	cp -f ./VERSION $(PATHINSTDOC)
	chmod -R 644 $(PATHINSTDOC)*

# Remove all installed files
uninstall:
	rm -rf $(PATHINSTBIN)
	rm -rf $(PATHINSTDOC)

# --- PACKAGING ---

# Build the RPM package for RedHat-like Linux distributions
rpm: build
	rm -rf $(PATHRPMPKG)
	rpmbuild --define "_topdir $(PATHRPMPKG)" --define "_version $(VERSION)" --define "_release $(RELEASE)" --define "_current_directory $(CURRENTDIR)" --define "_libpath $(LIBPATH)" --define "_docpath $(DOCPATH)" --define "_configpath $(CONFIGPATH)" -bb resources/rpm/rpm.spec

# Build the DEB package for Debian-like Linux distributions
deb: build
	rm -rf $(PATHDEBPKG)/SRC
	mkdir -p $(PATHDEBPKG)/SRC/DEBIAN
	mkdir -p $(PATHDEBPKG)/SRC$(LIBPATH)
	cp -rf ./src/* $(PATHDEBPKG)/SRC$(LIBPATH)
	cp -rf ./vendor $(PATHDEBPKG)/SRC$(LIBPATH)
	find $(PATHDEBPKG)/SRC -path $(PATHDEBPKG)/SRC -prune -o -type d -exec chmod 755 {} \;
	find $(PATHDEBPKG)/SRC -path $(PATHDEBPKG)/SRC -prune -o -type f -exec chmod 644 {} \;
	find $(PATHDEBPKG)/SRC -path $(PATHDEBPKG)/SRC -prune -o -type f -name '*.php' -exec chmod 755 {} \;
	mkdir -p $(PATHDEBPKG)/SRC/$(DOCPATH)
	cp -f ./LICENSE.TXT $(PATHDEBPKG)/SRC/$(DOCPATH)
	cp -f ./README.md $(PATHDEBPKG)/SRC/$(DOCPATH)
	cp -f ./VERSION $(PATHDEBPKG)/SRC/$(DOCPATH)
	cp -f ./resources/deb/copyright $(PATHDEBPKG)/SRC/$(DOCPATH)
	chmod -R 644 $(PATHDEBPKG)/SRC/$(DOCPATH)*
	cp -f ./resources/deb/copyright $(PATHDEBPKG)/SRC/DEBIAN/
	cp -f ./resources/deb/control $(PATHDEBPKG)/SRC/DEBIAN/
	sed -ri "s/~#VERSION#~/$(VERSION)/" $(PATHDEBPKG)/SRC/DEBIAN/control
	sed -ri "s/~#INSTSIZE#~/`du -s --apparent-size --block-size=1024 ./target/DEB/SRC/ | grep -oh '^[0-9]*'`/" $(PATHDEBPKG)/SRC/DEBIAN/control
	fakeroot dpkg-deb --build $(PATHDEBPKG)/SRC $(PATHDEBPKG)

#	sed -ri "s/~#INSTSIZE#~/`du -sb ./target/DEB/SRC/ | grep -oh '^[0-9]*'`/" $(PATHDEBPKG)/SRC/DEBIAN/control

# Execute all tests, generate documentation, generate reports and build the package
dist: build_dev qa_all report docs $(OSPKG)
