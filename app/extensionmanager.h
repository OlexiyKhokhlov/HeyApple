#pragma once

#ifdef __OBJC__

// Objective-C part

#include <functional>
#import <SystemExtensions/SystemExtensions.h>

@interface ExtensionManagerImpl : NSObject<OSSystemExtensionRequestDelegate>
- (void)installExtension : (NSString*)bundle_id andCallback: (std::function<void(bool)>)cb forceInstall: (bool)force;
- (void)removeExtension : (NSString*)bundle_id andCallback: (std::function<void(bool)>)cb;
- (bool)hasProgress;
@property (strong) OSSystemExtensionRequest *request;
@property std::function<void(bool)> callback;
@property bool m_force;
@end

typedef ExtensionManagerImpl* ExtensionManagerImplPtr;

#else

// C++ part

#include <string>
#include <objc/objc.h>
typedef id ExtensionManagerImplPtr;

#endif

// Common part

#include <string>
class ExtensionManager
{
public:
    ExtensionManager(const char* extension_id);
    ~ExtensionManager();

    void install(bool force = false);
    void uninstall();
    void start();
    void stop();

private:
    ExtensionManagerImplPtr m_impl;
    std::string m_extensionID;
    bool m_result = false;
};
