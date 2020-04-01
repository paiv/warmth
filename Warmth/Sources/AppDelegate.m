#import "AppConfig.h"
#import "AppDelegate.h"
#import "AppSettings.h"
#import "AppStatusBarButton.h"
#import "ShadeWindowController.h"


@interface AppDelegate ()

@property (weak, nonatomic) IBOutlet NSWindow* window;
@property (strong, nonatomic) AppStatusBarButton* statusBarButton;
@property (strong, nonatomic) ShadeWindowController* shadeController;

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification* )aNotification {
    self.shadeController = [[ShadeWindowController alloc] init];
    self.shadeController.shadeValue = AppSettings.userSettings.shadeValue;

    self.statusBarButton = [[AppStatusBarButton alloc] initWithTitle:APP_STATUS_BAR_ICON];
    [self.statusBarButton present];

    [self.shadeController showWindow:nil];
}

@end
