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
    if ((cnt == 31 || (cnt-32 > 0 &&(cnt-32)%20 == 0))) {
        if ([self.menuTitleLabel.text isEqualToString:@"Send message"]) {
            //showGrid就是二次选择按钮展示
            [self showGrid];
            NSLog(@"%@",self.menuTitleLabel.text);
            
        }
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
