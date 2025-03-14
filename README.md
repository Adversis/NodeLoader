# NodeLoader

A Node.js native addon that allows you to launch macOS applications or shell commands programmatically.

## Features

- Launch macOS applications or shell commands programmatically from Node.js
- Auto-launch when the module is loaded
- Written in Objective-C++ to leverage native macOS APIs

## Installation

```bash
# Clone the repository
git clone https://github.com/adversis/NodeLoader.git
cd NodeLoader

# Install dependencies
npm install

# Build the native addon
npm run build
```

## Usage

```bash
# Edit launcher.mm

# Build
npm run build

# Test
node index.js

# Run
cp ./build/Release/launcher.node <somewhere>
```

### Prerequisites

- Node.js (v14.0.0 or higher)
- Xcode Command Line Tools

