#import "extensionmanager.h"

#import <Foundation/Foundation.h>
#import <SystemExtensions/SystemExtensions.h>
#import <NetworkExtension/NetworkExtension.h>

#include <iostream>
#include <stdexcept>

namespace {
bool loadPreferences(){
    __block BOOL wasError = NO;

    [NEFilterManager.sharedManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {

        if(nil != error)
        {
            std::cerr << "loadFromPreferencesWithCompletionHandler failed:" << [[error localizedDescription] UTF8String] << std::endl;
            wasError = YES;
        }

        CFRunLoopStop(CFRunLoopGetCurrent());
    }];

    CFRunLoopRun();

    return wasError == NO;
}

int savePreferences(){
    __block int errorCode = 0;

    { [NEFilterManager.sharedManager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            if(nil != error)
            {
                std::cerr << "saveToPreferencesWithCompletionHandler failed:" << [[error localizedDescription] UTF8String] << std::endl;
                errorCode = [error code];
            }

            CFRunLoopStop(CFRunLoopGetCurrent());

        }]; }

    CFRunLoopRun();

    return errorCode;
}

} // anonymous namespace


@implementation ExtensionManagerImpl

// Handle the result of the install, remove, and upgrade requests.
- (void)request:(OSSystemExtensionRequest *)request didFinishWithResult:(OSSystemExtensionRequestResult)result
{
    if (request != self.request) {
        return;
    }

    std::cerr << "SystemExtension request did finish with result:" << (long)result << std::endl;

    self.request = nil;
    self.callback(result ==  OSSystemExtensionRequestCompleted || result == OSSystemExtensionRequestWillCompleteAfterReboot);

    CFRunLoopStop(CFRunLoopGetCurrent());
}

// Handle failure of the install, remove, and upgrade requests.
- (void)request:(OSSystemExtensionRequest *)request didFailWithError:(NSError *)error
{
    if (request != self.request) {
        return;
    }

    std::cerr << "SystemExtension request did fail with error:" << error << [error localizedDescription] << std::endl;

    self.callback(false);
    self.request = nil;

    CFRunLoopStop(CFRunLoopGetCurrent());
}

// Handle a request to update the dext.
- (OSSystemExtensionReplacementAction)request:(OSSystemExtensionRequest OS_UNUSED *)request actionForReplacingExtension:(OSSystemExtensionProperties *)existing withExtension:(OSSystemExtensionProperties *)ext
{
    std::cerr << "Replace extension:" << existing.bundleShortVersion << "-->" << ext.bundleShortVersion << std::endl;

    if (self.m_force) {
        return OSSystemExtensionReplacementActionReplace;
    }
    return OSSystemExtensionReplacementActionCancel;
}

// Update the UI if the dext installation request requires user approval.
- (void)requestNeedsUserApproval:(OSSystemExtensionRequest *)request
{
    if (request != self.request) {
        return;
    }

    std::cerr << "Installation not finished. Need user approval" << std::endl;
}

// Use the SystemExtension framework to install the dext.
- (void)installExtension : (NSString*)bundle_id andCallback: (std::function<void(bool)>)cb  forceInstall: (bool)force {
    if (self.request) {
        return;
    }

    OSSystemExtensionRequest *request =
        [OSSystemExtensionRequest activationRequestForExtension:bundle_id
                                                          queue:dispatch_get_main_queue()];
    request.delegate = self;
    self.callback = cb;
    self.m_force = force;

    [[OSSystemExtensionManager sharedManager] submitRequest:request];
    self.request = request;

    CFRunLoopRun();
}

// Use the SystemExtension framework to remove the dext.
- (void)removeExtension : (NSString*)bundle_id andCallback: (std::function<void(bool)>) cb {
    if (self.request) {
        return;
    }

    OSSystemExtensionRequest *request =
        [OSSystemExtensionRequest deactivationRequestForExtension:bundle_id
                                                            queue:dispatch_get_main_queue()];
    request.delegate = self;
    self.callback = cb;

    [[OSSystemExtensionManager sharedManager] submitRequest:request];
    self.request = request;

    CFRunLoopRun();
}

- (bool)hasProgress {
    return self.request != nil;
}
@end


namespace {
NSString* toNSString(const std::string& str) {
  return [NSString stringWithUTF8String:str.c_str()];
}

}
ExtensionManager::ExtensionManager(const char* extension_id)
  : m_extensionID(extension_id)
{
    m_impl = [[ExtensionManagerImpl alloc] init];
}

ExtensionManager::~ExtensionManager() = default;

void ExtensionManager::install(bool force) {
    [m_impl installExtension:(toNSString(m_extensionID)) andCallback:[this](bool ok){
        m_result = ok;
    } forceInstall:force];

    if (!m_result) {
      throw std::runtime_error("Can't install");
    }
}

void ExtensionManager::uninstall(){
    [m_impl removeExtension:(toNSString(m_extensionID)) andCallback:[this](bool ok){
         m_result = ok;
    }];

    if (!m_result) {
      throw std::runtime_error("Can't uninstall");
    }
}

void ExtensionManager::start() {

    std::cerr << "Start activating SystemExtension" << std::endl;

    if (!loadPreferences()) {
         throw std::runtime_error("Can't load preferences");
    }

    int errCode = 0;
    int maxRepeatCount = 3;
    do {
        if(nil == NEFilterManager.sharedManager.providerConfiguration)
        {
            __block NEFilterProviderConfiguration* config = nil;
            config = [[NEFilterProviderConfiguration alloc] init];
            config.filterPackets = NO;
            config.filterSockets = YES;
            NEFilterManager.sharedManager.providerConfiguration = config;
        }

        NEFilterManager.sharedManager.enabled = YES;

        errCode = savePreferences();
    } while (errCode == 5 && maxRepeatCount-- != 0); // Repeat while user don't allow or maxRepeatCount is reached

    if (errCode != 0) {
        throw std::runtime_error("Can't enable");
    }

    std::cerr << "Activated" << std::endl;
}

void ExtensionManager::stop(){
    std::cerr << "Start de-activating SystemExtension" << std::endl;

    if (!loadPreferences()) {
        throw std::runtime_error("Can't load preferences");
    }

    NEFilterManager.sharedManager.enabled = NO;

    if (savePreferences() != 0) {
        throw std::runtime_error("Can't save preferences");
    }

    std::cerr << "De-Activated" << std::endl;
}
