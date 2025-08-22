# Default to Unix-style separator
DATASEP := :

# Detect Windows
ifeq ($(OS),Windows_NT)
	DATASEP := ;
endif

# Run the app in development
run:
	python main.py

# Build standalone app for current OS
build:
ifeq ($(OS),Windows_NT)
	pyinstaller --onefile --windowed --name EasyFolder --add-data "UI;UI" --icon easyfolder.ico main.py
else
	pyinstaller --onefile --windowed --name EasyFolder --add-data "UI:UI" --icon EasyFolder.icns main.py
endif

# Clean previous builds
clean:
	rm -rf build dist *.spec
