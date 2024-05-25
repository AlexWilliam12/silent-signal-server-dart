APP=silent-signal
SRC=bin/main.dart
TARGET=target/bin

.PHONK: build
build:
	@if [ ! -d "$(TARGET)" ]; then \
		mkdir -p "$(TARGET)"; \
	fi
	@if [ ! -d "uploads" ]; then \
		mkdir -p "uploads"; \
	fi
	@echo "Building the app $(APP)..."
	dart compile exe $(SRC) -o $(TARGET)/$(APP)
	@echo "Build has finished"

.PHONK: run
run:
	@echo "Running the app $(APP)..."
	dart run $(SRC)

.PHONK: clean
clean:
	@echo "Cleaning files..."
	@if [ -e "$(TARGET)/$(APP)" ]; then \
		rm $(TARGET)/$(APP); \
	fi
	@find uploads -type f ! -name '.gitkeep' -exec rm -f {} +
	@echo "Clear has finished"