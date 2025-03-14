const launcher = require('./build/Release/launcher');

/**
 * Opens an application on macOS
 * @param {string} appIdentifierOrPath - Bundle identifier (com.apple.Safari) or path to app (/Applications/Safari.app)
 * @returns {boolean} - Whether the operation was successful
 */
function openApplication(appIdentifierOrPath) {
  try {
    return launcher.openApplication(appIdentifierOrPath);
  } catch (error) {
    console.error('Error opening application:', error.message);
    return false;
  }
}

/**
 * Opens the Calculator app
 * @returns {boolean} - Whether the operation was successful
 */
function openCalculator() {
  try {
    return launcher.openCalculator();
  } catch (error) {
    console.error('Error opening Calculator:', error.message);
    return false;
  }
}

// Export the functions
module.exports = { 
  openApplication,
  openCalculator
};

// If running this file directly, open Calculator by default or use provided app
if (require.main === module) {
  const appToOpen = process.argv[2];
  
  if (!appToOpen) {
    // Default to Calculator if no argument provided
    console.log('No application specified, launching Calculator...');
    const result = openCalculator();
    console.log(`Opening Calculator: ${result ? 'Success' : 'Failed'}`);
  } else {
    // Open specified application
    const result = openApplication(appToOpen);
    console.log(`Opening ${appToOpen}: ${result ? 'Success' : 'Failed'}`);
  }
}