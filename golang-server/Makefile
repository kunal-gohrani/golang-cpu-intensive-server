# Makefile
BINARY_NAME=golang-webserver
ZIP_NAME=$(BINARY_NAME).zip

.PHONY: all build zip clean

all: build

build:
	@echo "Building the application..."
	go build -o dist/$(BINARY_NAME) cmd/main.go

zip: build
	@echo "Zipping the binary..."
	zip $(ZIP_NAME) $(BINARY_NAME)

clean:
	@echo "Cleaning up..."
	rm -f $(BINARY_NAME) $(ZIP_NAME)
	rm -rf dist $(ZIP_NAME)
