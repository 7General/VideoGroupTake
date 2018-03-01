//
//  TakeShortVideoViewController.m
//  VideoTake
//
//  Created by zzg on 2018/2/26.
//  Copyright © 2018年 zzg. All rights reserved.
//

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#import "TakeShortVideoViewController.h"
#import "PressButton.h"
#import "TakePressButton.h"

@interface TakeShortVideoViewController ()


@end

@implementation TakeShortVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    self.title = @"拍摄短视频";
    
    UIView * toolView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT - 180, SCREENWIDTH, 180)];
    toolView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:toolView];
    
    CGFloat pW = 100;
    CGFloat pH = 100;
    CGFloat pX = SCREENWIDTH * 0.5 - pW * 0.5;
    CGFloat pY = 180 * 0.5 - pH * 0.5;
    
    TakePressButton * press = [[TakePressButton alloc] initWithFrame:CGRectMake(pX, pY, pW, pH)];
    press.backgroundColor = [UIColor redColor];
    [toolView addSubview:press];
    [press setButtonAction:^(LDPressButtonState state) {
        switch (state) {
            case Begin:
                NSLog(@"-------begin");
                break;
            case Moving:
                NSLog(@"-------moving");
                break;
            case WillCancle:
                NSLog(@"-------WillCancle");
                break;
            case DidCancle:
                NSLog(@"-------DidCancle");
                break;
            case End:
                NSLog(@"-------End");
                break;
            case Click:
                NSLog(@"-------Click");
                break;
            default:
                break;
        }
    }];
}





@end

