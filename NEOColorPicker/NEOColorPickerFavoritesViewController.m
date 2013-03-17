//
//  NEOColorPickerFavoritesViewController.m
//
//  Created by Karthik Abram on 10/24/12.
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

#import "NEOColorPickerFavoritesViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorPreviewView.h"

@interface NEOColorPickerFavoritesViewController () <UIScrollViewDelegate>
@end

@implementation NEOColorPickerFavoritesViewController
{
    NSMutableArray* colorArray;
    int colorPerPage;
    
    ColorPreviewView* selectedColorPreviewView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *pattern = [UIColor colorWithPatternImage:[UIImage imageNamed:@"colorPicker.bundle/color-picker-checkered"]];

    selectedColorPreviewView = [[ColorPreviewView alloc] initWithFrame:SELECTED_COLOR_BOX_FRAME
                                                                 color:self.selectedColor
                                                               pattern:pattern
                                                                shadow:YES];
    [self.view addSubview:selectedColorPreviewView];

    [self setupButton:self.clearAllButton withBundleImageIdx:BUNDLE_IMAGE_CLEANER];

    colorPerPage = 24;
    colorArray = [NSMutableArray array];
    NSOrderedSet *colors = [NEOColorPickerFavoritesManager instance].favoriteColors;
    int count = [colors count];
    for (int i = 0; i < count; i++) {
        ColorPreviewView* preview = [[ColorPreviewView alloc] initWithFrame:CGRectZero
                                                                      color:[colors objectAtIndex:i]
                                                                    pattern:pattern
                                                                     shadow:YES];
        [self.scrollView addSubview:preview];
        [colorArray addObject:preview];
    }

    self.scrollView.delegate = self;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorGridTapped:)];
    [self.scrollView addGestureRecognizer:recognizer];
    [self setAdjustPanelPositionWithOrientation:[self isLandscape]];
}


- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setClearAllButton:nil];
    [super viewDidUnload];
}

- (void) colorGridTapped:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.scrollView];
    int screenWidth = [self getScreenWidth];
    int page = point.x / screenWidth;
    int delta = (int)point.x % screenWidth;
    int colorPerRow = [self isLandscape] ? 6 : 4;
   
    int row = (int)((point.y - 8) / 48);
    int column = (int)((delta - 8) / 78);
    int index = 24 * page + row * colorPerRow + column;
    if (index < [[NEOColorPickerFavoritesManager instance].favoriteColors count]) {
        self.selectedColor = [[NEOColorPickerFavoritesManager instance].favoriteColors objectAtIndex:index];
        [selectedColorPreviewView setDisplayColor:self.selectedColor];
    }
}


- (IBAction)pageValueChange:(id)sender
{
    int screenWidth = [self getScreenWidth];
    [self.scrollView scrollRectToVisible:CGRectMake(self.pageControl.currentPage * screenWidth, 0,
                                                    self.scrollView.bounds.size.width,
                                                    self.scrollView.bounds.size.height)
                                animated:YES];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int screenWidth = [self getScreenWidth];
    self.pageControl.currentPage = scrollView.contentOffset.x / screenWidth;
}

-(void)saveButtonPressed;
{
    [super saveButtonPressed];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setAdjustPanelPositionWithOrientation:(BOOL)landscapeMode
{
    int screenWidth = [self getScreenWidth];
    int colorPerRow = [self isLandscape] ? 6 : 4;
    int i = 0;
    
    for(ColorPreviewView* colorView in colorArray) {
        int page = i / colorPerPage;
        int x = i % colorPerPage;
        int column = x % colorPerRow;
        int row = x / colorPerRow;
        CGRect frame = CGRectMake(page * screenWidth + 8 + (column * 78), 8 + row * 48, 70, 40);
        [colorView setFrame:frame];
        i++;
    }
    
    int count = [colorArray count];
    int pages = (count - 1) / colorPerPage + 1;
    self.pageControl.numberOfPages = pages;
    self.scrollView.contentSize = CGSizeMake(pages * screenWidth,
                                             self.scrollView.bounds.size.height);
}

- (IBAction)toucheDownClearButton:(id)sender
{
    if ([colorArray count]>0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete all favorite colors"
                                                        message:@"Are you sure to delete them all?"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:@"Cancel", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) //OK buttons
    {
        for(ColorPreviewView* colorView in colorArray) {
            [colorView removeFromSuperview];
        }        
        [colorArray removeAllObjects];

        [[NEOColorPickerFavoritesManager instance] clearAllFavoriteColors];

        [self setAdjustPanelPositionWithOrientation:[self isLandscape]];
    }
}

@end
