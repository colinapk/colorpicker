//
//  NEOViewController.h
//  ColorPickerExample
//
//  Created by Karthik Abram on 12/28/12.
//  Copyright (c) 2012 Neovera.
//

#import <UIKit/UIKit.h>

@interface TestViewController : UIViewController<UIPopoverControllerDelegate>

//- (IBAction)buttonPressPickColor:(id)sender;
//
///*
// * This button instance is needed for calculating popover position
// */
//@property (weak, nonatomic) IBOutlet UIButton *pickColorButton;
@property (weak, nonatomic) IBOutlet UIButton *pickColorButton;

- (IBAction)buttonPressPickColor:(id)sender;

@end
