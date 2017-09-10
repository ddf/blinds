//
//  BlindsView.m
//  Blinds
//
//  Created by Damien Quartz on 9/9/17.
//  Copyright © 2017 Damien Quartz.
//

#import "BlindsView.h"

// these are expressed as a percentage of the pixel-width of the screen
// based on fixed pixel values arrived at through experimentation on a 1280x800 screen
const float   minSpacing = 0.01171875f;
const float   maxSpacing = 0.0234375f;
const float   wiggle     = 0.00234375;

@implementation BlindsView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/60.0];
        
        blindsCount = int(1.0f / minSpacing);
        blinds = new Blind[blindsCount];
        
        const float width = frame.size.width;
        float px = 0;
        for(int i = 0; i < blindsCount; ++i)
        {
            blinds[i].x = px + SSRandomFloatBetween(width*minSpacing, width*maxSpacing);
            px = blinds[i].x;
            blinds[i].f = SSRandomFloatBetween(2.f, 8.f);
        }
        
        lineWeight = width*wiggle;
        frameCount = 0;
    }
    return self;
}

- (void)dealloc
{
    delete[] blinds;
}

- (BOOL)isOpaque
{
    // this keeps Cocoa from unneccessarily redrawing our superview
    return YES;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    
    [NSBezierPath setDefaultLineWidth:lineWeight];
    // the path we use to render all the boxes
    NSBezierPath* path = [NSBezierPath bezierPath];
    float ptx = 0;
    float pbx = 0;
    const float dt = [self animationTimeInterval];
    const float ty = rect.size.height;
    const float by = 0;
    for(int i = 0; i < blindsCount; ++i)
    {
        float ctx = blinds[i].x;
        if ( ctx >= rect.size.width ) break;
        float cbx = blinds[i].x+sinf(blinds[i].o)*lineWeight;
        // scale the distance based on ratio between our test width and the actual width.
        // this should give us about the same range of grey values regardless of resolution.
        float d = (cbx - pbx)*(1280.0f/rect.size.width);
        float h = d*d*0.08f;
        
        //fill(h);
        //quad(ptx, 0, ctx, 0, cbx, height, pbx, height);
        [[NSColor colorWithWhite:h/255.0f alpha:1] setFill];
        [path removeAllPoints];
        [path moveToPoint:NSMakePoint(ptx, ty)];
        [path lineToPoint:NSMakePoint(ctx, ty)];
        [path lineToPoint:NSMakePoint(cbx, by)];
        [path lineToPoint:NSMakePoint(pbx, by)];
        [path closePath];
        [path fill];
        
        //stroke(225);
        [[NSColor colorWithWhite:225.0f/255.0f alpha:1] setStroke];
        //line(ctx, 0, cbx, height);
        // offset by 0.5 because coordinates are between pixels:
        // http://stackoverflow.com/questions/8016618/how-to-get-a-1-pixel-line-with-nsbezierpath
        [NSBezierPath strokeLineFromPoint:NSMakePoint(ctx+0.5f, ty) toPoint:NSMakePoint(cbx+0.5f, by)];
        
        ptx = ctx;
        pbx = cbx;
        float fmod = sinf((frameCount+i)*0.14f);
        blinds[i].o += (blinds[i].f+fmod)*dt;
    }
    
    float d = rect.size.width - pbx;
    float h = (d*d*0.08f);
    // fill(h);
    // quad(ptx, 0, width, 0, width, height, pbx, height);
    [[NSColor colorWithWhite:h/255.0f alpha:1] setFill];
    [path removeAllPoints];
    [path moveToPoint:NSMakePoint(ptx, ty)];
    [path lineToPoint:NSMakePoint(rect.size.width, ty)];
    [path lineToPoint:NSMakePoint(rect.size.width, by)];
    [path lineToPoint:NSMakePoint(pbx, by)];
    [path closePath];
    [path fill];
    
    ++frameCount;
}

- (void)animateOneFrame
{
    [self setNeedsDisplay:YES];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
