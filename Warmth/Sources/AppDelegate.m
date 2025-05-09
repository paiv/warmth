#import "AppConfig.h"
#import "AppDelegate.h"
#import "AppSettings.h"
#import "AppStatusBarButton.h"
#import "ShadeWindowController.h"


@interface AppDelegate ()

@property (weak, nonatomic) IBOutlet NSWindow* window;
@property (strong, nonatomic) AppStatusBarButton* statusBarButton;
@property (strong, nonatomic) NSArray<ShadeWindowController*>* shadeControllers;
@property (strong, nonatomic) id<NSObject> screensObserver;

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification* )aNotification {
    self.statusBarButton = [[AppStatusBarButton alloc] initWithTitle:APP_STATUS_BAR_ICON];
    [self.statusBarButton present];

    [self refreshShadesForScreens:NSScreen.screens];

    __weak typeof(self) weakSelf = self;
    self.screensObserver = [NSNotificationCenter.defaultCenter
                            addObserverForName:NSApplicationDidChangeScreenParametersNotification
                            object:nil
                            queue:nil
                            usingBlock:^(NSNotification* _Nonnull notification) {
        [weakSelf refreshShadesForScreens:NSScreen.screens];
    }];
}

- (void)refreshShadesForScreens:(NSArray<NSScreen*>*)screens {
    for (ShadeWindowController* controller in self.shadeControllers) {
        [controller close];
    }
    self.shadeControllers = nil;

    NSMutableArray<ShadeWindowController*>* controllers = [NSMutableArray arrayWithCapacity:screens.count];
    for (NSScreen* screen in screens) {
        ShadeWindowController* shadeController = [[ShadeWindowController alloc] init];
        shadeController.screen = screen;
        shadeController.shadeValue = AppSettings.userSettings.shadeValue;
        [shadeController showWindow:nil];
        [controllers addObject:shadeController];
    }
    self.shadeControllers = controllers;
}

@end
