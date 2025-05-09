#import <AppKit/AppKit.h>


@interface AppDelegate : NSObject <NSApplicationDelegate>
@end


@interface AppDelegate (Shade)

@property (strong, nonatomic) NSArray* shadeControllers;

@end
