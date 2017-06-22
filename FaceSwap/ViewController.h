//
//  ViewController.h
//  FaceAR_SDK_IOS_OpenFace_RunFull
//
//  Created by Keegan Ren on 7/5/16.
//  Copyright © 2016 Keegan Ren. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <opencv2/videoio/cap_ios.h>
#import "RNGridMenu.h"
typedef NS_OPTIONS(NSUInteger, imgClss){
    NONE=0,
    GLASS=1<<0,
    EAR=1<<1,
    FACE=1<<2,
    CIGARRETE=1<<3,
    BEARD=1<<4,
    
    NECKLACE=1<<5,
    LEFTEYE=1<<6,
    RIGHTEYE=1<<7,
    BOW=1<<8,
    HAT=1<<9,
    MOUTH=1<<10,
    BIGMOUTH=1<<11,
    SHARK=1<<12
};

@interface ViewController : UIViewController<CvVideoCameraDelegate, RNGridMenuDelegate>

//- (IBAction)startButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *start;
@property (weak, nonatomic) IBOutlet UIButton *stop;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (weak, nonatomic) IBOutlet UIImageView *LeftEye;
@property (weak, nonatomic) IBOutlet UIImageView *Cigarette;
@property (weak, nonatomic) IBOutlet UIImageView *Bow;
@property (weak, nonatomic) IBOutlet UIImageView *Mouth;
@property (weak, nonatomic) IBOutlet UIImageView *Beard;
@property (weak, nonatomic) IBOutlet UIImageView *Face;
@property (weak, nonatomic) IBOutlet UIImageView *Ear;
@property (weak, nonatomic) IBOutlet UIImageView *Glass;
@property (weak, nonatomic) IBOutlet UIImageView *RightEye;
@property (weak, nonatomic) IBOutlet UIImageView *Hat;
@property (weak, nonatomic) IBOutlet UIImageView *NeckLace;
//@property (nonatomic, strong) imgClss *imageClass;//图片类别，在imgClss中取
@property (weak, nonatomic) IBOutlet UIImageView *BigMouth;
@property (weak, nonatomic) IBOutlet UIImageView *Shark;
@property (weak, nonatomic) IBOutlet UIScrollView *ScrollView;
//-(void)photoTapped:(UIGestureRecognizer *)gestureRecognizer;
@end
