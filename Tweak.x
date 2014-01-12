#import <AppSupport/CPDistributedMessagingCenter.h>

#define ROCKETBOOTSTRAP_LOAD_DYNAMIC
#import "rocketbootstrap.h"

%ctor {
    @autoreleasepool {
        NSBundle *mainBundle = NSBundle.mainBundle;
        if ([mainBundle.bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
            NSLog(@"daemontest: Unlocking service.");
            rocketbootstrap_unlock("net.joedj.daemontest");
        } else {
            NSString *executablePath = mainBundle.executablePath;
            if (executablePath && [executablePath rangeOfString:@"/Applications/"].location != NSNotFound) {
                NSLog(@"daemontest: Sending ping...");
                CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"net.joedj.daemontest"];
                rocketbootstrap_distributedmessagingcenter_apply(center);
                NSDictionary *response = [center sendMessageAndReceiveReplyName:@"ping" userInfo:nil];
                NSLog(@"daemontest: Ping response: %@", response);
            } else {
                NSLog(@"daemontest: What the hell am I doing here?");
            }
        }
    }
}
