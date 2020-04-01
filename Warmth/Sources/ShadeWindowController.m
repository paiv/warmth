#import "AppConfig.h"
#import "ShadeWindowController.h"


@implementation ShadeWindowController

- (instancetype)init {
    self = [super initWithWindow:nil];
    if (self) {
        [self loadWindow];
        [self windowDidLoad];
    }
    return self;
}

- (void)loadWindow {
    NSRect windowRect = NSScreen.mainScreen.frame;
    NSWindow* window = [[NSWindow alloc] initWithContentRect:windowRect styleMask:(NSWindowStyleMaskFullScreen | NSWindowStyleMaskFullSizeContentView) backing:NSBackingStoreBuffered defer:NO];
    window.titlebarAppearsTransparent = YES;
    window.titleVisibility = NSWindowTitleHidden;
    window.hasShadow = NO;
    window.collectionBehavior = (NSWindowCollectionBehaviorStationary | NSWindowCollectionBehaviorIgnoresCycle);
    window.canHide = NO;
    window.hidesOnDeactivate = NO;
    [window setLevel:CGShieldingWindowLevel()];

    window.ignoresMouseEvents = YES;
    [window standardWindowButton:NSWindowCloseButton].hidden = YES;
    [window standardWindowButton:NSWindowMiniaturizeButton].hidden = YES;
    [window standardWindowButton:NSWindowZoomButton].hidden = YES;

    window.backgroundColor = NSColor.blackColor;
    window.alphaValue = 0;

    self.window = window;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleScreenParametersChange:) name:NSApplicationDidChangeScreenParametersNotification object:nil];

    [self updateShade];
}

- (void)handleScreenParametersChange:(NSNotification*)notification {
    NSRect windowRect = NSScreen.mainScreen.frame;
    [self.window setFrame:windowRect display:NO];
}

- (void)setShadeValue:(float)shadeValue {
    _shadeValue = shadeValue;
    [self updateShade];
}

- (void)updateShade {
    if (self.isWindowLoaded) {
        self.window.alphaValue = APP_MAX_SHADE * self.shadeValue;
    }
}

@end
