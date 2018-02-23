//
//  TakeVideoViewController.m
//  VideoTake
//
//  Created by zzg on 2018/2/23.
//  Copyright © 2018年 zzg. All rights reserved.
//
#define SW [UIScreen mainScreen].bounds.size.width
#define SH [UIScreen mainScreen].bounds.size.height

#import "TakeVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface TakeVideoViewController ()<AVCaptureFileOutputRecordingDelegate>

/* 管理输入，输出对象的数据传递 */
@property (nonatomic, weak)  AVCaptureSession * captureSession;
/* 获取输入数据，从AVCaptureDevice中获取 */
@property (nonatomic, weak) AVCaptureDeviceInput * captureDeviceInput;
/* 照片输出流 */
@property (nonatomic, weak) AVCaptureMovieFileOutput * captureMovieFileOutput;
/* 相机拍摄预览图层 */
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *captureMovePreviewLayer;


@property (assign,nonatomic) BOOL enableRotation;//是否允许旋转（注意在视频录制过程中禁止屏幕旋转）
@property (assign,nonatomic) CGRect *lastBounds;//旋转的前大小
@property (assign,nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;//后台任务标识

@end

@implementation TakeVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self steupTakePhoto];
    [self initView];
}

- (void)initView {
    self.title = @"拍摄视频";
    /* 拍照 */
    UIButton * takeVideo = [UIButton buttonWithType:UIButtonTypeCustom];
    takeVideo.center = CGPointMake(SW * 0.5, SH - 50);
    takeVideo.bounds = CGRectMake(0, 0, 50, 50);
    [takeVideo setImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
    [takeVideo addTarget:self action:@selector(takeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takeVideo];
    
    /* 转换摄像头 */
    UIButton * takeChange = [UIButton buttonWithType:UIButtonTypeCustom];
    takeChange.frame = CGRectMake(0, takeVideo.frame.origin.y, 50, 50);
    [takeChange setImage:[UIImage imageNamed:@"takeFlash"] forState:UIControlStateNormal];
    [takeChange addTarget:self action:@selector(takeChangeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takeChange];
    
    /* 闪光灯 */
    UIButton * takeFlash = [UIButton buttonWithType:UIButtonTypeCustom];
    takeFlash.frame = CGRectMake(SW - 50, takeVideo.frame.origin.y, 50, 50);
    [takeFlash setImage:[UIImage imageNamed:@"takeLight"] forState:UIControlStateNormal];
    [takeFlash addTarget:self action:@selector(takeFlashClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takeFlash];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.captureSession startRunning];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.captureSession stopRunning];
}



#pragma mark - PRIVATE FUNCATION
/**
 校验手机能否支持摄像功能
 */
- (void)steupTakePhoto {
    //判断权限
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [self takeMovieFileOutput];
            } else {
                NSString *title = @"请在iPhone的”设置-隐私-相机“选项中，允许App访问你的相机";
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
                [alertView show];
            }
        });
    }];
}


/**
 拍照初始化
 */
- (void)takeMovieFileOutput {
    /* 获取后置摄像头 */
    AVCaptureDevice  *captureDevice = [self getCameraDeviceWithPosition:(AVCaptureDevicePositionBack)];
    if (!captureDevice) {
        NSLog(@"获取后置摄像头出现问题");
        return;
    }
    //创建输入流
    NSError *error = nil;
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"获取输入对象流%@",error.localizedDescription);
        return;
    }
    self.captureDeviceInput = captureDeviceInput;
    
    //添加一个音频输入设备
    AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    AVCaptureDeviceInput *audioCaptureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    if (error) {
        NSLog(@"去对象输入出错%@",error.localizedDescription);
        return;
    }
    
    
    // 初始化输出对象
    AVCaptureMovieFileOutput * captureMoveFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    self.captureMovieFileOutput = captureMoveFileOutput;
    
    //初始化链接对象
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {//设置分辨率
        session.sessionPreset=AVCaptureSessionPreset1280x720;
    }
    self.captureSession = session;
    
    //将设备输入添加到会话中
    if ([session canAddInput:captureDeviceInput]) {
        [session addInput:captureDeviceInput];
         [session addInput:audioCaptureDeviceInput];
        
        AVCaptureConnection *captureConnection=[captureMoveFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoStabilizationSupported ]) {
            captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
        }
    }
    
    //将设备输出添加到会话中
    if ([session canAddOutput:captureMoveFileOutput]) {
        [session addOutput:captureMoveFileOutput];
    }
    
    //创建视频预览层，用于实时展示摄像头状态
    AVCaptureVideoPreviewLayer *prewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    prewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    prewLayer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:prewLayer atIndex:0];
    self.captureMovePreviewLayer = prewLayer;
    [session startRunning];
}


/**
 取得指定位置的摄像头
 
 @param position 摄像头位置
 @return 摄像头设备
 */
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}

-(void)takeClick {
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection=[self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    //根据连接取得设备输出的数据
    if (![self.captureMovieFileOutput isRecording]) {
        self.enableRotation=NO;
        //如果支持多任务则则开始多任务
        if ([[UIDevice currentDevice] isMultitaskingSupported]) {
            self.backgroundTaskIdentifier=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
        }
        //预览图层和视频方向保持一致
        captureConnection.videoOrientation=[self.captureMovePreviewLayer connection].videoOrientation;
        NSString *outputFielPath=[NSTemporaryDirectory() stringByAppendingString:@"myMovie.mov"];
        NSLog(@"save path is :%@",outputFielPath);
        NSURL *fileUrl=[NSURL fileURLWithPath:outputFielPath];
        [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
    }
    else{
        [self.captureMovieFileOutput stopRecording];//停止录制
    }
}

//屏幕旋转时调整视频预览图层的方向
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    AVCaptureConnection *captureConnection=[self.captureMovePreviewLayer connection];
    captureConnection.videoOrientation=(AVCaptureVideoOrientation)toInterfaceOrientation;
}
//旋转后重新设置大小
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    self.captureMovePreviewLayer.frame=self.view.bounds;
}



#pragma mark - 视频输出代理
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"开始录制...");
}
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    NSLog(@"视频录制完成.");
    //视频录入完成之后在后台将视频存储到相簿
    self.enableRotation=YES;
    UIBackgroundTaskIdentifier lastBackgroundTaskIdentifier=self.backgroundTaskIdentifier;
    self.backgroundTaskIdentifier=UIBackgroundTaskInvalid;
    ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"保存视频到相簿过程中发生错误，错误信息：%@",error.localizedDescription);
        }
        if (lastBackgroundTaskIdentifier!=UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:lastBackgroundTaskIdentifier];
        }
        NSLog(@"成功保存视频到相簿.");
    }];
    
}

@end
