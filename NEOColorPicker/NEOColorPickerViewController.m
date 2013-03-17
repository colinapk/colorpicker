//
//  NEOColorPickerViewController.m
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


#import "NEOColorPickerViewController.h"
#import "NEOColorPickerHSLViewController.h"
#import "NEOColorPickerHueGridViewController.h"
#import "NEOColorPickerFavoritesViewController.h"
#import "UIColor+NEOColor.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorPreviewView.h"


@interface NEOColorPickerViewController () <NEOColorPickerViewControllerDelegate> {
}

@end

@implementation NEOColorPickerViewController
{
    NSMutableArray* colorPreviewArray;
    ColorPreviewView* selectedColorPreviewView, *animatedPreviewView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)createColors
{
    colorPreviewArray = [NSMutableArray array];
    
    int colorCount = NEOColorPicker4InchDisplay() ? 24 : 20;
    for (int i = 0; i < colorCount; i++) {
        UIColor *color = [UIColor colorWithHue:i / (float)colorCount
                                    saturation:1.0 brightness:1.0 alpha:1.0];
        [self createColorPreviewWithColor:color];
    }
    
    colorCount = 8;
    for (int i = 0; i < colorCount; i++) {
        UIColor *color = [UIColor colorWithWhite:i/(float)(colorCount - 1) alpha:1.0];
        [self createColorPreviewWithColor:color];
    }
}

-(void)createColorPreviewWithColor:(UIColor*)color
{
    ColorPreviewView* colorPreviewView = [[ColorPreviewView alloc] initWithFrame:CGRectZero
                                                                           color:color
                                                                         pattern:nil
                                                                          shadow:YES];
    
    [self.simpleColorGrid addSubview:colorPreviewView];
    [colorPreviewArray addObject:colorPreviewView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.selectedColor) {
        self.selectedColor = [UIColor blackColor];
    }
    
    [self setupButton:self.buttonHue withBundleImageIdx:BUNDLE_IMAGE_HUE];
    [self setupButton:self.buttonAddFavorite withBundleImageIdx:BUNDLE_IMAGE_FAVORITE_ADD];
    [self setupButton:self.buttonFavorites withBundleImageIdx:BUNDLE_IMAGE_FAVORITE_PICKER];
    [self setupButton:self.buttonHueGrid withBundleImageIdx:BUNDLE_IMAGE_GRID];
    
    /*
     * Selected color box
     */
    selectedColorPreviewView = [self createSelectedColorPreviewView];
    [self createColors];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorGridTapped:)];
    [self.simpleColorGrid addGestureRecognizer:recognizer];
    
    [self setAdjustPanelPositionWithOrientation:[self isLandscape]];
}

-(ColorPreviewView*) createSelectedColorPreviewView
{
    ColorPreviewView* view = [[ColorPreviewView alloc] initWithFrame:SELECTED_COLOR_BOX_FRAME
                                                                 color:self.selectedColor
                                                                shadow:YES];
    [self.view addSubview:view];
    return view;
}

-(int)colorLayerWidth
{
    return [self isLandscape] ? (NEOColorPicker4InchDisplay() ? 66 : 64) : 75;
}

-(void)setAdjustPanelPositionWithOrientation:(BOOL)landscapeMode
{
    int width = [self colorLayerWidth];
    int count = [colorPreviewArray count];
    for (int i = 0; i < count; i++) {
        ColorPreviewView* colorPreviewView = [colorPreviewArray objectAtIndex:i];
        
        int column, row;
        if (landscapeMode) {
            column = i / 4;
            row = i % 4;
        } else {
            column = i % 4;
            row = i / 4;
        }
        colorPreviewView.frame = CGRectMake(8 + column * (width+3), 8 + row * 48, width, 40);
    }
}

- (void)viewDidUnload {
    [self setNavigationBar:nil];
    [self setSimpleColorGrid:nil];
    [self setButtonHue:nil];
    [self setButtonAddFavorite:nil];
    [self setButtonFavorites:nil];
    [self setButtonHueGrid:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateSelectedColor];
}


- (void) updateSelectedColor {
    [selectedColorPreviewView setDisplayColor:self.selectedColor];
}


- (void) colorGridTapped:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.simpleColorGrid];
    int width = [self colorLayerWidth];
    int row = (int)((point.y - 8) / 48);
    int column = (int)((point.x - 8) / width);
    int index = [self isLandscape] ? (row + column * 4) : (row * 4 + column);
    self.selectedColor = [[colorPreviewArray objectAtIndex:index] getDisplayColor];
    [self updateSelectedColor];
}


- (IBAction)buttonPressCancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(colorPickerViewControllerDidCancel:)]) {
        [self.delegate colorPickerViewControllerDidCancel:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)buttonPressHue:(id)sender {
    NEOColorPickerHSLViewController *controller = [[NEOColorPickerHSLViewController alloc] init];
    controller.delegate = self;
    controller.dialogTitle = self.dialogTitle;
    controller.disallowOpacitySelection = self.disallowOpacitySelection;
    controller.selectedColor = self.selectedColor;
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)colorPickerViewController:(NEOColorPickerBaseViewController *)controller didSelectColor:(UIColor *)color {
    if (self.disallowOpacitySelection && [color neoAlpha] != 1.0) {
        self.selectedColor = [color neoColorWithAlpha:1.0];
    } else {
        self.selectedColor = color;
    }
    [self updateSelectedColor];
    [controller dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)buttonPressHueGrid:(id)sender {
    NEOColorPickerHueGridViewController *controller = [[NEOColorPickerHueGridViewController alloc] init];
    controller.delegate = self;
    controller.dialogTitle = self.dialogTitle;
    controller.selectedColor = self.selectedColor;

    [self.navigationController pushViewController:controller animated:YES];
}


- (IBAction)buttonPressAddFavorite:(id)sender {
    [[NEOColorPickerFavoritesManager instance] addFavorite:self.selectedColor];
    
    animatedPreviewView = [self createSelectedColorPreviewView];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         animatedPreviewView.frame = _buttonFavorites.frame;
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                         [animatedPreviewView removeFromSuperview];
                         animatedPreviewView = nil;
                     }];
}


- (IBAction)buttonPressFavorites:(id)sender {
    NEOColorPickerFavoritesViewController *controller = [[NEOColorPickerFavoritesViewController alloc] init];
    controller.delegate = self;
    controller.selectedColor = self.selectedColor;
    controller.dialogTitle = @"Favorites";

    [self.navigationController pushViewController:controller animated:YES];
}

@end
