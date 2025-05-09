#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShadeWindowController : NSWindowController

@property (weak, nonatomic) NSScreen* screen;
@property (assign, nonatomic) float shadeValue;

@end

NS_ASSUME_NONNULL_END
