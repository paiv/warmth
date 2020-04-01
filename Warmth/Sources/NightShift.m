#import "CoreBrightness.h"
#import "NightShift.h"
#import <math.h>


@interface NightShift ()

@property (strong, nonatomic) CBClient* provider;

@end


@implementation NightShift

+ (instancetype)client {
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[NightShift alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.provider = [[CBClient alloc] init];
    }
    return self;
}

- (BOOL)isSupported {
    return [CBClient supportsBlueLightReduction];
}

- (BOOL)isEnabled {
    CBBlueLightClient* blueLight = self.provider.blueLightClient;
    
    Status status;
    if (![blueLight getBlueLightStatus:&status]) {
        return NO;
    }
    return status.active;
}

- (float)strength {
    CBBlueLightClient* blueLight = self.provider.blueLightClient;
    
    float value = 0;
    if (![blueLight getStrength:&value]) {
        return NAN;
    }
    return value;
}

- (void)setStrength:(float)strength {
    CBBlueLightClient* blueLight = self.provider.blueLightClient;
    
    [blueLight setStrength:strength commit:NO];
}

@end
