//
//  BlindsView.h
//  Blinds
//
//  Created by Damien Quartz on 9/9/17.
//  Copyright © 2017 Damien Quartz.
//

#import <ScreenSaver/ScreenSaver.h>

struct Blind
{
    float x, f, o;
};

@interface BlindsView : ScreenSaverView
{
    // array of Blind structs.
    // dynamically allocated based on screensize
    Blind* blinds;
    int    blindsCount;
    float  lineWeight;
    int    frameCount;
}
@end
