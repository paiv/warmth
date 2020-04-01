#import <AppKit/AppKit.h>
#import "AppStatusBarButton.h"
#import "NightShiftController.h"


@interface AppStatusBarButton ()

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSStatusItem* item;
@property (strong, nonatomic) NightShiftController* nightShiftControl;

@end


@implementation AppStatusBarButton

- (instancetype)initWithTitle:(NSString*)title {
    self = [super init];
    if (self) {
        self.title = title;
        self.nightShiftControl = [[NightShiftController alloc] init];
    }
    return self;
}

- (void)present {
    NSStatusItem* item = [NSStatusBar.systemStatusBar statusItemWithLength:NSSquareStatusItemLength];
    item.button.title = self.title;
    
    if (@available(macOS 10.12, *)) {
        item.behavior = NSStatusItemBehaviorTerminationOnRemoval;
        item.visible = YES;
    }
    
    self.item = item;
    
    NSMenu* menu = [[NSMenu alloc] init];
    item.menu = menu;
    
    NSMenuItem* control = [[NSMenuItem alloc] init];
    control.view = self.nightShiftControl.view;
    
    [menu addItem:control];
}

@end
