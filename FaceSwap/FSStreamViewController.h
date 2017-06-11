//
//  FSStreamViewController.h
//  FaceSwap
//
//  Created by Alexander Karlsson on 2017-01-22.
//  Copyright © 2017 Alexander Karlsson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/videoio/cap_ios.h>
#import <Foundation/Foundation.h>
#import <FSImageUtils.h>

@interface FSStreamViewController : UIViewController<CvVideoCameraDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    CvVideoCamera *videoCamera;
    BOOL streamStarted, frontCamera, libImageIsBackground;
    UIImage *libImg;
    cv::Mat img;
}


- (IBAction)libraryButtonPressed:(id)sender;
- (IBAction)streamButtonPressed:(id)sender;
- (IBAction)segmentChanged:(id)sender;
- (IBAction)trashButtonPressed:(id)sender;
- (IBAction)cameraButtonPressed:(id)sender;


@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, readwrite) FSImageUtils *imUtils;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *streamButton;
@property (strong, nonatomic) UIImagePickerController *imgPicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *libraryButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;

@end
