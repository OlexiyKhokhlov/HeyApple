# MacOS Network Extention example
This is complete example of the Mac "Network Extension" in a project based on C++ and CMake.

## Motivation
Once I had to make a network extension for Mac. I was heavy confused. The official documentation leaved more questions than provided the answers. Unofficial manuals as usual are based on XCode. So suggest like - "press the button in the XCode and it resolves your problem" doesn't help as well. Github has a few great samples. But it wasn't so simple to build it and run in my own environment. So I have made this example. I hope it helps to wide range of developers.

### Apple developer settings
The big brother watching you! So without Apple signing you cannot properly build, install and run your own network extension. Even for debug or education reason you cannot do that!
This point doesn't look so simple since there are two different types os signing - the release signing and the developer signing. This example shows how to work with both cases. But  if you want to save a time you can use only one signing case.
So what do you need for signing? First of all you should create apple developer account if you haven't. When it is done follow the next steps:
* Create an App ID for the main application. Where Bundle ID looks like - 'com.CompanyName.HeyApple'. Capabilities "Network Extensions" and "System Extension" should be enabled;
* Create an App ID for the network extension. Where Bundle ID looks like - 'com.CompanyName.HeyApple.Extension'. Capabilities "Network Extensions" and "System Extension" should be enabled;

If you want to use developer signing:
* Add  UDID/UUID of your Mac machine to the account;
* Create a certificate for developer build. Certificate type should be - "Development";
* Create a provisioning profile for the main application. It should have enabled "Network Extensions" and "System Extension" capabilities. Should refer to the main App ID, developer certificate, developer machine UDID;
* Create a provisioning profile for the network extension. It should have enabled "Network Extensions" and "System Extension" capabilities. Should refer to the extension App ID, developer certificate, developer machine UDID;

If you want to use release signing:
* Create a certificate for release build. Certificate type should be - "Developer ID Application";
* Create a provisioning profile for the main application. It should have enabled "Network Extensions" and "System Extension" capabilities. Should refer to the main App ID, release certificate;
* Create a provisioning profile for the network extension. It should have enabled "Network Extensions" and "System Extension" capabilities. Should refer to the extension App ID, release certificate;

After the creation every certificate should be donloaded and installed. Every provisioning profile should be downloaded inside the source tree by the next path:
* './app/MainApp.provisionprofile' - main app release build provisioning profile;
* './app/MainApp-dev.provisionprofile' - main app developer build provisioning profile;
* './extension/MainApp.provisionprofile' - extension app release build provisioning profile;
* './extension/MainApp-dev.provisionprofile' - extension app developer build provisioning profile;

### How to build
Open './CMakeLists.txt' find and completely fill out the next variables:
* GROUP_ID - is your Apple developer group id;
* MAIN_APP_ID - is your main application ID as you have done in the your Apple developer account;
* EXTENSION_ID - is your extension ID as you have done in the your Apple developer account;
* SIGN_PREFIX - is a ID prefix of MAIN_APP_ID and EXTENSION_ID;
* DEV_CERT_NAME - is a development certificate name that should be already instaled;
* REL_CERT_NAME - is a release certificate name that should be already instaled;

The example of coniguration:
```
set(GROUP_ID "A123XYZ09F")
set(MAIN_APP_ID "com.CompanyName.HeyApple")
set(EXTENSION_ID "com.CompanyName.HeyApple.Extension")
set(SIGN_PREFIX "com.CompanyName.")
set(DEV_CERT_NAME "FFFAA23497836BC9B0%A010367BABABCAFE00275")
set(REL_CERT_NAME "2A0778DFA9A78000C7B1237FC6B8B10A4455FF07")
```
NOTE: If you want to use only one signing type you can do not fill an other cert name variable.

When it is done create a build folder and run cmake from this folder like the next sample:
`cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/Users/John/intall -DUSE_APPLE_DEV_SIGN=ON ..`

If 'DUSE_APPLE_DEV_SIGN' is ON it means the application bundle will be signed with the help of developer certificate.
Otherwise it will be signed with the help of release certificate.

When cmake configuration stage has been finished without errors run `make && make install`. It creates a 'HeyApple.app' by the given CMAKE_INSTALL_PREFIX and signes it.

### Installation
This example doesn't provide any package building. For the testing you should copy installed bundle into '/Application' folder manually. Apple doesn't allow to use network extension from user defined folder. So it step is mandatory!

## Usage and debug
The example contains the controll application that is placed by '/Application/HeyApple/Contents/MacOS/HeyApple'. This is command line application. Allowed commands are - [install | uninstall | start | stop]. As you can understand these commands can install/uninstall/start/stop the extension. There is a few different installation terms regarding network extension. The first means bundle installation into '/Application' folder for whole bundle. Factually this is a single step for an ordinary application installation. But for the network extension Apple is required additional installation step. On this step an extension should be copied from an installed application bundle into '/Library/Systemextensions/<UUID>' folder. Where UUID is a system automaticaly generated unique ID. Essentialy there are two extension. The first is placed inside the bundle. The second inside the Mac system. And only the second instance can be run.

The extension doesn't provide any traffic filtering. It just logs every connection. These logs can be observed in temrminal with the help of:
`log stream --level info --process pid`
Where pid is an actual pid of the extension process. Be sure it has been started with the help of the main app.
Also can be informative an log output on the debug level. In the such case in contains a Mac network extension stuff messages. A sample of the debug log is:
```
2022-12-24 15:29:05.393829+0200 0x383e     Debug       0x0                  302    0    com.CompanyName.HeyApple.Extension: (NetworkExtension) [com.apple.networkextension:] Fetching appInfo from cache for pid: 847 uuid: 70C94704-6C40-35E5-A1A0-FF89862A2D41 bundle id: .com.apple.Safari
2022-12-24 15:29:05.393943+0200 0x383e     Debug       0x0                  302    0    com.CompanyName.HeyApple.Extension: (NetworkExtension) [com.apple.networkextension:] Handling new flow:
        identifier = F101E8A8-387E-42A1-B28B-AB392163664A
        hostname = cmake.org
        sourceAppIdentifier = .com.apple.Safari
        sourceAppVersion = 16.0
        sourceAppUniqueIdentifier = 20:{length = 20, bytes = 0xd43e30f896b843326e57247e752f9c5d2cc744e9}
        procPID = 847
        eprocPID = 847
        direction = outbound
        inBytes = 0
        outBytes = 0
        signature = 32:{length = 32, bytes = 0xc82c03ee 60232757 f9c93d16 1d914d60 ... dea450f5 f1c1c0f7 }
        localEndpoint = 192.168.50.138:53497
        remoteEndpoint = 66.194.253.25:443
        remoteHostname = cmake.org
        protocol = 6
        family = 2
        type = 1
        procUUID = 70C94704-6C40-35E5-A1A0-FF89862A2D41
        eprocUUID = 70C94704-6C40-35E5-A1A0-FF89862A2D41
2022-12-24 15:29:05.393994+0200 0x383e     Info        0x0                  302    0    com.CompanyName.HeyApple.Extension: [com.Okhokhlov.HeyApple:Default] PID=847; Path: /Library/Apple/System/Library/StagedFrameworks/Safari/SafariShared.framework/Versions/A/XPCServices/com.apple.Safari.SearchHelper.xpc/Contents/MacOS/com.apple.Safari.SearchHelper; TCP; port: 443;
```

The current extension list can be retrieived via command - `systemextensionctl list`.

NOTE: There are two wass how to uninstall an extension:
* Using 'uninstall' command of the main app;
* Delete an application bundle via Mac Finder. In this case it should show a prompt regarding an installed extension.
  All other cases can provide a situation when your system contains an extension but you can't control it anymore.
 And one more - after uninstall I recomend to reboot your Mac. It helps to cleanup internal Mac data and helps to avoid strange extension bugs.

## Usefull links
* [Apple official documentation](https://developer.apple.com/documentation/networkextension?language=objc);
* [SimpleFirewall - Apple example](https://developer.apple.com/documentation/networkextension/filtering_network_traffic);
* [A great article by Alexander Kotyk](https://www.apriorit.com/dev-blog/669-mac-system-extensions);
* [LuLu FireWall open-source firewall application](https://github.com/objective-see/LuLu);