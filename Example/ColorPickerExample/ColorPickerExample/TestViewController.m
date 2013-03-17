//
//  NEOViewController.m
//  ColorPickerExample
//
//  Created by Karthik Abram on 12/28/12.
//  Copyright (c) 2012 Neovera.
//

#import "TestViewController.h"
#import "NEOColorPickerViewController.h"

@interface TestViewController () <NEOColorPickerViewControllerDelegate>

@property (nonatomic, strong) UIColor *currentColor;

@end

@implementation TestViewController
{
    NEOColorPickerViewController* colorPickerController;
    UIPopoverController* popover;
}

- (id) init {
    if (self = [super init]) {
        self.currentColor = [UIColor blackColor];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)buttonPressPickColor:(id)sender {
    [self popupColorPicker];
}


- (void)colorPickerViewController:(NEOColorPickerBaseViewController *)controller didSelectColor:(UIColor *)color {
    self.currentColor = color;
    self.view.backgroundColor = color;
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)popupColorPicker
{
    [self dismissColorPickerController];
    colorPickerController = [[NEOColorPickerViewController alloc] init];
    colorPickerController.delegate = self;
    colorPickerController.selectedColor = self.currentColor;
    colorPickerController.dialogTitle = @"Example";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:colorPickerController];
        
        popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        [popover setDelegate:self];
        
        NSLog(@"_selectColorButton.frame x=%f, y=%f, w=%f", self.pickColorButton.frame.origin.x, self.self.pickColorButton.frame.origin.y, self.pickColorButton.frame.size.width);
        [popover presentPopoverFromRect:self.pickColorButton.frame
                                 inView:self.view
               permittedArrowDirections:UIPopoverArrowDirectionAny
                               animated:YES];
    } else {
        [self.navigationController pushViewController:colorPickerController animated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self dismissColorPickerController];
}

-(void)dismissColorPickerController
{
    if (colorPickerController==nil) {
        return;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [colorPickerController dismissModalViewControllerAnimated:YES];
        [colorPickerController.view removeFromSuperview];
        [popover dismissPopoverAnimated:YES];
        popover = nil;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController setNavigationBarHidden:YES];
    }
	colorPickerController = nil;
}

@end
