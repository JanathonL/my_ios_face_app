//
//  YALSideMenuCell.m
//  YALMenuAnimation
//
//  Created by Maksym Lazebnyi on 1/12/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//

#import "ContextMenuCell.h"
#import <stdio.h>

#import "RNGridMenu.h"
#import "ViewController.h"

@interface ContextMenuCell ()
@end
//extern int choice;
extern imgClss imageClass;
extern bool first;

@implementation ContextMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.layer.masksToBounds = YES;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowColor = [[UIColor colorWithRed:181.0/255.0 green:181.0/255.0 blue:181.0/255.0 alpha:1] CGColor];
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.5;
}

//这个函数是第一次选择按钮按下去的反馈，要写什么逻辑直接参照我下面这个send message这个按钮写就好了
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    static int cnt = 0;
    cnt++;
    NSLog(@"%d",cnt);
    //if(cnt>=41){
    if ((cnt == 62 || (cnt-62 > 0 &&(cnt-62)%38 == 0))) {
        printf("%d\n",first);
        if ([self.menuTitleLabel.text isEqualToString:@"Hat"]&&first==true) {
            //showGrid就是二次选择按钮展示
            //[self showGrid];
            NSLog(@"%@",self.menuTitleLabel.text);
            imageClass^=HAT;
            //printf("%d",imageClass);
            //[Example instanceCount]
            //imageClass=NONE;
            first=false;
            printf("hat\n");
            
        }
        if ([self.menuTitleLabel.text isEqualToString:@"Glass"]&&first==true) {
            imageClass^=GLASS;
            //int i=2;
            //choice=1;
            //printf("%d\n",choice);
            first=false;
            printf("glass\n");
        }
        if ([self.menuTitleLabel.text isEqualToString:@"Beard"]&&first==true) {
            imageClass^=BEARD;
            //printf("%d\n",imageClass);
            printf("beard\n");
            first=false;
        }
        if ([self.menuTitleLabel.text isEqualToString:@"Face"]&&first==true) {
            imageClass^=FACE;
            //printf("%d\n",imageClass);
            printf("face\n");
            first=false;
        }
        if ([self.menuTitleLabel.text isEqualToString:@"Necklace"]&&first==true) {
            imageClass^=NECKLACE;
            printf("necklace\n");
            first=false;
        }
        if ([self.menuTitleLabel.text isEqualToString:@"Bow"]&&first==true) {
            imageClass^=BOW;
            printf("bow\n");
            first=false;
        }
        if ([self.menuTitleLabel.text isEqualToString:@"LeftEye"]&&first==true) {
            imageClass^=LEFTEYE;
            printf("left\n");
            first=false;
        }
        if ([self.menuTitleLabel.text isEqualToString:@"RightEye"]&&first==true) {
            imageClass^=RIGHTEYE;
            printf("right\n");
            first=false;
        }
        if ([self.menuTitleLabel.text isEqualToString:@"Mouth"]&&first==true) {
            imageClass^=MOUTH;
            first=false;
        }
        if ([self.menuTitleLabel.text isEqualToString:@"Ear"]&&first==true) {
            imageClass^=EAR;
            first=false;
        }
        if ([self.menuTitleLabel.text isEqualToString:@"Pipe"]&&first==true) {
            imageClass^=CIGARRETE;
            first=false;
        }
        //cnt=0;
    }
}


//这个函数是二次选择按钮的反馈
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    NSLog(@"Dismissed with item %d: %@", itemIndex, item.title);
}


- (void)showGrid {
    NSInteger numberOfOptions = 9;
    NSArray *items = @[
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"arrow"] title:@"Next"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"attachment"] title:@"Attach"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"block"] title:@"Cancel"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"bluetooth"] title:@"Bluetooth"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"cube"] title:@"Deliver"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"download"] title:@"Download"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"enter"] title:@"Enter"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"file"] title:@"Source Code"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"github"] title:@"Github"]
                       ];
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    ViewController* vc;
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            vc = (ViewController*)nextResponder;
        }
    }
    //这里我已经把ViewController这个类变成了RNGridMenudelegate只要我找到我写的viewController就可以进行代理
    av.delegate = vc;
    //    av.bounces = NO;
    [av showInViewController:vc center:CGPointMake(vc.view.bounds.size.width/2.f, vc.view.bounds.size.height/2.f)];
}

#pragma mark - YALContextMenuCell

- (UIView*)animatedIcon {
    return self.menuImageView;
}

- (UIView *)animatedContent {
    return self.menuTitleLabel;
}

@end
