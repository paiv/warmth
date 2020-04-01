#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppSettings : NSObject

+ (instancetype)userSettings;

@property (assign, nonatomic) float shiftValue;
@property (assign, nonatomic) float shadeValue;

@end

NS_ASSUME_NONNULL_END
