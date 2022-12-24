#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>
#import <os/log.h>
#import <os/signpost.h>

os_log_t logHandle = nil;

int main(int /*argc*/, char** /*argv*/)
{
   @autoreleasepool {
        logHandle = os_log_create("com.Okhokhlov.HeyApple", "Default");

        os_log_info(logHandle, "Started: %{public}@ (pid: %d / uid: %d)", NSProcessInfo.processInfo.arguments.firstObject, getpid(), getuid());

        //start sysext
        // Apple notes, "call [this] as early as possible"
        [NEProvider startSystemExtensionMode];
    }
    
    dispatch_main();

    return 0;
}
