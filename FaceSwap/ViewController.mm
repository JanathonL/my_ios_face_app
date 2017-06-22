//
//  ViewController.m
//  FaceAR_SDK_IOS_OpenFace_RunFull
//
//  Created by Keegan Ren on 7/5/16.
//  Copyright © 2016 Keegan Ren. All rights reserved.
//

#import "ViewController.h"

///// opencv
#import <opencv2/opencv.hpp>
///// C++
#include <iostream>
///// user
#include "FaceARDetectIOS.h"
//
#import "ContextMenuCell.h"
#import "YALContextMenuTableView.h"
#import "YALNavigationBar.h"

static NSString *const menuCellIdentifier = @"rotationCell";
//int choice=0;
imgClss imageClass=NONE;
bool first;
//static imgClss imageClass;//图片类别，在imgClss中取
//typedef NS_OPTIONS(NSUInteger, imgClss){
//    NONE=0,
//    GLASS=1<<0,
//    EAR=1<<1,
//    FACE=1<<2,
//    CIGARRETE=1<<3,
//    BEARD=1<<4,
//    
//    NECKLACE=1<<5,
//    LEFTEYE=1<<6,
//    RIGHTEYE=1<<7,
//    BOW=1<<8,
//    HAT=1<<9,
//    MOUTH=1<<10,
//};

@interface ViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
YALContextMenuTableViewDelegate
>

@property (nonatomic, strong) YALContextMenuTableView* contextMenuTableView;

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *menuIcons;

@end

@implementation ViewController {
    FaceARDetectIOS *facear;
    int frame_count;
    cv::Mat_<double> res;
    int rows;//the rows of res
    int i;//assign which point to use
    int x,y;//get the x and y of the point
    bool start;//相机是否开启
    //imgClss imageClass;//图片类别，在imgClss中取
    //extern int mychoice=0;
}
//MARK:图片按钮事件
-(void)glass1Tapped
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        imageClass^=GLASS;
        _Glass.image=[UIImage imageNamed:@"glass1"];
    }];
//    imageClass^=GLASS;
//    _Glass.image=[UIImage imageNamed:@"glass1"];
}
-(void)glass2Tapped
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        imageClass^=GLASS;
        _Glass.image=[UIImage imageNamed:@"glass2"];
    }];
//    imageClass^=GLASS;
//    _Glass.image=[UIImage imageNamed:@"glass2"];
}
-(void)beard1Tapped
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        imageClass^=BEARD;
        _Beard.image=[UIImage imageNamed:@"beard1"];
    }];
//    imageClass^=BEARD;
//    _Beard.image=[UIImage imageNamed:@"beard1"];
}
-(void)beard2Tapped
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        imageClass^=BEARD;
        _Beard.image=[UIImage imageNamed:@"beard2"];
    }];
//    imageClass^=BEARD;
//    _Beard.image=[UIImage imageNamed:@"beard2"];
}
-(void)face1Tapped
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        imageClass^=FACE;
        _Face.image=[UIImage imageNamed:@"face1"];
    }];
//    imageClass^=FACE;
//    _Face.image=[UIImage imageNamed:@"face1"];
}
-(void)mouth1Tapped
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        imageClass^=MOUTH;
        _Mouth.image=[UIImage imageNamed:@"mouth1"];
    }];
//    imageClass^=MOUTH;
//    _Mouth.image=[UIImage imageNamed:@"mouth1"];
}
-(void)left_eye2Tapped
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        imageClass^=LEFTEYE;
        _LeftEye.image=[UIImage imageNamed:@"left_eye2"];
    }];
//    imageClass^=LEFTEYE;
//    _LeftEye.image=[UIImage imageNamed:@"left_eye2"];
}
-(void)right_eye1Tapped
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        imageClass^=RIGHTEYE;
        _RightEye.image=[UIImage imageNamed:@"right_eye1"];
    }];
//    imageClass^=RIGHTEYE;
//    _RightEye.image=[UIImage imageNamed:@"right_eye1"];
}
-(void)ear1Tapped
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        imageClass^=EAR;
        _Ear.image=[UIImage imageNamed:@"ear1"];
    }];
    
}
-(void)bow2Tapped
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        imageClass^=BOW;
        _Bow.image=[UIImage imageNamed:@"bow2"];
    }];
    
}
-(void)necklace1Tapped
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        imageClass^=NECKLACE;
        _NeckLace.image=[UIImage imageNamed:@"necklace1"];
    }];
    
}
-(void)pipeTapped
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        imageClass^=CIGARRETE;
        _Cigarette.image=[UIImage imageNamed:@"pipe"];
    }];
    
}
-(void)hatTapped
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        imageClass^=HAT;
        _Hat.image=[UIImage imageNamed:@"hat3"];
    }];
    
}
-(void)bigmouthTapped
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        imageClass^=BIGMOUTH;
        _BigMouth.image=[UIImage imageNamed:@"bigmouth"];
    }];
}
-(void)sharkTapped
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        imageClass^=SHARK;
        _Shark.image=[UIImage imageNamed:@"shark2"];
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //MARK:Scroll view的滚动选择
    _ScrollView.frame=CGRectMake(0,859,900,80);
    _ScrollView.contentSize=CGSizeMake(1650, 80);
    _ScrollView.backgroundColor=UIColor.grayColor;
    UIImageView *imageView1 = [[UIImageView alloc] init];
    imageView1.image = [UIImage imageNamed:@"glass1"];
    imageView1.frame=CGRectMake(0, 0, 100, 80);
    imageView1.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(glass1Tapped)];
    [imageView1 addGestureRecognizer:singleTap];//点击图片事件
    [_ScrollView addSubview:imageView1];
    
    UIImageView *imageView2 = [[UIImageView alloc] init];
    imageView2.image = [UIImage imageNamed:@"glass2"];
    imageView2.frame=CGRectMake(100, 0, 100, 80);
    imageView2.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(glass2Tapped)];
    [imageView2 addGestureRecognizer:singleTap2];//点击图片事件
    [_ScrollView addSubview:imageView2];
    
    UIImageView *imageView3 = [[UIImageView alloc] init];
    imageView3.image = [UIImage imageNamed:@"beard1"];
    imageView3.frame=CGRectMake(200, 0, 100, 80);
    imageView3.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beard1Tapped)];
    [imageView3 addGestureRecognizer:singleTap3];//点击图片事件
    [_ScrollView addSubview:imageView3];
    
    UIImageView *imageView4 = [[UIImageView alloc] init];
    imageView4.image = [UIImage imageNamed:@"beard2"];
    imageView4.frame=CGRectMake(300, 0, 100, 80);
    imageView4.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beard2Tapped)];
    [imageView4 addGestureRecognizer:singleTap4];//点击图片事件
    [_ScrollView addSubview:imageView4];
    
    UIImageView *imageView5 = [[UIImageView alloc] init];
    imageView5.image = [UIImage imageNamed:@"face1"];
    imageView5.frame=CGRectMake(400, 0, 100, 80);
    imageView5.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(face1Tapped)];
    [imageView5 addGestureRecognizer:singleTap5];//点击图片事件
    [_ScrollView addSubview:imageView5];
    
    UIImageView *imageView6 = [[UIImageView alloc] init];
    imageView6.image = [UIImage imageNamed:@"mouth1"];
    imageView6.frame=CGRectMake(500, 0, 100, 80);
    imageView6.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mouth1Tapped)];
    [imageView6 addGestureRecognizer:singleTap6];//点击图片事件
    [_ScrollView addSubview:imageView6];
    
    UIImageView *imageView7 = [[UIImageView alloc] init];
    imageView7.image = [UIImage imageNamed:@"left_eye2"];
    imageView7.frame=CGRectMake(600, 0, 100, 80);
    imageView7.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap7 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(left_eye2Tapped)];
    [imageView7 addGestureRecognizer:singleTap7];//点击图片事件
    [_ScrollView addSubview:imageView7];
    
    UIImageView *imageView8 = [[UIImageView alloc] init];
    imageView8.image = [UIImage imageNamed:@"right_eye1"];
    imageView8.frame=CGRectMake(700, 0, 100, 80);
    imageView8.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap8 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(right_eye1Tapped)];
    [imageView8 addGestureRecognizer:singleTap8];//点击图片事件
    [_ScrollView addSubview:imageView8];
    
    UIImageView *imageView9 = [[UIImageView alloc] init];
    imageView9.image = [UIImage imageNamed:@"ear1"];
    imageView9.frame=CGRectMake(800, 0, 100, 80);
    imageView9.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap9 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ear1Tapped)];
    [imageView9 addGestureRecognizer:singleTap9];//点击图片事件
    [_ScrollView addSubview:imageView9];
    
    UIImageView *imageView10 = [[UIImageView alloc] init];
    imageView10.image = [UIImage imageNamed:@"bow2"];
    imageView10.frame=CGRectMake(900, 0, 100, 80);
    imageView10.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap10 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bow2Tapped)];
    [imageView10 addGestureRecognizer:singleTap10];//点击图片事件
    [_ScrollView addSubview:imageView10];
    
    UIImageView *imageView11 = [[UIImageView alloc] init];
    imageView11.image = [UIImage imageNamed:@"necklace1"];
    imageView11.frame=CGRectMake(1000, 0, 100, 80);
    imageView11.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap11 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(necklace1Tapped)];
    [imageView11 addGestureRecognizer:singleTap11];//点击图片事件
    [_ScrollView addSubview:imageView11];
    
    UIImageView *imageView12 = [[UIImageView alloc] init];
    imageView12.image = [UIImage imageNamed:@"pipe"];
    imageView12.frame=CGRectMake(1100, 0, 100, 80);
    imageView12.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap12 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pipeTapped)];
    [imageView12 addGestureRecognizer:singleTap12];//点击图片事件
    [_ScrollView addSubview:imageView12];
    
    UIImageView *imageView13 = [[UIImageView alloc] init];
    imageView13.image = [UIImage imageNamed:@"hat3"];
    imageView13.frame=CGRectMake(1200, 0, 100, 80);
    imageView13.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap13 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hatTapped)];
    [imageView13 addGestureRecognizer:singleTap13];//点击图片事件
    [_ScrollView addSubview:imageView13];
    
    UIImageView *imageView14 = [[UIImageView alloc] init];
    imageView14.image = [UIImage imageNamed:@"bigmouth"];
    imageView14.frame=CGRectMake(1300, 0, 100, 80);
    imageView14.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap14 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigmouthTapped)];
    [imageView14 addGestureRecognizer:singleTap14];//点击图片事件
    [_ScrollView addSubview:imageView14];
    
    UIImageView *imageView15 = [[UIImageView alloc] init];
    imageView15.image = [UIImage imageNamed:@"shark2"];
    imageView15.frame=CGRectMake(1400, 0, 100, 80);
    imageView15.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap15 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sharkTapped)];
    [imageView15 addGestureRecognizer:singleTap15];//点击图片事件
    [_ScrollView addSubview:imageView15];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    //相机未开启
    start=false;
    
    [self initiateMenuOptions];
    
    // set custom navigationBar with a bigger height
    [self.navigationController setValue:[[YALNavigationBar alloc]init] forKeyPath:@"navigationBar"];
    ///////////////////
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _Glass.frame=CGRectMake(0,0, 0, 0);
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _Ear.frame=CGRectMake(0,0, 0, 0);
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _Beard.frame=CGRectMake(0,0, 0, 0);
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _Face.frame=CGRectMake(0,0, 0, 0);
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _Cigarette.frame=CGRectMake(0,0, 0, 0);
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _NeckLace.frame=CGRectMake(0,0, 0, 0);
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _Mouth.frame=CGRectMake(0,0, 0, 0);
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _LeftEye.frame=CGRectMake(0,0, 0, 0);
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _RightEye.frame=CGRectMake(0,0, 0, 0);
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _Bow.frame=CGRectMake(0,0, 0, 0);
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _Hat.frame=CGRectMake(0,0, 0, 0);
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _BigMouth.frame=CGRectMake(0,0, 0, 0);
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _Shark.frame=CGRectMake(0,0, 0, 0);
    }];
    //MARK: imageClass初始化
    //imageClass=HAT|BOW;
//    imageClass|=NECKLACE|MOUTH;
//    imageClass|=LEFTEYE|RIGHTEYE;
//    imageClass=NONE;
    //printf("p:%d,",choice);
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    //should be called after rotation animation completed
    [self.contextMenuTableView reloadData];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.contextMenuTableView updateAlongsideRotation];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        //should be called after rotation animation completed
        [self.contextMenuTableView reloadData];
    }];
    [self.contextMenuTableView updateAlongsideRotation];
    
}

#pragma mark - IBAction

- (IBAction)presentMenuButtonTapped:(UIBarButtonItem *)sender {
    //自己加的判断
    first=true;
    // init YALContextMenuTableView tableView
    if (!self.contextMenuTableView) {
        self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.animationDuration = 0.05;
        //optional - implement custom YALContextMenuTableView custom protocol
        self.contextMenuTableView.yalDelegate = self;
        //optional - implement menu items layout
        self.contextMenuTableView.menuItemsSide = Right;
        self.contextMenuTableView.menuItemsAppearanceDirection = FromBottomToTop;
        
        //register nib
        UINib *cellNib = [UINib nibWithNibName:@"ContextMenuCell" bundle:nil];
        [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
        
    }
    
    // it is better to use this method only for proper animation
    [self.contextMenuTableView showInView:self.navigationController.view withEdgeInsets:UIEdgeInsetsZero animated:YES];
}


- (IBAction)startButtonPressed:(id)sender
{
    i=0;
    if(start==false){
        [self.videoCamera start];
        [self.start setTitle:@"stop" forState:UIControlStateNormal];
        start=true;
        //图片是第一次选择
        first=true;
    }else{
        imageClass=NONE;
        [self.videoCamera stop];
        [self.start setTitle:@"start" forState:UIControlStateNormal];
        start=false;
        first=false;
    }
}

- (void)processImage:(cv::Mat &)image
{
    cv::Mat targetImage(image.cols,image.rows,CV_8UC3);
    cv::cvtColor(image, targetImage, cv::COLOR_BGRA2BGR);

    if(targetImage.empty()){
        std::cout << "targetImage empty" << std::endl;
    }
    else
    {
        float fx, fy, cx, cy;
        cx = 1.0*targetImage.cols / 2.0;
        cy = 1.0*targetImage.rows / 2.0;
    
        fx = 500 * (targetImage.cols / 640.0);
        fy = 500 * (targetImage.rows / 480.0);
    
        fx = (fx + fy) / 2.0;
        fy = fx;
        res=[[FaceARDetectIOS alloc] run_FaceAR:targetImage frame__:frame_count fx__:fx fy__:fy cx__:cx cy__:cy];
        rows = res.rows/2;
        double eyebrowLeftX=res.at<double>(17);
        double eyebrowLeftY=res.at<double>(17+rows);
        double eyebrowRightX=res.at<double>(26);
        //double eyebrowRightY=res.at<double>(26+rows);
        double height=res.at<double>(29+rows)-res.at<double>(27+rows);
        double mouthHeight=res.at<double>(66+rows)-res.at<double>(62+rows);
        x=eyebrowLeftX;
        y=eyebrowLeftY;
        double width=(eyebrowRightX-eyebrowLeftX);//width需要乘2来保证大小合适
        //赋值类型，到时候需要放到按钮里面
        //imageClass=BEARD|FACE;
        //imageClass=GLASS|EAR;
        //printf("process:%x",imageClass);
        if(imageClass&GLASS){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
               // _Glass.frame=CGRectMake(x+width/2,y+height, width*2, height/3);
                _Glass.frame=CGRectMake(x*1.6-30,y*1.7-50, width*2, height*2);
            }];
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _Glass.frame=CGRectMake(0,0, 0, 0);
            }];
        }
        if(imageClass&EAR){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                //_Ear.frame=CGRectMake(x,y-height/3, width*3, height);
                _Ear.frame=CGRectMake(x*1.6-30-width/2,y*1.7-50-height*5, width*3, height*4);
            }];
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _Ear.frame=CGRectMake(0,0, 0, 0);
            }];
        }
        if(imageClass&FACE){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _Face.frame=CGRectMake(x*1.6-30,y*1.7-80, width*2, height*6);
            }];
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _Face.frame=CGRectMake(0,0, 0, 0);
            }];
        }
        if(imageClass&BEARD){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _Beard.frame=CGRectMake(x*1.6-30+width/4,y*1.7-60+height*3, width*3/2, height*2);
            }];
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _Beard.frame=CGRectMake(0,0, 0, 0);
            }];
        }
        if(imageClass&CIGARRETE){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _Cigarette.frame=CGRectMake(x*1.6-30+width,y*1.7-50+height*4, width+20, height*4);
            }];
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _Cigarette.frame=CGRectMake(0,0, 0, 0);
            }];
        }
        if(imageClass&NECKLACE){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _NeckLace.frame=CGRectMake(x*1.6-30,res.at<double>(8+rows)*1.7-50, width*2, height*3);
            }];
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _NeckLace.frame=CGRectMake(0,0, 0, 0);
            }];
        }
        if(imageClass&MOUTH){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _Mouth.frame=CGRectMake(x*1.6-30+width/2,y*1.7-60+height*5, width, height*2);
            }];
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _Mouth.frame=CGRectMake(0,0, 0, 0);
            }];
        }
        if(imageClass&LEFTEYE){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _LeftEye.frame=CGRectMake(x*1.6-30,y*1.7-50, width, height*3);
            }];
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _LeftEye.frame=CGRectMake(0,0, 0, 0);
            }];
        }
        if(imageClass&RIGHTEYE){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _RightEye.frame=CGRectMake(x*1.6-30+width,y*1.7-50, width, height*3);
            }];
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _RightEye.frame=CGRectMake(0,0, 0, 0);
            }];
        }
        if(imageClass&BOW){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _Bow.frame=CGRectMake(x*1.6-30+width/2,res.at<double>(8+rows)*1.7-50, width, height*4);
            }];
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _Bow.frame=CGRectMake(0,0, 0, 0);
            }];
        }
        if(imageClass&HAT){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _Hat.frame=CGRectMake(x*1.6-30-width/5,y*1.7-50-height*7, width*3, height*6);
            }];
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _Hat.frame=CGRectMake(0,0, 0, 0);
            }];
        }
        if(imageClass&BIGMOUTH&&mouthHeight>=10){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _BigMouth.frame=CGRectMake(x*1.6-30+width/2,res.at<double>(49+rows)*1.7-50-mouthHeight/2, width, mouthHeight*1.7);
            }];
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _BigMouth.frame=CGRectMake(0,0, 0, 0);
            }];
        }
        if(imageClass&SHARK){
            if(mouthHeight<=10){
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    _Shark.frame=CGRectMake(x*1.6-20,y*1.7-50-height*4, width*2, height*12);
                }];
//            }else if(mouthHeight>=40){
//                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                    _Shark.frame=CGRectMake(x*1.6-30+width/2,y*1.7-50-height*4, width/2, height*3);
//                }];
            }else{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    _Shark.frame=CGRectMake(x*1.6-30+width/2+mouthHeight,y*1.7-50-height*4+mouthHeight*5, width*(20/mouthHeight), height*(120/mouthHeight));
                }];
            }
            
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _Shark.frame=CGRectMake(0,0, 0, 0);
            }];
        }

        frame_count = frame_count + 1;
        
    }
    cv::cvtColor(targetImage, image, cv::COLOR_BGRA2RGB);
}


#pragma mark - Local methods

- (void)initiateMenuOptions {
    self.menuTitles = @[@"",
                        @"Hat",
                        @"Glass",
                        @"Beard",
                        @"Face",
                        @"Necklace",
                        @"Bow",
                        @"LeftEye",
                        @"RightEye",
                        @"Mouth",
                        @"Ear",
                        @"Pipe"];
    
    self.menuIcons = @[[UIImage imageNamed:@"Icnclose"],
                       [UIImage imageNamed:@"hat3"],
                       [UIImage imageNamed:@"glass1"],
                       [UIImage imageNamed:@"beard1"],
                       [UIImage imageNamed:@"face1"],
                       [UIImage imageNamed:@"necklace1"],
                       [UIImage imageNamed:@"bow1"],
                       [UIImage imageNamed:@"left_eye2"],
                       [UIImage imageNamed:@"right_eye1"],
                       [UIImage imageNamed:@"mouth1"],
                       [UIImage imageNamed:@"ear1"],
                       [UIImage imageNamed:@"pipe"]];
}


#pragma mark - YALContextMenuTableViewDelegate

- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"Menu dismissed with indexpath = %@", indexPath);
}

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    //NSLog(@"Dismissed with item %d: %@", itemIndex, item.title);
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView dismisWithIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuTitles.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
    
    if (cell) {
        cell.backgroundColor = [UIColor clearColor];
        cell.menuTitleLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
        cell.menuImageView.image = [self.menuIcons objectAtIndex:indexPath.row];
        // NSLog(@"in cell create:%@",cell.menuTitleLabel.text);
    }
    
    return cell;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
