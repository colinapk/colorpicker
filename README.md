Neovera Color Picker
====================

Background
----------

A color picker is the most conspicuously absent component in the collection of built-in controls provided by Apple in the iOS library. There are many open-source components that have sprung up to fill the gap. This component was created for the [ToonThat][https://itunes.apple.com/us/app/toonthat/id584478951?ls=1&mt=8] application as we didn't find the level of flexibility and feature-set in the others.

Improvements by Tony Pham (softgaroo.com)
----------
* Support landscape mode for iPhone
* Support iPad
* Animation when saving Favorite colors
* Use NavigationController to push views
* Clean and improve the code for being easier readable and maintenance

The new improvements are used already in my freeware [Composite photo app][https://itunes.apple.com/us/app/composite-photo/id590158659?ls=1&mt=8]. To see them in actions, look at videos:

* http://www.youtube.com/watch?v=a7g_rYtjtL0
* http://www.youtube.com/watch?v=4XjQuMLG3Qw

Screenshots
-------
![Simple selector](https://github.com/nguyenpham/colorpicker/blob/master/etc/image1.png?raw=true)
![Hue Grid selector](https://github.com/nguyenpham/colorpicker/blob/master/etc/image2.png?raw=true)
![HSL selector](https://github.com/nguyenpham/colorpicker/blob/master/etc/image3.png?raw=true)
![Landscape](https://github.com/nguyenpham/colorpicker/blob/master/etc/image4.png?raw=true)
![Landscape](https://github.com/nguyenpham/colorpicker/blob/master/etc/image5.png?raw=true)
![iPad](https://github.com/nguyenpham/colorpicker/blob/master/etc/image6.png?raw=true)


Features
-------
* Shows a simple color pallete (simplifies the simple case).
* iPhone 5 ready - color pallete expands to fill larger screen.
* Hue grid - more variations of primary color. Color line in the bottom can be tapped to select color or grid can be swiped left and right.
* HSL selector - for fine grain color selection, presents Hue circle and separate saturation and luminosity controls.
* Alpha selector
* Allows users to save their favorite colors. Favorites are stored in a file in the Documents directory.
* Simple delegate model.
* You can specify current color selection and title for header.


Usage
-----
Copy the files within the Source folder into your project. The colorPicker.bundle file contains the graphical resources.

In your view controller where you want to invoke the color picker, first implement the methods of the delegate:

    @implementation MyViewController <NEOColorPickerViewControllerDelegate>
    
Assuming you want to launch the view controller in response to a button being clicked, setup and launch an instance of NEOColorPickerViewController:

    NEOColorPickerViewController *controller = [[NEOColorPickerViewController alloc] init];
    controller.delegate = self;
    controller.selectedColor = <some initial color reference>;
    controller.dialogTitle = @"My dialog title";
    
    [self presentViewController:controller animated:YES completion:nil];
    
Finally handle the color picker delegate callback when the color is selected. You can also implement an optional callback that is called when the color picker is dismissed:

    - (void) colorPickerViewController:(NEOColorPickerBaseViewController *)controller didSelectColor:(UIColor *)color {
        // Do something with the color.    
        self.view.backgroundColor = color;
        [controller dismissViewControllerAnimated:YES completion:nil];
    }

License
-------
[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)
