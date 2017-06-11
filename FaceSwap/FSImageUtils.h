//
//  FSImageUtils.h
//  FaceSwap
//
//  Created by Alexander Karlsson on 2016-12-31.
//  Copyright © 2016 Alexander Karlsson. All rights reserved.
//

#ifndef FacialLandmarksUtils_h
#define FacialLandmarksUtils_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "opencv2/photo.hpp"


@interface FSImageUtils : NSObject

typedef enum FSSwapStatus_t
{
    FS_STATUS_OK,
    FS_STATUS_NO_FACE_FOUND,
    FS_STATUS_SINGLE_FACE_ERROR,
    FS_STATUS_IMAGE_TOO_SMALL
} FSSwapStatus_t;

-(NSInteger)nbrOfFaces :(UIImage*)img;
//-(UIImage*)swapFaces :(UIImage*)img1 :(UIImage*)img2 :(FSSwapStatus_t&)FSStatus;
-(UIImage*)swapFacesMulti :(UIImage*)img :(FSSwapStatus_t&)FSStatus;
-(UIImage*)swapFacesOneToMany :(UIImage*)img1 :(UIImage*)img2 :(FSSwapStatus_t&)FSStatus;
-(void)prepareForLiveSwapLibMode :(UIImage*)img;
-(void)liveSwapFacesLibMode :(cv::Mat&)mat;
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;


-(void)liveSwapFaces :(cv::Mat&)mat;

@end

#endif /* FSImageUtils_h */
