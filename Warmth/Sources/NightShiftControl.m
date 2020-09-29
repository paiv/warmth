#import "AppConfig.h"
#import "NightShiftControl.h"
#import "v3math.h"


@interface NightShiftControl ()

@property (weak, nonatomic) IBOutlet NSView *knobView;
@property (assign, nonatomic) NSRect knobBounds;
@property (assign, nonatomic) float storeShiftValue;
@property (assign, nonatomic) float storeShadeValue;
@property (strong, nonatomic) NSTimer* reportTimer;
@property (strong, nonatomic) NSImage* backgroundImage;

@end


@implementation NightShiftControl

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    self.backgroundImage = [self renderBackgroundImageOfSize:frameRect.size padding:APP_KNOB_PADDING];
    
    NSImage* knobImage = [self knobImageOfSize:CGSizeMake(APP_KNOB_SIZE, APP_KNOB_SIZE)];
    NSImageView* knob = [NSImageView imageViewWithImage:knobImage];
    knob.imageAlignment = NSImageAlignCenter;
    knob.imageFrameStyle = NSImageFrameNone;
    knob.imageScaling = NSImageScaleNone;
    knob.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);
    [self addSubview:knob];
    self.knobView = knob;
    self.knobBounds = NSInsetRect(self.bounds, APP_KNOB_PADDING, APP_KNOB_PADDING);
    knob.frame = NSMakeRect(NSMinX(self.knobBounds) - knobImage.size.width / 2, NSMinY(self.knobBounds) - knobImage.size.height / 2, knobImage.size.width, knobImage.size.height);

    NSTrackingArea* trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:(NSTrackingMouseMoved | NSTrackingActiveInActiveApp | NSTrackingActiveWhenFirstResponder) owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
    
    return self;
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];

    [self sendAction:@selector(viewWillAppear) to:self.target];
}

- (NSImage*)renderBackgroundImageOfSize:(CGSize)size padding:(CGFloat)padding {
    size_t width = size.width;
    size_t height = size.height;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = width * 4;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);

    {
        size_t width = size.width - 2 * padding;
        size_t height = size.height - 2 * padding;
        size_t bitsPerComponent = 8;
        size_t bitsPerPixel = 32;
        size_t bytesPerRow = width * 4;

        CGBitmapInfo bitmapInfo = (CGBitmapInfo) (kCGImageAlphaNoneSkipFirst);
        
        size_t dataSize = bytesPerRow * height;
        uint32_t* data = calloc(dataSize, 1);
        
        v3 shade = {0, 0, 0};
        v3 tint = {0.1, 0, 1};
        for (size_t j = 0; j < height; ++j) {
            float y = (float)j / (height - 1);
            for (size_t i = 0; i < width; ++i) {
                float z = (float)i / (width - 1);
#if !APP_REVERSE_SHADE_AXIS
                z = 1 - z;
#endif
                z = (1 - APP_MAX_SHADE + z * APP_MAX_SHADE);
                shade.z = z;
                tint.y = 0.5 * y;
                v3 pixel = hsv_shade(&tint, &shade);
                
                v3 rgb = hsv_to_rgb(&pixel);
                uint32_t r = (uint8_t)(rgb.x * 255);
                uint32_t g = (uint8_t)(rgb.y * 255);
                uint32_t b = (uint8_t)(rgb.z * 255);
                data[j*width + i] = (b << 24) | (g << 16) | (r << 8);
            }
        }
        
        CGDataProviderRef provider = CGDataProviderCreateWithData(nil, data, dataSize, nil);
        
        CGImageRef gradientImage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpace, bitmapInfo, provider, nil, NO, kCGRenderingIntentDefault);
        
        CGRect rect = CGRectMake(padding, padding, width, height);
        CGContextDrawImage(context, rect, gradientImage);
        
        CGImageRelease(gradientImage);
        CGDataProviderRelease(provider);
        free(data);
    }
    
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    NSImage* image = [[NSImage alloc] initWithCGImage:cgimage size:size];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

- (void)drawRect:(NSRect)dirtyRect {
    [self.backgroundImage drawInRect:dirtyRect fromRect:dirtyRect operation:NSCompositingOperationCopy fraction:1];
}

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];

    NSPoint pos = [self convertPoint:event.locationInWindow fromView:nil];
    [self positionKnobAtPoint:pos];
    [self updateValuesFromKnobPositionFlush:NO];
}

- (void)mouseDragged:(NSEvent *)event {
    [super mouseDragged:event];
    
    NSPoint pos = [self convertPoint:event.locationInWindow fromView:nil];
    [self positionKnobAtPoint:pos];
    [self updateValuesFromKnobPositionFlush:NO];
}

- (void)mouseUp:(NSEvent *)event {
    [super mouseUp:event];
    
    NSPoint pos = [self convertPoint:event.locationInWindow fromView:nil];
    [self positionKnobAtPoint:pos];
    [self updateValuesFromKnobPositionFlush:YES];
}

- (float)shiftValue {
    return self.storeShiftValue;
}

- (void)setShiftValue:(float)shiftValue {
    self.storeShiftValue = shiftValue;
    [self updateKnobPosition];
}

- (float)shadeValue {
    return self.storeShadeValue;
}

- (void)setShadeValue:(float)shadeValue {
    self.storeShadeValue = shadeValue;
    [self updateKnobPosition];
}

- (NSImage*)knobImageOfSize:(CGSize)size {
    NSImage* image = [[NSImage alloc] initWithSize:size];
    [image lockFocus];

    NSBezierPath* path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, 0, size.width, size.height)];
    [NSColor.whiteColor setFill];
    [path fill];

    [image unlockFocus];
    return image;
}

- (void)updateKnobPosition {
    float x = self.storeShadeValue;
    float y = self.storeShiftValue;
    if (!isfinite(x)) {
        x = 0;
    }
    if (!isfinite(y)) {
        y = 0;
    }
#if APP_REVERSE_SHADE_AXIS
    x = 1 - x;
#endif
    NSRect knobFrame = self.knobView.frame;
    knobFrame.origin.x = (NSMinX(self.knobBounds) + x * NSWidth(self.knobBounds)) - NSWidth(knobFrame) / 2;
    knobFrame.origin.y = (NSMinY(self.knobBounds) + (1 - y) * NSHeight(self.knobBounds)) - NSHeight(knobFrame) / 2;
    self.knobView.frame = knobFrame;
}

- (void)positionKnobAtPoint:(NSPoint)point {
    NSRect knobFrame = self.knobView.frame;
    knobFrame.origin.x = MAX(NSMinX(self.knobBounds), MIN(NSMaxX(self.knobBounds), point.x)) - NSWidth(knobFrame) / 2;
    knobFrame.origin.y = MAX(NSMinY(self.knobBounds), MIN(NSMaxY(self.knobBounds), point.y)) - NSHeight(knobFrame) / 2;
    self.knobView.frame = knobFrame;
}

- (void)setReportTimer:(NSTimer *)reportTimer {
    [_reportTimer invalidate];
    _reportTimer = reportTimer;
}

- (void)updateValuesFromKnobPositionFlush:(BOOL)flush {
    NSRect knobFrame = self.knobView.frame;
    CGSize canvasSize = self.knobBounds.size;
    CGPoint canvasOffset = self.knobBounds.origin;
    
    CGFloat shadeOffset = NSMidX(knobFrame) - canvasOffset.x;
#if APP_REVERSE_SHADE_AXIS
    shadeOffset = canvasSize.width - shadeOffset;
#endif
    
    self.storeShiftValue = (canvasSize.height - (NSMidY(knobFrame) - canvasOffset.y)) / canvasSize.height;
    self.storeShadeValue = shadeOffset / canvasSize.width;

    if (flush) {
        self.reportTimer = nil;
        [self reportValueChange];
    }
    else if (!self.reportTimer) {
        __weak typeof(self) weakSelf = self;
        self.reportTimer = [NSTimer timerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.reportTimer = nil;
            [strongSelf reportValueChange];
        }];
        [NSRunLoop.currentRunLoop addTimer:self.reportTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)reportValueChange {
    [self sendAction:self.action to:self.target];
}

@end
