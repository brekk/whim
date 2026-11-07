BUILD_DIR := ./build
SRC_DIR := ./src

version.lock:
	madlib install

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)

README.md: madlib.json
	pilcrow -i README.md --repo brekk/whim --auto

version.lock:
	madlib install

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
