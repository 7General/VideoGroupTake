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

@interface MainViewController ()<AVCaptureMetadataOutputObjectsDelegate>

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
    
    UIButton * takePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    takePhoto.frame = CGRectMake(100, 200, 100, 100);
    takePhoto.backgroundColor = [UIColor redColor];
    [takePhoto setTitle:@"拍照" forState:UIControlStateNormal];
    [takePhoto addTarget:self action:@selector(takePhotoClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takePhoto];
    
    UIButton * takeChange = [UIButton buttonWithType:UIButtonTypeCustom];
    takeChange.frame = CGRectMake(100, 300, 100, 100);
    takeChange.backgroundColor = [UIColor redColor];
    [takeChange setTitle:@"切换摄像头" forState:UIControlStateNormal];
    [takeChange addTarget:self action:@selector(takeChangeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takeChange];
}


/**
 切换摄像头
 */
-(void)takeChangeClick {
    AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition=AVCaptureDevicePositionFront;
    if (currentPosition==AVCaptureDevicePositionUnspecified||currentPosition==AVCaptureDevicePositionFront) {
        toChangePosition=AVCaptureDevicePositionBack;
    }
    toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
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

-(void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}

/**
 *  给输入设备添加通知
 */
-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
   
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //捕获区域发生改变
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
/**
 *  捕获区域改变
 *
 *  @param notification 通知对象
 */
-(void)areaChange:(NSNotification *)notification{
    NSLog(@"捕获区域改变...");
}


- (void)takePhotoClick {
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection=[self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    //根据连接取得设备输出的数据
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            NSData *imageData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image=[UIImage imageWithData:imageData];
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
        
    }];
}

- (void)takeClick {
    
//    NSLog(@"---------");
//    QRScannViewController * qr = [[QRScannViewController alloc] init];
//    [self.navigationController pushViewController:qr animated:YES];
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
    
    [self takeVideo];
    
}



-(void)takeVideo {
    //判断权限
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                NSLog(@"------AVMediaTypeVideo");
                [self loadScanView];
            } else {
                NSString *title = @"请在iPhone的”设置-隐私-相机“选项中，允许App访问你的相机";
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
                [alertView show];
            }
        });
    }];
}

- (void)loadScanView {
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
        NSLog(@"获取输入对象流时出现问题，%@",error.localizedDescription);
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


@end
