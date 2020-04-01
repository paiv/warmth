#import "AppConfig.h"
#import "AppSettings.h"
#import "NightShiftController.h"
#import "NightShiftControl.h"
#import "NightShift.h"
#import "ShadeWindowController.h"


@interface NightShiftController ()

@property (weak, nonatomic) ShadeWindowController* shadeController;
@property (weak, nonatomic) NightShift* provider;
@property (weak, nonatomic) NightShiftControl* control;

@end


@implementation NightShiftController

- (void)loadView {
    NSRect frame = NSMakeRect(0, 0, APP_WINDOW_SIZE, APP_WINDOW_SIZE);
    NightShiftControl* control = [[NightShiftControl alloc] initWithFrame:frame];
    
    self.control = control;
    self.view = control;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.control setTarget:self];
    [self.control setAction:@selector(handleNightShiftControlValueChange:)];
    
    self.provider = NightShift.client;
    self.provider.strength = AppSettings.userSettings.shiftValue;
}

- (void)viewWillAppear {
    self.shadeController = [NSApp.delegate performSelector:@selector(shadeController)];
    self.control.shiftValue = self.provider.strength;
    self.control.shadeValue = self.shadeController.shadeValue;
}

- (IBAction)handleNightShiftControlValueChange:(id)sender {
    self.shadeController.shadeValue = self.control.shadeValue;
    self.provider.strength = self.control.shiftValue;
    
    AppSettings.userSettings.shadeValue = self.shadeController.shadeValue;
    AppSettings.userSettings.shiftValue = self.control.shiftValue;
}

@end
