#import <AppSupport/CPDistributedMessagingCenter.h>

#define ROCKETBOOTSTRAP_LOAD_DYNAMIC
#import "rocketbootstrap.h"

#define EXIT_TIMEOUT_SECONDS 10

@interface JJDaemonTest: NSObject
@end

@implementation JJDaemonTest {
    NSTimer *_timeout;
}

- (id)init {
    if ((self = [super init])) {
        [self _resetTimeout];
    }
    return self;
}

- (void)_setupSignalHandlers {
    dispatch_source_t sigtermSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGTERM, 0, dispatch_get_main_queue());
    if (sigtermSource) {
        dispatch_source_set_event_handler(sigtermSource, ^{
            [self _terminate];
        });
        dispatch_resume(sigtermSource);
        struct sigaction sigtermAction;
        memset(&sigtermAction, 0, sizeof(struct sigaction));
        sigtermAction.sa_handler = SIG_IGN;
        sigaction(SIGTERM, &sigtermAction, NULL);
    } else {
        NSLog(@"Unable to create SIGTERM event source.");
    }
}

- (void)_setupServer {
    CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"net.joedj.daemontest"];
    rocketbootstrap_distributedmessagingcenter_apply(center);
    [center registerForMessageName:@"ping" target:self selector:@selector(ping)];
    [center runServerOnCurrentThread];
}

- (void)start {
    [self _setupSignalHandlers];
    [self _setupServer];
}

- (NSDictionary *)ping {
    [self _resetTimeout];
    return @{ @"response" : @"pong" };
}

- (void)_resetTimeout {
    [_timeout invalidate];
    _timeout = [NSTimer scheduledTimerWithTimeInterval:EXIT_TIMEOUT_SECONDS target:self selector:@selector(_exit) userInfo:nil repeats:NO];
}

- (void)_terminate {
    NSLog(@"Goodbye, cruel world.");
    [self _exit];
}

- (void)_exit {
    exit(EXIT_SUCCESS);
}

@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        @autoreleasepool {
            [[[JJDaemonTest alloc] init] start];
        }
        [NSRunLoop.currentRunLoop run];
        return EXIT_FAILURE;
    }
}
