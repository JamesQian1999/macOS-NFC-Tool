# NFC-Tool
A straightforward and efficient macOS application designed for cloning NFC cards onto blank cards with ease. The code have tested on ACR122U.

## 🚀 How to run the tool:
1. Install the app using the provided DMG file.
2. Launch the NFC-Tool app from your Applications folder.
3. Use the app to read the UID from the NFC card you wish to clone.
4. Write the read UID onto an empty NFC card to complete the cloning process.

## 🛠 Dependency
Before using NFC-Tool, ensure you have the following packages installed:

- [Homebrew](https://brew.sh/): The Package Manager for macOS (or Linux)
- [libnfc](https://github.com/nfc-tools/libnfc): A library that provides a high-level interface to NFC devices

To install these dependencies, open your terminal and run:

```shell
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
$ brew install libnfc
