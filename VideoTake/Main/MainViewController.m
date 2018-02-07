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

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);
@interface MainViewController ()



/* 管理输入，输出对象的数据传递 */
@property (nonatomic, strong)  AVCaptureSession * captureSession;
/* 获取输入数据，从AVCaptureDevice中获取 */
@property (nonatomic, strong) AVCaptureDeviceInput * captureDeviceInput;
/* 照片输出流 */
@property (nonatomic, strong) AVCaptureStillImageOutput * captureStillImageOutput;
/* 相机拍摄预览图层 */
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@property (weak, nonatomic)  UIView *viewContainer;
/* 拍照按钮 */
@property (weak, nonatomic)  UIButton *takeButton;
/* 自动闪光灯按钮 */
@property (weak, nonatomic)  UIButton *flashAutoButton;
/* 打开闪光灯按钮 */
@property (weak, nonatomic)  UIButton *flashOnButton;
/* 关闭闪光灯按钮 */
@property (weak, nonatomic)  UIButton *flashOffButton;
/* 聚焦光标 */
@property (weak, nonatomic)  UIImageView *focusCursor;
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
}



- (void)takeClick {
    
    NSLog(@"---------");
    QRScannViewController * qr = [[QRScannViewController alloc] init];
    [self.navigationController pushViewController:qr animated:YES];
    /**
     使用AVFoundation拍照和录制视频的一般步骤如下：
     
     创建AVCaptureSession对象。
     使用AVCaptureDevice的静态方法获得需要使用的设备，例如拍照和录像就需要获得摄像头设备，录音就要获得麦克风设备。
     利用输入设备AVCaptureDevice初始化AVCaptureDeviceInput对象。
     初始化输出数据管理对象，如果要拍照就初始化AVCaptureStillImageOutput对象；如果拍摄视频就初始化AVCaptureMovieFileOutput对象。
     将数据输入对象AVCaptureDeviceInput、数据输出对象AVCaptureOutput添加到媒体会话管理对象AVCaptureSession中。
     创建视频预览图层AVCaptureVideoPreviewLayer并指定媒体会话，添加图层到显示容器中，调用AVCaptureSession的startRuning方法开始捕获。
     将捕获的音频或视频数据输出到指定文件。
     */
}


@end
