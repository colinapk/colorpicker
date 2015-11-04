//
//  NEOColorPickerBaseViewController.m
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

#import "NEOColorPickerBaseViewController.h"
#import <QuartzCore/QuartzCore.h>


@implementation NEOColorPickerFavoritesManager {
    NSMutableOrderedSet *_favorites;
}

+ (NEOColorPickerFavoritesManager *) instance {
    static dispatch_once_t _singletonPredicate;
    static NEOColorPickerFavoritesManager *_singleton = nil;
    
    dispatch_once(&_singletonPredicate, ^{
        _singleton = [[super allocWithZone:nil] init];
    });
    
    return _singleton;
}


- (id)init {
    if (self = [super init]) {

        NSFileManager *fs = [NSFileManager defaultManager];
        NSString *filename = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"neoFavoriteColors.data"];
        if ([fs isReadableFileAtPath:filename]) {
            _favorites = [[NSMutableOrderedSet alloc] initWithOrderedSet:[NSKeyedUnarchiver unarchiveObjectWithFile:filename]];
        } else {
            _favorites = [[NSMutableOrderedSet alloc] init];            
        }
    }
    
    return self;
}


+ (id) allocWithZone:(NSZone *)zone {
    return [self instance];
}


- (void)addFavorite:(UIColor *)color {
    [_favorites addObject:color];
    [self saveDataToFile];
}

-(void)saveDataToFile
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_favorites];
    NSString *filename = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"neoFavoriteColors.data"];
    [data writeToFile:filename atomically:YES];
}


- (NSOrderedSet *)favoriteColors {
    return _favorites;
}

-(void)clearAllFavoriteColors
{
    [_favorites removeAllObjects];
    [self saveDataToFile];
}

@end


@interface NEOColorPickerBaseViewController ()

@end

@implementation NEOColorPickerBaseViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.topItem.title = self.dialogTitle;
    
    UIBarButtonItem *saveButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                  target:self
                                                  action:@selector(saveButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];

}

-(void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [self setAdjustPanelPositionWithOrientation:[self isLandscape]];
}

-(BOOL)isLandscape
{
    UIInterfaceOrientation orientation = self.navigationController.interfaceOrientation;
    return UIInterfaceOrientationIsLandscape(orientation);
}

-(int)getScreenWidth
{
    int screenWidth = [UIScreen mainScreen].bounds.size.width;
    return screenWidth;
}


-(void)setAdjustPanelPositionWithOrientation:(BOOL)landscapeMode
{
}

-(void)saveButtonPressed
{
    if (self.delegate) {
        [self.delegate colorPickerViewController:self didSelectColor:self.selectedColor];
    }
}

- (void) setupShadow:(CALayer *)layer {
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.8;
    layer.shadowOffset = CGSizeMake(0, 2);
    CGRect rect = layer.frame;
    rect.origin = CGPointZero;
    layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:layer.cornerRadius].CGPath;
}

-(void)setupButton:(UIButton*)button withBundleImageIdx:(int)bundleImageIdx
{
    NSString* imageName;
    
    switch (bundleImageIdx) {
        case BUNDLE_IMAGE_HUE:
            imageName = @"colorPicker.bundle/hue_selector";
            break;
        case BUNDLE_IMAGE_FAVORITE_ADD:
            imageName = @"colorPicker.bundle/picker-favorites-add";
            break;
        case BUNDLE_IMAGE_FAVORITE_PICKER:
            imageName = @"colorPicker.bundle/picker-favorites";
            break;
        case BUNDLE_IMAGE_GRID:
            imageName = @"colorPicker.bundle/picker-grid";
            break;
        case BUNDLE_IMAGE_CLEANER:
            imageName = @"colorPicker.bundle/cleaner";
            break;
        case BUNDLE_IMAGE_MAX:
            imageName = @"colorPicker.bundle/color-picker-max";
            break;
        case BUNDLE_IMAGE_MIN:
            imageName = @"colorPicker.bundle/color-picker-min";
            break;
            
        default:
            break;
    }

    [button setBackgroundColor:[UIColor clearColor]];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

@end
