//
//  FSImageUtils.mm
//  FaceSwap
//
//  Created by Alexander Karlsson on 2016-12-31.
//  Copyright © 2016 Alexander Karlsson. All rights reserved.
//


#import "FSImageUtils.h"
#include <vector>

#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <ImageIO/CGImageProperties.h>
#import <QuartzCore/QuartzCore.h>

#include "dlib/opencv.h"
#include "dlib/image_processing.h"


#define SIZE_LIMIT 20000

@implementation FSImageUtils
{
    dlib::shape_predictor sp;
    
    // For liveSwap library mode
    cv::Mat matLibMode;
    std::vector<cv::Point2f> facePtsLibMode;
    
}


-(id)init {
    if ( self = [super init] ) {
        // Predictor for facial landmark positions
        NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
        const char* modelFileNameCString = [modelFileName UTF8String];
        
        // Load predictor with trained model
        dlib::deserialize(modelFileNameCString) >> sp;
    }
    return self;
}


#pragma mark Global functions


/** 
 Returns the number of input faces.
 */
-(NSInteger)nbrOfFaces :(UIImage*)img
{
    try {
        // Convert to opencv mat and to correct color space
        cv::Mat mat = [self cvMatFromUIImage:img];
        cv::cvtColor(mat, mat, cv::COLOR_BGR2RGB);
        
        // Adjust image size
        mat = [self resizeImage:mat WithSizeLimit:700];
    				
        // Detect faces
        std::vector<dlib::rectangle> faces = [self detectFace:[self UIImageFromCVMat:mat]];
        
        return (NSInteger)faces.size();
    
    } catch (cv::Exception exep) {
        return 0;
    }
    
    return 0;
}


/** 
 Swaps faces of two selfie images. (Public)
 The face in img1 will be pasted over img2's face.
 img1: first selfie image.
 img2: second selfie image.
 */
-(UIImage*)swapFaces :(UIImage*)img1 :(UIImage*)img2 :(FSSwapStatus_t&)FSStatus
{
    FSStatus = FS_STATUS_OK;
    
    cv::Mat mat1 = [self cvMatFromUIImage:img1];
    cv::Mat mat2 = [self cvMatFromUIImage:img2];
    
    // Check size
    if (mat1.rows * mat1.cols < SIZE_LIMIT) FSStatus = FS_STATUS_IMAGE_TOO_SMALL;
    if (mat2.rows * mat2.cols < SIZE_LIMIT) FSStatus = FS_STATUS_IMAGE_TOO_SMALL;
    if (FSStatus == FS_STATUS_IMAGE_TOO_SMALL)
        return [self UIImageFromCVMat:mat1];
    
    // Use correct color space
    cv::cvtColor(mat1, mat1, cv::COLOR_BGR2RGB);
    cv::cvtColor(mat2, mat2, cv::COLOR_BGR2RGB);
    
    // Adjust image size
    mat1 = [self resizeImage:mat1 WithSizeLimit:700];
    mat2 = [self resizeImage:mat2 WithSizeLimit:700];
    
    // Convert to dlib images
    dlib::cv_image<dlib::bgr_pixel> img1Dlib = [self CVMat2DlibImage:mat1];
    dlib::cv_image<dlib::bgr_pixel> img2Dlib = [self CVMat2DlibImage:mat2];
    
    // Get facial landmarks
    std::vector<std::vector<cv::Point2f>> lm1 = [self DLibFacialLandmarks:img1Dlib :img1];
    if (lm1.size() == 0) FSStatus = FS_STATUS_NO_FACE_FOUND;
    std::vector<std::vector<cv::Point2f>> lm2 = [self DLibFacialLandmarks:img2Dlib :img2];
    if (lm2.size() == 0) FSStatus = FS_STATUS_NO_FACE_FOUND;
    
    if (FSStatus == FS_STATUS_NO_FACE_FOUND)
        return [self UIImageFromCVMat:mat1];
    
    // Swap faces!
    cv::Mat swImg = [self faceSwap:mat1 :mat2 :lm1[0] :lm2[0]];
    
    // Convert back to UIImage
    UIImage* swUI = [self UIImageFromCVMat:swImg];

    return swUI;
}

/* Sort condition */
bool customFaceSort(std::vector<cv::Point2f> vecA, std::vector<cv::Point2f> vecB)
{
    return vecA[0].x < vecB[0].x;
}

/** 
 Swaps faces for images with >= 2 faces. (Public)
 */
-(UIImage*)swapFacesMulti :(UIImage*)img :(FSSwapStatus_t&)FSStatus
{
    UIImage* swUI;
    
    try {
        FSStatus = FS_STATUS_OK;
        
        cv::Mat mat1 = [self cvMatFromUIImage:img];
        
        // Use correct color space
        cv::cvtColor(mat1, mat1, cv::COLOR_BGR2RGB);
        
        // Check size
        if (mat1.rows * mat1.cols < SIZE_LIMIT) FSStatus = FS_STATUS_IMAGE_TOO_SMALL;
        if (FSStatus == FS_STATUS_IMAGE_TOO_SMALL) return [self UIImageFromCVMat:mat1];
        
        // Convert image to dlib compatible image
        dlib::cv_image<dlib::bgr_pixel> imgDlib = [self CVMat2DlibImage:mat1];
        
        // Get facial landmarks of input image
        std::vector<std::vector<cv::Point2f>> lm = [self DLibFacialLandmarks:imgDlib :img];
        
        std::sort(lm.begin(), lm.end(), customFaceSort);
        
        if (lm.size() == 0) FSStatus = FS_STATUS_NO_FACE_FOUND;
        if (lm.size() == 1) FSStatus = FS_STATUS_SINGLE_FACE_ERROR;
        if (lm.size() <= 1) return img;
        
        // Swap faces
        // Make a copy of input
        cv::Mat swImg = mat1.clone();
        
        // Loop all faces
        for (size_t i = lm.size()-1; i > 1; i-=2) {
            swImg = [self faceSwap:mat1.clone() :swImg :lm[i-1] :lm[i]];
            swImg = [self faceSwap:mat1.clone() :swImg :lm[i] :lm[i-1]];
        }
        
        // Different approach if image has even/odd number of faces
        if (lm.size() % 2 == 0) {
            swImg = [self faceSwap:mat1.clone() :swImg :lm[0] :lm[1]];
            swImg = [self faceSwap:mat1.clone() :swImg :lm[1] :lm[0]];
        } else {
            swImg = [self faceSwap:swImg :swImg :lm[1] :lm[0]];
            swImg = [self faceSwap:mat1.clone() :swImg :lm[0] :lm[1]];
        }
        
        swUI = [self UIImageFromCVMat:swImg];
        
    } catch (cv::Exception exep) {
        swUI = img;
        FSStatus = FS_STATUS_NO_FACE_FOUND;
    }
    
    return swUI;
}


/** 
 Replaces the faces in image 2 with the face in image1.
 */
-(UIImage*)swapFacesOneToMany :(UIImage*)img1 :(UIImage*)img2 :(FSSwapStatus_t&)FSStatus
{
    UIImage *swUI;
    
    try {
        FSStatus = FS_STATUS_OK;
        // Convert UIImages to cv Mat
        cv::Mat cvImg1 = [self cvMatFromUIImage:img1];
        cv::Mat cvImg2 = [self cvMatFromUIImage:img2];
        
        // Check size
        if (cvImg1.rows * cvImg1.cols < SIZE_LIMIT) FSStatus = FS_STATUS_IMAGE_TOO_SMALL;
        if (cvImg2.rows * cvImg2.cols < SIZE_LIMIT) FSStatus = FS_STATUS_IMAGE_TOO_SMALL;
        if (FSStatus == FS_STATUS_IMAGE_TOO_SMALL) return img1;
        
        int sizeLim = 2000;
        
        // Resize image if too big
        if (cvImg1.cols * cvImg1.rows > sizeLim) {
            NSLog(@"Resized image 1");
            cvImg1 = [self resizeImage:cvImg1 WithSizeLimit:sizeLim];
        }
        if (cvImg2.cols * cvImg2.rows > sizeLim) {
            NSLog(@"Resized image 2");
            cvImg2 = [self resizeImage:cvImg2 WithSizeLimit:sizeLim];
        }
        
        // Change orientation if image has wrong orientation
        if (img1.imageOrientation == UIImageOrientationRight)
            [self rotateImg:cvImg1];
        
        if (img2.imageOrientation == UIImageOrientationRight)
            [self rotateImg:cvImg2];
                
        // Use correct color space
        cv::cvtColor(cvImg1, cvImg1, cv::COLOR_BGR2RGB);
        cv::cvtColor(cvImg2, cvImg2, cv::COLOR_BGR2RGB);
        
        // Convert to dlib images
        dlib::cv_image<dlib::bgr_pixel> img1Dlib = [self CVMat2DlibImage:cvImg1];
        dlib::cv_image<dlib::bgr_pixel> img2Dlib = [self CVMat2DlibImage:cvImg2];
        
        // Get facial landmarks
        std::vector<std::vector<cv::Point2f>> lm1 = [self DLibFacialLandmarks:img1Dlib :[self UIImageFromCVMat:cvImg1]];
        if (lm1.size() == 0) FSStatus = FS_STATUS_NO_FACE_FOUND;
        
        std::vector<std::vector<cv::Point2f>> lm2 = [self DLibFacialLandmarks:img2Dlib :[self UIImageFromCVMat:cvImg2]];
        if (lm2.size() == 0) FSStatus = FS_STATUS_NO_FACE_FOUND;
        
        if (FSStatus == FS_STATUS_NO_FACE_FOUND) return img1;
        
        // Swap faces!
        cv::Mat img2Cl = cvImg2.clone();
        // Replace all faces in image 2 with the face in image 1.
        for (size_t i = 0; i < lm2.size(); i++)
            img2Cl = [self faceSwap:cvImg1 :img2Cl :lm1[0] :lm2[i]];
        
        // Convert back to UIImage
        swUI = [self UIImageFromCVMat:img2Cl];
        
    } catch (cv::Exception exep) {
        swUI = img1;
        FSStatus = FS_STATUS_NO_FACE_FOUND;
    }
    
    return swUI;
}


/** 
 Swaps faces in live mode.
 Supports swapps of two faces in the same image.
 */
-(void)liveSwapFaces :(cv::Mat&)mat
{
    cv::Mat mat1 = mat.clone();
    try {
        dlib::cv_image<dlib::bgr_pixel> img1Dlib = [self CVMat2DlibImage:mat];
        std::vector<std::vector<cv::Point2f>> lm = [self DLibFacialLandmarks:img1Dlib :[self UIImageFromCVMat:mat]];
        
        // Swap faces
        // Make a copy of input
        cv::Mat swImg = mat.clone();
        
        if (lm.size() >= 2) {
            // Swap two faces
            //swImg = [self faceSwap:mat.clone() :swImg :lm[1] :lm[0]];
            //swImg = [self faceSwap:mat.clone() :swImg :lm[0] :lm.back()];
            
            std::sort(lm.begin(), lm.end(), customFaceSort);
            
            // Loop all faces
            for (size_t i = lm.size()-1; i > 1; i-=2) {
                swImg = [self faceSwap:mat1.clone() :swImg :lm[i-1] :lm[i]];
                swImg = [self faceSwap:mat1.clone() :swImg :lm[i] :lm[i-1]];
            }
            
            // Different approach if image has even/odd number of faces
            if (lm.size() % 2 == 0) {
                swImg = [self faceSwap:mat1.clone() :swImg :lm[0] :lm[1]];
                swImg = [self faceSwap:mat1.clone() :swImg :lm[1] :lm[0]];
            } else {
                swImg = [self faceSwap:swImg :swImg :lm[1] :lm[0]];
                swImg = [self faceSwap:mat1.clone() :swImg :lm[0] :lm[1]];
            }
        }
        
        mat = swImg;
        
    } catch(cv::Exception exep) {
        cv::cvtColor(mat1, mat1, cv::COLOR_BGR2RGB);
        mat = mat1;
    }
}



/** 
 Prepares for liveswap when a library image is used for face replacement.
 */
-(void)prepareForLiveSwapLibMode :(UIImage*)img
{
    // Convert to opencv mat and to correct color space
    cv::Mat mat = [self cvMatFromUIImage:img];
    cv::cvtColor(mat, mat, cv::COLOR_BGRA2RGB);
    
    // Adjust image size
    mat = [self resizeImage:mat WithSizeLimit:700];
    matLibMode = mat;
    dlib::cv_image<dlib::bgr_pixel> img1Dlib = [self CVMat2DlibImage:mat];
    std::vector<std::vector<cv::Point2f>> lm = [self DLibFacialLandmarks:img1Dlib :[self UIImageFromCVMat:mat]];
    facePtsLibMode = lm[0];
}


/** 
 Swaps faces live, but with pre-loaded library images that will replace face(s).
 */
-(void)liveSwapFacesLibMode :(cv::Mat&)mat
{
    cv::Mat mat1 = mat.clone();
    try {
        dlib::cv_image<dlib::bgr_pixel> img1Dlib = [self CVMat2DlibImage:mat];
        std::vector<std::vector<cv::Point2f>> lm = [self DLibFacialLandmarks:img1Dlib :[self UIImageFromCVMat:mat]];
        
        // Swap faces
        // Make a copy of input
        cv::Mat swImg = mat.clone();
        
        if (lm.size() >= 1) {
            for (size_t i = 0; i < lm.size(); i++)
                swImg = [self faceSwap:matLibMode :swImg :facePtsLibMode :lm[i]];
        }
        
        mat = swImg;

    } catch(cv::Exception exep) {
        cv::cvtColor(mat1, mat1, cv::COLOR_BGR2RGB);
        mat = mat1;
    }
}


#pragma mark Face detection


/** 
 Apple face detection. Should be faster than dlibs.
 */
-(std::vector<dlib::rectangle>)detectFace :(UIImage*)img
{
    // Convert UIImage to CIImage
    CIImage* image = [CIImage imageWithCGImage:img.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };
    // Create the detector with high accuracy
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:context
                                              options:opts];
    
    // Make a transform that will help transforming found face to right coordinates
    int height = img.size.height;
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -1 * height);

    
    // Find orientation?
    int exifOrientation;
    switch (img.imageOrientation) {
        case UIImageOrientationUp:
            exifOrientation = 1;
            break;
        case UIImageOrientationDown:
            exifOrientation = 3;
            break;
        case UIImageOrientationLeft:
            exifOrientation = 8;
            break;
        case UIImageOrientationRight:
            exifOrientation = 6;
            break;
        case UIImageOrientationUpMirrored:
            exifOrientation = 2;
            break;
        case UIImageOrientationDownMirrored:
            exifOrientation = 4;
            break;
        case UIImageOrientationLeftMirrored:
            exifOrientation = 5;
            break;
        case UIImageOrientationRightMirrored:
            exifOrientation = 7;
            break;
        default:
            break;
    }
    
    opts = @{ CIDetectorImageOrientation :[NSNumber numberWithInt:exifOrientation
                                           ] };
    NSArray *features = [detector featuresInImage:image options:opts];

    // Save face bounding box as dlib structure, dlib will be used to find the facial landmarks
    std::vector<dlib::rectangle> faces;

    
    for (CIFaceFeature *f in features) {
        //NSLog(@"%@", NSStringFromCGRect(f.bounds));
        // Facial bounding box
        CGRect faceRect = CGRectApplyAffineTransform(f.bounds, transform);
        
        // Facial bounding box features
        int width = (int)faceRect.size.width;
        int height = (int)faceRect.size.height;
        int x = (int)faceRect.origin.x;
        int y = (int)faceRect.origin.y;
        
        dlib::rectangle rct(x, y, x + width, y + height);
        faces.push_back(rct);
    }
    
    return faces;
}


#pragma mark Facial landmarks section


-(std::vector<std::vector<cv::Point2f>>)DLibFacialLandmarks:(dlib::cv_image<dlib::bgr_pixel>)img :(UIImage*)UIImg
{    
    // Get a list of bounding boxes for found faces
    std::vector<dlib::rectangle> dets = [self detectFace:UIImg];
    std::vector<std::vector<cv::Point2f>> landmarks;
    
    // Can be used for multiple face detection
    for (unsigned long j = 0; j < dets.size(); ++j) {
        dlib::full_object_detection shape = sp(img, dets[j]);
        
        // Store temporary x and y coordinates here, will be used for the swapping stage.
        std::vector<cv::Point2f> lm;
        for (size_t i = 0; i < shape.num_parts(); i++) {
            lm.push_back(cv::Point2f((float)shape.part(i).x(), (float)shape.part(i).y()));
        }
        landmarks.push_back(lm);
    }

    return landmarks;
}


#pragma mark FaceSwap section


/**
 Main faceSwap function
 */
-(cv::Mat)faceSwap:(cv::Mat)img1 :(cv::Mat)img2 :(std::vector<cv::Point2f>)points1 :(std::vector<cv::Point2f>)points2
{
    cv::Mat img1Warped = img2.clone();
    
    //convert Mat to float data type
    img1.convertTo(img1, CV_32F);
    img1Warped.convertTo(img1Warped, CV_32F);
    
    cv::Mat img11 = img1, img22 = img2;
    img11.convertTo(img11, CV_8UC3);
    img22.convertTo(img22, CV_8UC3);
    
    // Find convex hull
    std::vector<cv::Point2f> hull1;
    std::vector<cv::Point2f> hull2;
    std::vector<int> hullIndex;
    
    cv::convexHull(points2, hullIndex, false, false);
    
    for (size_t i = 0; i < hullIndex.size(); i++) {
        hull1.push_back(points1[hullIndex[i]]);
        hull2.push_back(points2[hullIndex[i]]);
    }
    
    // Find delaunay triangulation for points on the convex hull
    std::vector< std::vector<int> > dt;
    cv::Rect rect1(0, 0, img1Warped.cols, img1Warped.rows);
    
    [self calculateDelaunayTriangles:rect1 :hull2 :dt];
    
    // Apply affine transformation to Delaunay triangles
    for (size_t i = 0; i < dt.size(); i++) {
        std::vector<cv::Point2f> t1, t2;
        // Get points for img1, img2 corresponding to the triangles
        for(size_t j = 0; j < 3; j++) {
            t1.push_back(hull1[dt[i][j]]);
            t2.push_back(hull2[dt[i][j]]);
        }
        
        [self warpTriangle:img1 :img1Warped :t1 :t2];
    }
    
    // Calculate mask
    std::vector<cv::Point> hull8U;
    for (size_t i = 0; i < hull2.size(); i++) {
        cv::Point pt(hull2[i].x, hull2[i].y);
        hull8U.push_back(pt);
    }
    
    cv::Mat mask = cv::Mat::zeros(img2.rows, img2.cols, img2.depth());
    cv::fillConvexPoly(mask,&hull8U[0], (int)hull8U.size(), cv::Scalar(255,255,255));
    
    // Clone seamlessly.
    cv::Rect r = cv::boundingRect(hull2);
    img1Warped.convertTo(img1Warped, CV_8UC3);
    cv::Mat img1WarpedSub = img1Warped(r);
    cv::Mat img2Sub       = img2(r);
    cv::Mat maskSub       = mask(r);
    
    cv::Point center(r.width/2, r.height/2);
    
    cv::Mat output;
    cv::seamlessClone(img1WarpedSub, img2Sub, maskSub, center, output, cv::NORMAL_CLONE);
    output.copyTo(img2(r));
    
    return img2;
}


/**
 Warps and alpha blends triangular regions from img1 and img2 to img
 */
-(void)warpTriangle:(cv::Mat&)img1 :(cv::Mat&)img2 :(std::vector<cv::Point2f>&)t1 :(std::vector<cv::Point2f>&)t2
{
    cv::Rect r1 = cv::boundingRect(t1);
    cv::Rect r2 = cv::boundingRect(t2);
    
    // Offset points by left top corner of the respective rectangles
    std::vector<cv::Point2f> t1Rect, t2Rect;
    std::vector<cv::Point> t2RectInt;
    for (int i = 0; i < 3; i++) {
        t1Rect.push_back( cv::Point2f( t1[i].x - r1.x, t1[i].y -  r1.y) );
        t2Rect.push_back( cv::Point2f( t2[i].x - r2.x, t2[i].y - r2.y) );
        t2RectInt.push_back( cv::Point(t2[i].x - r2.x, t2[i].y - r2.y) ); // for fillConvexPoly
    }
    
    // Get mask by filling triangle
    cv::Mat mask = cv::Mat::zeros(r2.height, r2.width, img1.type());
    cv::fillConvexPoly(mask, t2RectInt, cv::Scalar(1.0, 1.0, 1.0), 16, 0);
    
    // Apply warpImage to small rectangular patches
    cv::Mat img1Rect;
    img1(r1).copyTo(img1Rect);
    
    cv::Mat img2Rect = cv::Mat::zeros(r2.height, r2.width, img1Rect.type());
    
    [self applyAffineTransform:img2Rect :img1Rect :t1Rect :t2Rect];
    
    cv::multiply(img2Rect,mask, img2Rect);
    cv::multiply(img2(r2), cv::Scalar(1.0,1.0,1.0) - mask, img2(r2));
    img2(r2) = img2(r2) + img2Rect;
}


/**
 Apply affine transform calculated using srcTri and dstTri to src
 */
-(void)applyAffineTransform:(cv::Mat&)warpImage :(cv::Mat&)src :(std::vector<cv::Point2f>&)srcTri :(std::vector<cv::Point2f>&)dstTri
{
    // Find the affine transform of two triangles.
    cv::Mat warpMat = cv::getAffineTransform( srcTri, dstTri );
    // Apply transform to src image
    cv::warpAffine( src, warpImage, warpMat, warpImage.size(), cv::INTER_LINEAR, cv::BORDER_REFLECT_101);
}


/** 
 Calculates the Delaunay triangulation of a set of points.
 */
-(void)calculateDelaunayTriangles:(cv::Rect)rect1 :(std::vector<cv::Point2f>&)points :(std::vector<std::vector<int>>&)delaunayTri
{
    // Object to find the Delaunay with
    cv::Subdiv2D subdiv(rect1);
    
    // Insert points into subdiv
    for (std::vector<cv::Point2f>::iterator it = points.begin(); it != points.end(); it++)
        subdiv.insert(*it);
    
    std::vector<cv::Vec6f> triangleList;
    subdiv.getTriangleList(triangleList);
    std::vector<cv::Point2f> pt(3);
    std::vector<int> ind(3);
    
    for (size_t i = 0; i < triangleList.size(); i++) {
        cv::Vec6f t = triangleList[i];
        pt[0] = cv::Point2f(t[0], t[1]);
        pt[1] = cv::Point2f(t[2], t[3]);
        pt[2] = cv::Point2f(t[4], t[5 ]);
        
        if (rect1.contains(pt[0]) && rect1.contains(pt[1]) && rect1.contains(pt[2])) {
            for (int j = 0; j < 3; j++)
                for (size_t k = 0; k < points.size(); k++)
                    if (std::abs(pt[j].x - points[k].x) < 1.0 && std::abs(pt[j].y - points[k].y) < 1)
                        ind[j] = (int)k;
            
            delaunayTri.push_back(ind);
        }
    }
}


# pragma mark Conversion section


/**
 Rotates the image mat clockwise(?).
 */
-(void)rotateImg :(cv::Mat&)mat
{
    cv::transpose(mat, mat);
    cv::flip(mat, mat, 1);
    cv::resize(mat, mat, cv::Size(mat.rows, mat.cols));
}


/** 
 Adjusts the size of input image.
 */
-(cv::Mat)resizeImage:(cv::Mat)img WithSizeLimit:(int)limit
{
    if (img.rows < limit || img.cols < limit) // Risky? Could one of them potentially be huge?
        return img;
    
    // Calculate ratio to keep proportions
    float ratio = (float)img.rows / (float)img.cols;
    
    cv::resize(img, img, cv::Size(limit/ratio, limit));
    
    return img;
}


/**
 Converts UIImage to OpenCV Mat
 http://docs.opencv.org/2.4/doc/tutorials/ios/image_manipulation/image_manipulation.html
 */
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}


/**
 Converts UIImage to grayscale OpenCV Mat
 http://docs.opencv.org/2.4/doc/tutorials/ios/image_manipulation/image_manipulation.html
 */
- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}


/**
 Converts OpenCV Mat to UIImage
 http://docs.opencv.org/2.4/doc/tutorials/ios/image_manipulation/image_manipulation.html
 */
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                              //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


/**
 Converts OpenCV Mat to Dlib image object
 http://stackoverflow.com/questions/37516675/opencv-dlib-mat-object-outputed-as-black-image
 http://dlib.net/webcam_face_pose_ex.cpp.html
 */
-(dlib::cv_image<dlib::bgr_pixel>)CVMat2DlibImage:(cv::Mat)cvMat
{
    cv::cvtColor(cvMat, cvMat, CV_RGBA2BGR);
    
    dlib::cv_image<dlib::bgr_pixel> dimg(cvMat);
    
    
    return dimg;
}

@end
