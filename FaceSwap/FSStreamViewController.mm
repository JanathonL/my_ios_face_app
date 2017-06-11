//
//  FSStreamViewController.m
//  FaceSwap
//
//  Created by Alexander Karlsson on 2017-01-22.
//  Copyright © 2017 Alexander Karlsson. All rights reserved.
//

#import "FSStreamViewController.h"
#import "opencv2/photo.hpp"

using namespace cv;

@interface FSStreamViewController ()

@end

@implementation FSStreamViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    streamStarted = NO;
    frontCamera = YES;
    
    videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    videoCamera.delegate = self;
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    //videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    videoCamera.defaultFPS = 30;
    
    self.imUtils = [[FSImageUtils alloc] init];
    
    // Set the navigationbar to transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    // Create image library stuff
    self.imgPicker = [[UIImagePickerController alloc] init];
    self.imgPicker.delegate = self;
    
    // Disable trashButton and hide it
    [self.trashButton setEnabled:NO];
    [self.trashButton setTintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
    
    // Disable the camera button and hide it
    [self.cameraButton setEnabled:NO];
    [self.cameraButton setTintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
    
    libImageIsBackground = NO;
    libImg = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self inActiveLogic];
}


/** 
 Makes sure the video stream is off when user switches application or "mode".
 */
-(void)viewWillDisappear:(BOOL)animated
{
    [self inActiveLogic];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    [self inActiveLogic];

}

- (void) applicationWillResign
{
    [self inActiveLogic];
}


-(void)inActiveLogic
{
    if (streamStarted)
        [videoCamera stop];
    
    streamStarted = NO;
    [self.streamButton setImage:[UIImage imageNamed:@"ic_videocam_36pt"]];
    [super viewWillDisappear:YES];
    
    // Disable the camera button and hide it
    [self.cameraButton setEnabled:NO];
    [self.cameraButton setTintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


/** 
 Image buffer. OpenCV image format.
 */
- (void)processImage:(Mat&)image;
{
    // Do some OpenCV stuff with the image
    Mat image_copy;
    cvtColor(image, image_copy, CV_BGRA2BGR);
    
    if (libImg != nil) {
        
        [self.imUtils liveSwapFacesLibMode:image_copy];

    } else
        [self.imUtils liveSwapFaces:image_copy];
    
    image = image_copy;
    img = image;
}


/** 
 Opens the photo library. The selected image will be used for replacing the live face.
 */
- (IBAction)libraryButtonPressed:(id)sender
{
    [self presentViewController:self.imgPicker animated:YES completion:nil];
}


/** 
 Opens/closes the image stream.
 */
- (IBAction)streamButtonPressed:(id)sender
{
    streamStarted = !streamStarted;
    
    if (streamStarted) {
        [videoCamera start];
        [self.streamButton setImage:[UIImage imageNamed:@"ic_videocam_off_36pt"]];
    
        // Disable the library button and hide it
        [self.libraryButton setEnabled:NO];
        [self.libraryButton setTintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
        
        // Enable and show the camera button
        [self.cameraButton setEnabled:YES];
        [self.cameraButton setTintColor:[UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:1.0]];

        
        if (libImg != nil) {
            // Disable trashButton
            [self.trashButton setEnabled:NO];
            [self.trashButton setTintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
        }
    } else {
        [videoCamera stop];
        [self.streamButton setImage:[UIImage imageNamed:@"ic_videocam_36pt"]];
        
        // Enable the library button and show it
        [self.libraryButton setEnabled:YES];
        [self.libraryButton setTintColor:[UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:1.0]];
        
        // Disable the camera button and hide it
        [self.cameraButton setEnabled:NO];
        [self.cameraButton setTintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
        
        if (libImg != nil) {
            self.imageView.image = libImg;
            // Enable trashButton
            [self.trashButton setEnabled:YES];
            [self.trashButton setTintColor:[UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:1.0]];
        }
    }
}


/**
 Changes front/back camera.
 */
- (IBAction)segmentChanged:(id)sender
{
    if ([sender selectedSegmentIndex] == 0)
        videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    else
        videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    
    if (streamStarted) {
        [videoCamera stop];
        frontCamera = !frontCamera;
        [videoCamera start];
    }

}


/**
 Removes the selcted image. With this button the user has the option to go back to ordinary live mode.
 */
- (IBAction)trashButtonPressed:(id)sender
{
    if (libImg != nil) {
        self.imageView.image = [UIImage imageNamed:@"faceswap_logo"];
        libImg = nil;
        
        // Disable trashButton
        [self.trashButton setEnabled:NO];
        [self.trashButton setTintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
    }
}


-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


/**
 Saves an image.
 */
- (IBAction)cameraButtonPressed:(id)sender
{
    // Convert opencv mat ot UIImage and save.
    UIImage *im = [self.imUtils UIImageFromCVMat:img];
    
    UIImage *im1 = [self imageWithImage:im scaledToSize:CGSizeMake(288, 380)];
    
    UIImageWriteToSavedPhotosAlbum(im1, nil, nil, nil);
    
    // Change color of camera button (to indicate action!).
    [self.cameraButton setTintColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.5]];
    
    // Puase so the camera button is gray for a short while
    [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(timerFunc) userInfo:nil repeats:NO];
}


/**
 Pauses for a short period of time. Used for the camerabutton so it can be set to a different color
 for a while.
 */
-(void)timerFunc
{
    // Reset color of camera button.
    [self.cameraButton setTintColor:[UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:1.0]];
}


/**
 Decides what will happen when an image was chosen in the library.
 */
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // Set or replace first image
    libImg = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];

    // Check number of faces, must be 1
    if ([self.imUtils nbrOfFaces:libImg] == 1) {
        self.imageView.image = libImg;
        
        // Is ok to prepare for live swap library mode
        [self.imUtils prepareForLiveSwapLibMode:libImg];
        
        // Enable trashButton
        [self.trashButton setEnabled:YES];
        [self.trashButton setTintColor:[UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:1.0]];
    
    } else {
        // Make sure libImg is nil and show message
        libImg = nil;
        self.imageView.image = [UIImage imageNamed:@"faceswap_logo"];
        [self topText:@"No face found" undertext:@"Photo must contain exactly one (detectable) face" buttonText:@"OK"];
        
        // Disable trashButton
        [self.trashButton setEnabled:NO];
        [self.trashButton setTintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
    }
}


/** 
 Shows a "toast" and an OK button.
 */
-(void)topText:(NSString*)text1 undertext:(NSString*)text2 buttonText:(NSString*)text3
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:text1 message:text2 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:text3 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Insert an action here, if needed.
    }];
    
    [alert addAction:firstAction];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
