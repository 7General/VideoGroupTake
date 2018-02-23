//
//  TakePhotoViewController.m
//  VideoTake
//
//  Created by zzg on 2018/2/23.
//  Copyright © 2018年 zzg. All rights reserved.
//


#define SW [UIScreen mainScreen].bounds.size.width
#define SH [UIScreen mainScreen].bounds.size.height

#import "TakePhotoViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface TakePhotoViewController ()

/* 管理输入，输出对象的数据传递 */
@property (nonatomic, weak)  AVCaptureSession * captureSession;
/* 获取输入数据，从AVCaptureDevice中获取 */
@property (nonatomic, weak) AVCaptureDeviceInput * captureDeviceInput;
/* 照片输出流 */
@property (nonatomic, weak) AVCaptureStillImageOutput * captureStillImageOutput;
@property (nonatomic, assign) BOOL  flashState;
@end

@implementation TakePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self steupTakePhoto];
    [self initView];
}
- (void)initView {
    self.title = @"拍照";
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

/**
 闪光灯
 */
- (void)takeFlashClick {
    self.flashState = !self.flashState;
    [self setFlashMode:AVCaptureFlashModeOn];
}

/**
 拍照事件
 */
- (void)takeClick {
    AVCaptureConnection *captureConnection=[self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            NSData *imageData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image=[UIImage imageWithData:imageData];
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
    }];
}

/**
 转换摄像头
 */
- (void)takeChangeClick {
    AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    /* 新设备名称 */
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition=AVCaptureDevicePositionFront;
    if (currentPosition==AVCaptureDevicePositionUnspecified||currentPosition==AVCaptureDevicePositionFront) {
        toChangePosition=AVCaptureDevicePositionBack;
    }
    toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    
    //创建输入流
    NSError *error = nil;
    AVCaptureDeviceInput *toChangeDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:toChangeDevice error:&error];
    if (error) {
        NSLog(@"获取输入对象流%@",error.localizedDescription);
        return;
    }
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.captureSession beginConfiguration];
    //移除原有输入对象
    [self.captureSession removeInput:self.captureDeviceInput];
    //添加新的输入对象
    if ([self.captureSession canAddInput:toChangeDeviceInput]) {
        [self.captureSession addInput:toChangeDeviceInput];
        self.captureDeviceInput=toChangeDeviceInput;
    }
    //提交会话配置
    [self.captureSession commitConfiguration];
}

#pragma mark - VIEW LIFE
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.captureSession startRunning];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
                [self takePhotoStillImageOutput];
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
- (void)takePhotoStillImageOutput {
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
    
    
    // 初始化输出对象
    AVCaptureStillImageOutput * captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary * outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    // 设置图片格式
    captureStillImageOutput.outputSettings = outputSettings;
    self.captureStillImageOutput = captureStillImageOutput;
    
    
    //初始化链接对象
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {//设置分辨率
        session.sessionPreset=AVCaptureSessionPreset1280x720;
    }
    self.captureSession = session;
    
    //将设备输入添加到会话中
    if ([session canAddInput:captureDeviceInput]) {
        [session addInput:captureDeviceInput];
    }
    
    //将设备输出添加到会话中
    if ([session canAddOutput:captureStillImageOutput]) {
        [session addOutput:captureStillImageOutput];
    }
    
    //创建视频预览层，用于实时展示摄像头状态
    AVCaptureVideoPreviewLayer *prewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    prewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    prewLayer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:prewLayer atIndex:0];
    
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
/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
// AVCaptureDevice *captureDevice
-(void)changeDeviceProperty:(void(^)(AVCaptureDevice *captureDevice))propertyChange{
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

/**
 *  设置闪光灯模式
 *  @param flashMode 闪光灯模式
 */
-(void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}

@end

