#import "AppSettings.h"


@implementation AppSettings

+ (instancetype)userSettings {
    static dispatch_once_t onceToken;
    static AppSettings* instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[AppSettings alloc] init];
    });
    return instance;
}

- (float)shiftValue {
    return [NSUserDefaults.standardUserDefaults floatForKey:@"shift_value"];
}

- (void)setShiftValue:(float)shiftValue {
    [NSUserDefaults.standardUserDefaults setFloat:shiftValue forKey:@"shift_value"];
}

- (float)shadeValue {
    return [NSUserDefaults.standardUserDefaults floatForKey:@"shade_value"];
}

- (void)setShadeValue:(float)shadeValue {
    [NSUserDefaults.standardUserDefaults setFloat:shadeValue forKey:@"shade_value"];
}

@end
