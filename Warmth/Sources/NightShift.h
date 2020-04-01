#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NightShift : NSObject

+ (instancetype)client;

@property (assign, nonatomic, readonly, getter=isSupported) BOOL supported;
@property (assign, nonatomic, readonly, getter=isEnabled) BOOL enabled;
@property (assign, nonatomic) float strength;

@end

NS_ASSUME_NONNULL_END
