//
//  ColorPreviewView.m
//  CompositePhoto
//
//  Created by Nguyen Pham on 20/01/13.
//  Copyright (c) 2013 Nguyen Pham. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ColorPreviewView.h"

#define CORNER_RADIUS       6.0

@implementation ColorPreviewView
{
    UIView* colorView;
    BOOL shadow;
}

- (id)initWithFrame:(CGRect)frame color:(UIColor*)color shadow:(BOOL)shadow_
{
    UIColor *pattern = [UIColor colorWithPatternImage:[UIImage imageNamed:@"colorPicker.bundle/color-picker-checkered"]];
    return [self initWithFrame:frame color:color pattern:pattern shadow:shadow_];
}

- (id)initWithFrame:(CGRect)frame color:(UIColor*)color pattern:(UIColor*)pattern shadow:(BOOL)shadow_
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizesSubviews:YES];
        
        frame.origin = CGPointZero;
        if (pattern) {
            UIImageView *checkeredView = [[UIImageView alloc] initWithFrame:frame];
            checkeredView.layer.cornerRadius = CORNER_RADIUS;
            checkeredView.layer.masksToBounds = YES;
            checkeredView.backgroundColor = pattern;
            [checkeredView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            [self addSubview:checkeredView];
        }
        
        colorView = [[UIView alloc] initWithFrame:frame];
        colorView.layer.cornerRadius = CORNER_RADIUS;
        colorView.backgroundColor = color;
        [colorView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self addSubview:colorView];
        
        shadow = shadow_;
        if (shadow) {
            [self setupShadow];
        }
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (shadow) {
        [self setupShadow];
    }
}

- (void) setupShadow
{
    CGRect frame = self.frame;
    frame.origin = CGPointZero;
    colorView.layer.shadowColor = [UIColor blackColor].CGColor;
    colorView.layer.shadowOpacity = 0.8;
    colorView.layer.shadowOffset = CGSizeMake(0, 2);
    colorView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:CORNER_RADIUS].CGPath;
}

-(void)setDisplayColor:(UIColor*)color
{
    colorView.backgroundColor = color;
}

-(UIColor*) getDisplayColor;
{
    return colorView.backgroundColor;
}

@end
