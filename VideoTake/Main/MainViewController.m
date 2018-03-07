//
//  MainViewController.m
//  VideoTake
//
//  Created by zzg on 2018/2/6.
//  Copyright © 2018年 zzg. All rights reserved.
//

#import "MainViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "QRScannViewController.h"
#import "TakePhotoViewController.h"
#import "TakeVideoViewController.h"
#import "TakeShortVideoViewController.h"

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface MainViewController ()
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"视频照片";
    
    UIButton * takeVideo = [UIButton buttonWithType:UIButtonTypeCustom];
    takeVideo.frame = CGRectMake(100, 100, 100, 100);
    takeVideo.backgroundColor = [UIColor redColor];
    [takeVideo setTitle:@"拍摄照片" forState:UIControlStateNormal];
    [takeVideo addTarget:self action:@selector(takeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takeVideo];
    
    UIButton * takePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    takePhoto.frame = CGRectMake(100, 210, 100, 100);
    takePhoto.backgroundColor = [UIColor redColor];
    [takePhoto setTitle:@"拍摄视频" forState:UIControlStateNormal];
    [takePhoto addTarget:self action:@selector(takeVideoClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takePhoto];
    
    UIButton * takeShortVideo = [UIButton buttonWithType:UIButtonTypeCustom];
    takeShortVideo.frame = CGRectMake(100, 320, 100, 100);
    takeShortVideo.backgroundColor = [UIColor redColor];
    [takeShortVideo setTitle:@"拍摄短视频" forState:UIControlStateNormal];
    [takeShortVideo addTarget:self action:@selector(takeShortVideoClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takeShortVideo];
    
    
    
//
//
//    CGRect frames = CGRectMake(100, 100, 200, 200);
//    UIView * bgView = [[UIView alloc] initWithFrame:frames];
//    bgView.backgroundColor = [UIColor lightGrayColor];
//    [self.view addSubview:bgView];
//
//    CGFloat mainWidth = frames.size.width * 0.5;
//
//    CGRect mainFrame = CGRectMake(mainWidth * 0.5, mainWidth * 0.5, mainWidth, mainWidth);
//
//
//    // 外层放大
//    CGRect ringFrame = CGRectInset(mainFrame, -0.6 * mainWidth /2.0, -0.6 * mainWidth /2.0);
//
//    UIBezierPath * ringPath = [UIBezierPath bezierPathWithRoundedRect:ringFrame cornerRadius:ringFrame.size.width / 2.0];
//    CAShapeLayer * ringLayer = [[CAShapeLayer alloc] init];
//    ringLayer.path = ringPath.CGPath;
//    ringLayer.frame = bgView.bounds;
//    ringLayer.fillColor = [UIColor whiteColor].CGColor;
//    [bgView.layer addSublayer:ringLayer];
//
//    // 画中间园
//    UIBezierPath * mainPath = [UIBezierPath bezierPathWithRoundedRect:mainFrame cornerRadius:mainFrame.size.width * 0.5];
//    CAShapeLayer * centerLayer = [[CAShapeLayer alloc] init];
//    centerLayer.path = mainPath.CGPath;
//    centerLayer.frame = bgView.bounds;
//    centerLayer.fillColor = [UIColor redColor].CGColor;
//    [bgView.layer addSublayer:centerLayer];
//
//    // 画圈
//    CGRect progressFrame = CGRectInset(ringFrame,2.0,2.0);
//    UIBezierPath * progressPath = [UIBezierPath bezierPathWithRoundedRect:progressFrame cornerRadius:progressFrame.size.width * 0.5];
//    CAShapeLayer * bLayer = [[CAShapeLayer alloc] init];
//    bLayer.fillColor = [UIColor clearColor].CGColor;
//    bLayer.path = progressPath.CGPath;
//    bLayer.strokeEnd = 1;
//    bLayer.lineWidth = 4;
//    bLayer.frame = bgView.bounds;
//    bLayer.strokeColor = [UIColor colorWithRed:31/255.0 green:185/255.0 blue:34/255.0 alpha:1].CGColor;
//    [bgView.layer addSublayer:bLayer];
    
    
    
    
}



- (void)takeClick {
    TakePhotoViewController * takePhot = [[TakePhotoViewController alloc] init];
    [self.navigationController pushViewController:takePhot animated:YES];
}

- (void)takeVideoClick {
    TakeVideoViewController * takeVideo = [[TakeVideoViewController alloc] init];
    [self.navigationController pushViewController:takeVideo animated:YES];
}

-(void)takeShortVideoClick {
    TakeShortVideoViewController * takeShort = [[TakeShortVideoViewController alloc] init];
    [self.navigationController pushViewController:takeShort animated:YES];
}








@end
