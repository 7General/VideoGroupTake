//
//  TakeShortVideoViewController.m
//  VideoTake
//
//  Created by zzg on 2018/2/26.
//  Copyright © 2018年 zzg. All rights reserved.
//

#import "TakeShortVideoViewController.h"
#import "PressButton.h"
#import "TakePressButton.h"

@interface TakeShortVideoViewController ()


@end

@implementation TakeShortVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.title = @"拍摄短视频";
    
    TakePressButton * press = [[TakePressButton alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    [self.view addSubview:press];
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

