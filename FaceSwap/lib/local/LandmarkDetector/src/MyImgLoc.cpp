//
//  MyImgLoc.cpp
//  FaceAR_SDK_IOS_OpenFace_RunFull
//
//  Created by csmacpro01 on 2017/6/8.
//  Copyright © 2017年 Keegan Ren. All rights reserved.
//

#include <stdio.h>

class imgLoc{
private:
    int ax,ay,bx,by,cx,cy;
    int loc1x,loc1y,loc2x,loc2y;
public:
    imgLoc(int ax, int ay, int bx, int by, int cx, int cy){
        this->ax=ax;
        this->ay=ay;
        this->bx=bx;
        this->by=by;
        this->cx=cx;
        this->cy=cy;
    }
    int getLoc1(){
        return 1;
    }
};
