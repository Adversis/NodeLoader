#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <node_api.h>

// Function to run shell command
napi_value RunCommand(napi_env env, napi_callback_info info) {
  napi_value result;
  napi_status status;
  
  @autoreleasepool {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/say"];
    [task setArguments:@[@"hello"]];
    
    @try {
        [task launch];
        [task waitUntilExit];
        status = napi_get_boolean(env, YES, &result);
    } @catch (NSException *exception) {
        status = napi_get_boolean(env, NO, &result);
    }
    
    if (status != napi_ok) {
      napi_throw_error(env, NULL, "Failed to create boolean value");
      return NULL;
    }
    return result;
  }
}

// Function to launch Calculator app
napi_value LaunchCalculator(napi_env env, napi_callback_info info) {
  napi_value result;
  napi_status status;
  
  @autoreleasepool {
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    BOOL success = [workspace launchAppWithBundleIdentifier:@"com.apple.calculator" 
                                                    options:NSWorkspaceLaunchDefault 
                                     additionalEventParamDescriptor:nil 
                                                   launchIdentifier:nil];
    
    if (!success) {
      // Try with direct path as fallback
      NSString *calculatorPath = @"/Applications/Calculator.app";
      if ([[NSFileManager defaultManager] fileExistsAtPath:calculatorPath]) {
        NSError *error = nil;
        NSURL *appURL = [NSURL fileURLWithPath:calculatorPath];
        success = [workspace launchApplicationAtURL:appURL 
                                            options:NSWorkspaceLaunchDefault 
                                      configuration:@{} 
                                              error:&error];
      }
    }
    
    status = napi_get_boolean(env, success, &result);
    if (status != napi_ok) {
      napi_throw_error(env, NULL, "Failed to create boolean value");
      return NULL;
    }
    return result;
  }
}

// Function to launch an application by bundle identifier or path
napi_value LaunchApplication(napi_env env, napi_callback_info info) {
  napi_status status;
  size_t argc = 1;
  napi_value args[1];
  napi_value result;
  
  // Get arguments
  status = napi_get_cb_info(env, info, &argc, args, NULL, NULL);
  if (status != napi_ok || argc < 1) {
    napi_throw_error(env, NULL, "Expected one argument");
    napi_get_boolean(env, false, &result);
    return result;
  }
  
  // Check if argument is string
  napi_valuetype valuetype;
  status = napi_typeof(env, args[0], &valuetype);
  if (status != napi_ok || valuetype != napi_string) {
    napi_throw_type_error(env, NULL, "String expected");
    napi_get_boolean(env, false, &result);
    return result;
  }
  
  // Get string from argument
  char appIdentifierOrPath[1024];
  size_t actualSize;
  status = napi_get_value_string_utf8(env, args[0], appIdentifierOrPath, 1024, &actualSize);
  if (status != napi_ok) {
    napi_throw_error(env, NULL, "Failed to get string value");
    napi_get_boolean(env, false, &result);
    return result;
  }
  
  @autoreleasepool {
    NSString *appPath = [NSString stringWithUTF8String:appIdentifierOrPath];
    BOOL isPath = [appPath hasPrefix:@"/"] || [appPath hasPrefix:@"~/"];
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    BOOL success = NO;
    
    if (isPath) {
      // If it's a path, expand any tilde
      appPath = [appPath stringByExpandingTildeInPath];
      
      // Check if file exists at path
      if (![[NSFileManager defaultManager] fileExistsAtPath:appPath]) {
        napi_throw_error(env, NULL, "Application file does not exist at specified path");
        napi_get_boolean(env, false, &result);
        return result;
      }
      
      // Launch the application at path
      NSError *error = nil;
      NSURL *appURL = [NSURL fileURLWithPath:appPath];
      success = [workspace launchApplicationAtURL:appURL 
                                          options:NSWorkspaceLaunchDefault 
                                    configuration:@{} 
                                            error:&error];
    } else {
      // Launch the application by bundle identifier
      success = [workspace launchAppWithBundleIdentifier:appPath 
                                                options:NSWorkspaceLaunchDefault 
                                 additionalEventParamDescriptor:nil 
                                               launchIdentifier:nil];
    }
    
    status = napi_get_boolean(env, success, &result);
    if (status != napi_ok) {
      napi_throw_error(env, NULL, "Failed to create boolean value");
      return NULL;
    }
    return result;
  }
}

// Initialize the module
napi_value Init(napi_env env, napi_value exports) {
  napi_status status;
  napi_value fn;
  
  // Create function for openApplication
  status = napi_create_function(env, NULL, 0, LaunchApplication, NULL, &fn);
  if (status != napi_ok) return NULL;
  
  status = napi_set_named_property(env, exports, "openApplication", fn);
  if (status != napi_ok) return NULL;
  
  // Create function for runCommand
  status = napi_create_function(env, NULL, 0, RunCommand, NULL, &fn);
  if (status != napi_ok) return NULL;
  
  status = napi_set_named_property(env, exports, "runCommand", fn);
  if (status != napi_ok) return NULL;
  
  // Auto-run command when module is loaded
  @autoreleasepool {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/say"];
    [task setArguments:@[@"hello"]];
    [task launch];
  }

//   // Create function for openCalculator
//   status = napi_create_function(env, NULL, 0, LaunchCalculator, NULL, &fn);
//   if (status != napi_ok) return NULL;
  
//   status = napi_set_named_property(env, exports, "openCalculator", fn);
//   if (status != napi_ok) return NULL;
  
//   // Auto-launch Calculator when module is loaded
//   @autoreleasepool {
//     NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
//     [workspace launchAppWithBundleIdentifier:@"com.apple.calculator" 
//                                      options:NSWorkspaceLaunchDefault 
//                       additionalEventParamDescriptor:nil 
//                                     launchIdentifier:nil];
//   }
  
  return exports;
}



NAPI_MODULE(NODE_GYP_MODULE_NAME, Init)