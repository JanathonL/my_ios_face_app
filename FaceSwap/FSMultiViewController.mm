//
//  FSMultiViewController.m
//  FaceSwap
//
//  Created by Alexander Karlsson on 2017-01-07.
//  Copyright © 2017 Alexander Karlsson. All rights reserved.
//

#import "FSMultiViewController.h"
#import "FSResultViewController.h"

@interface FSMultiViewController ()

@end

@implementation FSMultiViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Create and add tap recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer];
    
    // Create stuff for camera
    self.imgPickerCam = [[UIImagePickerController alloc] init];
    self.imgPickerCam.delegate = self;
    self.imgPickerCam.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    camInputUsed = NO;
    
    // Create image library stuff
    self.imgPicker = [[UIImagePickerController alloc] init];
    self.imgPicker.delegate = self;
    [self.imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    // center the activity indicator
    self.activityIndicator.center = self.view.center;
    
    // Create imageutils for swapping faces
    self.imUtils = [[FSImageUtils alloc] init];
    
    // Set the navigationbar to transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    Img = nil;
    
    // Code for orientation change
    // http://stackoverflow.com/questions/9122149/detecting-ios-uidevice-orientation
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    [self swapButtonLogic];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 Detects orientation change.
 Updates constraints for indicator.
 */
- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            self.activityIndicator.center = self.view.center;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            self.activityIndicator.center = self.view.center;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            self.activityIndicator.center = self.view.center;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            self.activityIndicator.center = self.view.center;
            break;
            
        default:
            break;
    };
}


/** 
 Opens the photo library.
 */
-(void)openPhotoLibrary
{
    [self presentViewController:self.imgPicker animated:YES completion:nil];
}


/** 
 Listener for opening the photo library.
 */
- (IBAction)albumButtonPressed:(id)sender
{
    [self openPhotoLibrary];
}


/**
 Listener for opening the photo library.
 */
- (IBAction)singleTap:(UITapGestureRecognizer *)recognizer
{
    [self openPhotoLibrary];
}


/** 
 Opens the camera.
 */
- (IBAction)cameraButtonPressed:(id)sender
{
    camInputUsed = YES;
    [self presentViewController:self.imgPickerCam animated:YES completion:NULL];
}


/**
 Calles the face swapping code if we have new faces to swap. If the faces are the same there will not be a new swap, just a reuse of the old swapped image.
 */
- (IBAction)swapPressed:(id)sender
{
    BOOL flag = YES;
    FSSwapStatus_t status = FS_STATUS_OK;
    
    if (swapImage == nil) {
        // Needs to do this if swapImage is nil
        if (Img != nil) {
        
            // Start activity indicator
            [NSThread detachNewThreadSelector:@selector(threadStartAnimating) toTarget:self withObject:nil];
            
            // Get face swap imaage
            swapImage = [self.imUtils swapFacesMulti:Img :status];
            
            [self.activityIndicator stopAnimating];
            
            if (status != FS_STATUS_OK) swapImage = nil;
        }
    }
    
    // Check returned status
    switch (status) {
        case FS_STATUS_OK:
            NSLog(@"Face swap ok");
            flag = YES;
            break;
            
        case FS_STATUS_NO_FACE_FOUND:
            flag = NO;
            NSLog(@"Fo face found");
            [self topText:@"Face swap failed" undertext:@"Face missing in at least one photo.\nFor best results use upright faces." buttonText:@"OK"];
            break;
            
        case FS_STATUS_IMAGE_TOO_SMALL:
            NSLog(@"Face too small");
            flag = NO;
            [self topText:@"Face swap failed" undertext:@"Selected image was too small." buttonText:@"OK"];
            break;
            
        case FS_STATUS_SINGLE_FACE_ERROR:
            NSLog(@"Only one face found");
            flag = NO;
            [self topText:@"Face swap failed" undertext:@"Only one face was found" buttonText:@"OK"];
            break;
            
        default:
            flag = NO;
            break;
    }
    
    
    // If swap was already done it's ok to start here.
    // If swap is ok send to next view controller
    if (flag) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        FSResultViewController *gvc = [storyboard instantiateViewControllerWithIdentifier:@"ResultView"];
        [gvc initialiseWithImage:swapImage];
        gvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:gvc animated:YES];
    }
}


/** 
 Starts rotating the spinner.
 */
- (void) threadStartAnimating
{
    [self.activityIndicator startAnimating];
}


/**
 Decides what will happen when an image was chosen in the library.
 */
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // Set or replace first image
    Img = info[UIImagePickerControllerOriginalImage];
    self.imgView.image = Img;
    
    // This will reset the swap, and a new swap will be made.
    swapImage = nil;
    
    camInputUsed = NO;

    [self swapButtonLogic];
    [self dismissViewControllerAnimated:YES completion:nil];
}


/**
 Enables/Disables and shows/hides the swap button according to the current state.
 */
-(void)swapButtonLogic
{
    if (Img != nil) {
        // Both image are OK and the swap button can be shown and enabled.
        [self.swapButton setEnabled:YES];
        [self.swapButton setTintColor:[UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:1.0]];
    } else {
        // Button will not be shown and enabled.
        [self.swapButton setEnabled:NO];
        [self.swapButton setTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
    }
}


/** 
 Alerts the user if something went wrong.
 */
-(void)topText:(NSString*)text1 undertext:(NSString*)text2 buttonText:(NSString*)text3
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:text1 message:text2 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:text3 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        
        // Insert an action here, if needed.
        
    }];
    
    [alert addAction:firstAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    [self swapButtonLogic];
}


@end
