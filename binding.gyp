{
  "targets": [
    {
      "target_name": "launcher",
      "sources": [ "launcher.mm" ],
      "xcode_settings": {
        "GCC_ENABLE_CPP_EXCEPTIONS": "YES",
        "CLANG_CXX_LIBRARY": "libc++",
        "MACOSX_DEPLOYMENT_TARGET": "10.15",
        "OTHER_LDFLAGS": [
          "-framework Cocoa",
          "-framework Foundation"
        ]
      }
    }
  ]
}

