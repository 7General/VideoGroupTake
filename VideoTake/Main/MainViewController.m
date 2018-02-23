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

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface MainViewController ()
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"拍摄照片";
    
    UIButton * takeVideo = [UIButton buttonWithType:UIButtonTypeCustom];
    takeVideo.frame = CGRectMake(100, 100, 100, 100);
    takeVideo.backgroundColor = [UIColor redColor];
    [takeVideo setTitle:@"拍摄照片" forState:UIControlStateNormal];
    [takeVideo addTarget:self action:@selector(takeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takeVideo];
    
    UIButton * takePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    takePhoto.frame = CGRectMake(100, 200, 100, 100);
    takePhoto.backgroundColor = [UIColor redColor];
    [takePhoto setTitle:@"拍摄视频" forState:UIControlStateNormal];
    [takePhoto addTarget:self action:@selector(takeVideoClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takePhoto];
    
}



- (void)takeClick {
    TakePhotoViewController * takePhot = [[TakePhotoViewController alloc] init];
    [self.navigationController pushViewController:takePhot animated:YES];
}

- (void)takeVideoClick {
    TakeVideoViewController * takeVideo = [[TakeVideoViewController alloc] init];
    [self.navigationController pushViewController:takeVideo animated:YES];
}






@end
