//
//  NEOColorPickerHueGridViewController.m
//
//  Created by Karthik Abram on 10/23/12.
//  Copyright (c) 2012 Neovera Inc.
//
//  Modified by Tony Nguyen Pham (softgaroo.com) Jan 2013

/*
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

#import <QuartzCore/QuartzCore.h>

#import "NEOColorPickerHueGridViewController.h"
#import "ColorPreviewView.h"


@interface NEOColorPickerHueGridViewController () <UIScrollViewDelegate>

@end

#define COLOR_LAYER_GAP 6
@implementation NEOColorPickerHueGridViewController
{
    ColorPreviewView* selectedColorPreviewView;
    NSMutableArray* colorPreviewArray;
    int colorCount, displayPage;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)createColors
{
    colorPreviewArray = [NSMutableArray array];
    for (int i = 0 ; i < 12; i++) {
        CGFloat hue = i * 30 / 360.0;
        colorCount = NEOColorPicker4InchDisplay() ? 32 : 24;
        for (int x = 0; x < colorCount; x++) {
            int row = x / 4;
            int column = x % 4;
            
            CGFloat saturation = column * 0.25 + 0.25;
            CGFloat luminosity = 1.0 - row * 0.12;
            UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:luminosity alpha:1.0];
            [self createColorPreviewWithColor:color];
        }
    }
}

-(void)createColorPreviewWithColor:(UIColor*)color
{
    ColorPreviewView* colorPreviewView = [[ColorPreviewView alloc] initWithFrame:CGRectZero
                                                                           color:color
                                                                         pattern:nil
                                                                          shadow:YES];
    
    [self.scrollView addSubview:colorPreviewView];
    [colorPreviewArray addObject:colorPreviewView];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    selectedColorPreviewView = [[ColorPreviewView alloc] initWithFrame:SELECTED_COLOR_BOX_FRAME
                                                                 color:self.selectedColor
                                                                shadow:YES];
    [self.view addSubview:selectedColorPreviewView];
   
    [self createColors];
    
    self.colorBar.image = [UIImage imageNamed:@"colorPicker.bundle/color-bar"];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorGridTapped:)];
    [self.scrollView addGestureRecognizer:recognizer];
    
    self.colorBar.userInteractionEnabled = YES;
    UITapGestureRecognizer *barRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorBarTapped:)];
    [self.colorBar addGestureRecognizer:barRecognizer];
    
    displayPage = 0;
    [self setAdjustPanelPositionWithOrientation:[self isLandscape]];
}

-(int)colorLayerWidth
{
    return [self isLandscape] ? (NEOColorPicker4InchDisplay() ? 64 : 70) : 70;
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setColorBar:nil];
    [super viewDidUnload];
}

- (void) colorGridTapped:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.scrollView];
    int screenWidth = [self getScreenWidth];
    int page = point.x / screenWidth;
    int delta = (int)point.x % screenWidth;
    
    int width = [self colorLayerWidth];
    int row = (int)((point.y - 8) / 48);
    int column = (int)((delta - 8) / (width + COLOR_LAYER_GAP));
    int index;
    if ([self isLandscape]) {
        index = colorCount * page + row + column * 4;
    } else {
        index = colorCount * page + row * 4 + column;
    }
    self.selectedColor = [[colorPreviewArray objectAtIndex:index] getDisplayColor];
    [selectedColorPreviewView setDisplayColor:self.selectedColor];
}

- (void) colorBarTapped:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.colorBar];
    int btnWidth = self.colorBar.bounds.size.width / 12;
    int page = point.x / btnWidth;
    [self setWorkingPage:page];
}

-(void)setWorkingPage:(int)page
{
    displayPage = page;
    int screenWidth = [self getScreenWidth];
    [self.scrollView scrollRectToVisible:CGRectMake(page*screenWidth, 0,
                                                    self.scrollView.frame.size.width,
                                                    self.scrollView.frame.size.height) animated:YES];
}

-(void)saveButtonPressed;
{
    [super saveButtonPressed];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setAdjustPanelPositionWithOrientation:(BOOL)landscapeMode
{
    int screenWidth = [self getScreenWidth];
    int width = [self colorLayerWidth];
   
    int count = [colorPreviewArray count];
    for (int idx = 0; idx < count; idx++) {
        ColorPreviewView *colorPreview = [colorPreviewArray objectAtIndex:idx];
        int page = idx / colorCount;
        int x = idx % colorCount;
        int column, row;
        if (landscapeMode) {
            column = x / 4;
            row = x % 4;
        } else {
            column = x % 4;
            row = x / 4;
        }
        CGRect frame = CGRectMake(page * screenWidth + 8 + column * (width+COLOR_LAYER_GAP), 8 + row * 48, width, 40);
        [colorPreview setFrame: frame];
    }
    
    self.scrollView.contentSize = CGSizeMake(screenWidth * 12, self.scrollView.bounds.size.height);// 296);
    [self setWorkingPage:displayPage];
}

@end
