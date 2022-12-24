#import <NetworkExtension/NetworkExtension.h>
#import <bsm/libbsm.h>
#import <libproc.h>
#import <os/log.h>
#import <os/signpost.h>

extern os_log_t logHandle;

@interface FilterDataProvider : NEFilterDataProvider
@end

@implementation FilterDataProvider

-(id)init
{
    self = [super init];
    return self;
}

-(void)startFilterWithCompletionHandler:(void (^)(NSError *error))completionHandler {
    os_log_info(logHandle, "method '%{public}s' invoked", __PRETTY_FUNCTION__);
    completionHandler(nil);
    return;
}

-(void)stopFilterWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler {
    os_log_info(logHandle, "method '%s' invoked with %ld", __PRETTY_FUNCTION__, (long)reason);
    completionHandler();
    return;
}

-(NEFilterNewFlowVerdict *)handleNewFlow:(NEFilterFlow *)flow {
    NEFilterSocketFlow* socketFlow = (NEFilterSocketFlow*)flow;
    NWHostEndpoint* remoteEndpoint = (NWHostEndpoint*)socketFlow.remoteEndpoint;

    audit_token_t* token = (audit_token_t*)flow.sourceAppAuditToken.bytes;
    pid_t pid = audit_token_to_pid(*token);

    char pathbuf[PROC_PIDPATHINFO_MAXSIZE];
    int ret = proc_pidpath(pid, pathbuf, sizeof(pathbuf));
    if ( ret <= 0 ) {
        os_log_error(logHandle, "proc_pidpath failed PID=%{public}d", pid);
    } else {
        os_log_info(logHandle, "PID=%{public}d; Path: %{public}s; %{public}s; port: %{public}s;",
                    pid, pathbuf,
                    socketFlow.socketType == SOCK_DGRAM? "UDP" : "TCP",
                    [remoteEndpoint.port UTF8String]);
    }

    return [NEFilterNewFlowVerdict allowVerdict];
}

@end

