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
