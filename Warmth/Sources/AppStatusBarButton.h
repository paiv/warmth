#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppStatusBarButton : NSObject

- (instancetype)initWithTitle:(NSString*)title;

- (void)present;

@end

NS_ASSUME_NONNULL_END
