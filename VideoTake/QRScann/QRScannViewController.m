//
//  QRScannViewController.m
//  VideoTake
//
//  Created by zzg on 2018/2/6.
//  Copyright © 2018年 zzg. All rights reserved.
//

#define SCREEN_WIDTH          [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT         [UIScreen mainScreen].bounds.size.height

#import "QRScannViewController.h"
#import "UIView+Addition.h"

#import <AVFoundation/AVFoundation.h>


@interface QRScannViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, assign) BOOL isReading;

@property (nonatomic, assign) UIStatusBarStyle originStatusBarStyle;

@property (nonatomic, strong) UIImageView *lineImageView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong) UIImageView * scanView;
/**
 *  记录开始的缩放比例
 */
@property(nonatomic,assign)CGFloat beginGestureScale;

/**
 *  最后的缩放比例
 */
@property(nonatomic,assign)CGFloat effectiveScale;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *prewLayer;
@property (nonatomic, strong) AVCaptureDevice *deviceInput;
@end

@implementation QRScannViewController

- (id)init {
    self = [super init];
    if (self) {
        self.scanType = QRCodeScannerTypeAll;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)dealloc {
    _session = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadCustomView];
    [self setUpGesture];
    self.effectiveScale = self.beginGestureScale = 1.0f;
    //判断权限
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [self loadScanView];
                [self startRunning];
            } else {
                NSString *title = @"请在iPhone的”设置-隐私-相机“选项中，允许App访问你的相机";
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
                [alertView show];
            }
            
        });
    }];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
#pragma clang diagnostic pop
    NSString *codeStr = @"";
    switch (_scanType) {
        case QRCodeScannerTypeAll: codeStr = @"二维码/条码"; break;
        case QRCodeScannerTypeQRCode: codeStr = @"二维码"; break;
        case QRCodeScannerTypeBarcode: codeStr = @"条码"; break;
        default: break;
    }
    
    //    //title
    //    if (self.titleStr && self.titleStr.length > 0) {
    //        self.titleLabel.text = self.titleStr;
    //    } else {
    //        self.titleLabel.text = codeStr;
    //    }
    
    //tip
    //    if (self.tipStr && self.tipStr.length > 0) {
    //        self.tipLabel.text = self.tipStr;
    //    } else {
    //        self.tipLabel.text= [NSString stringWithFormat:@"将%@放入框内，即可自动识别", codeStr];
    //    }
    self.tipLabel.text = @"将二维码放入框内即可自动识别";
    
    
    [self startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarStyle:self.originStatusBarStyle animated:YES];
#pragma clang diagnostic pop
    [self stopRunning];
    
    [super viewWillDisappear:animated];
}

- (void)loadScanView {
    //获取摄像设备
    self.deviceInput = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    //摄像头判断
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.deviceInput error:&error];
    if (error) {
        NSLog(@"不支持该设备的扫描功能!!");
        [self pressBackButton];
        return;
    }
    
    //创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    // 设置扫描区域
//    output.rectOfInterest = CGRectMake(
//                                       (self.view.height - 270) * 0.5 / self.view.height,
//                                       (self.view.width - 270) * 0.5 / self.view.width,
//                                       270 / self.view.height,
//                                       270 / self.view.width);
    
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //初始化链接对象
    self.session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self.session addInput:input];
    [self.session addOutput:output];
    
    //设置扫码支持的编码格式
    switch (self.scanType) {
        case QRCodeScannerTypeAll:
            output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,
                                         AVMetadataObjectTypeEAN13Code,
                                         AVMetadataObjectTypeEAN8Code,
                                         AVMetadataObjectTypeUPCECode,
                                         AVMetadataObjectTypeCode39Code,
                                         AVMetadataObjectTypeCode39Mod43Code,
                                         AVMetadataObjectTypeCode93Code,
                                         AVMetadataObjectTypeCode128Code,
                                         AVMetadataObjectTypePDF417Code];
            break;
            
        case QRCodeScannerTypeQRCode:
            output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode];
            break;
            
        case QRCodeScannerTypeBarcode:
            output.metadataObjectTypes=@[AVMetadataObjectTypeEAN13Code,
                                         AVMetadataObjectTypeEAN8Code,
                                         AVMetadataObjectTypeUPCECode,
                                         AVMetadataObjectTypeCode39Code,
                                         AVMetadataObjectTypeCode39Mod43Code,
                                         AVMetadataObjectTypeCode93Code,
                                         AVMetadataObjectTypeCode128Code,
                                         AVMetadataObjectTypePDF417Code];
            break;
            
        default:
            break;
    }
    self.prewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.prewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.prewLayer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:self.prewLayer atIndex:0];
    
    
    
}


/**
 *  添加点按手势，点按时聚焦
 */
-(void)addGenstureRecognizer{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self.scanView addGestureRecognizer:tapGesture];
}

-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point= [tapGesture locationInView:self.scanView];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint= [self.prewLayer captureDevicePointOfInterestForPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}


-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    AVCaptureDevice *captureDevice = [[AVCaptureDeviceInput deviceInputWithDevice:self.deviceInput error:nil] device];
    
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
    
}

- (void)loadCustomView {
    self.view.backgroundColor = [UIColor blackColor];
    CGRect rc = [[UIScreen mainScreen] bounds];
    
    CGFloat alpha = 0.3;
    
    //中间扫描区域
    UIImageView *scanCropView=[[UIImageView alloc] init];
    scanCropView.center = CGPointMake(self.view.centerX, self.view.centerY);
    scanCropView.bounds = CGRectMake(0, 0, 270, 270);
    scanCropView. backgroundColor =[ UIColor clearColor];
    scanCropView.userInteractionEnabled = YES;
    [ self.view addSubview :scanCropView];
    self.scanView = scanCropView;
    
    [self addGenstureRecognizer];
    
    _height = scanCropView.width;
    //最上部view
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rc.size.width, (self.view.height - scanCropView.height) * 0.5)];
    upView.alpha = alpha;
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    
    //左侧的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, scanCropView.top, (self.view.width -scanCropView.width) * 0.5, scanCropView.height)];
    leftView.alpha = alpha;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    
    //右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(scanCropView.right, scanCropView.top, (self.view.width -scanCropView.width) * 0.5, scanCropView.height)];
    rightView.alpha = alpha;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    
    //底部view
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, scanCropView.bottom, rc.size.width, (self.view.height - scanCropView.height) * 0.5)];
    downView.alpha = alpha;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    
    //四个边角
    CGFloat spaceOffset = 5;
    UIImage *cornerImage = [UIImage imageNamed:@"QRCodeTopLeft"];
    
    //左侧的view
    UIImageView *leftView_image = [[UIImageView alloc] initWithFrame:CGRectMake(scanCropView.frame.origin.x ,scanCropView.frame.origin.y, cornerImage.size.width, cornerImage.size.height)];
    leftView_image.image = cornerImage;
    [self.view addSubview:leftView_image];
    cornerImage = [UIImage imageNamed:@"QRCodeTopRight"];
    
    //右侧的view
    UIImageView *rightView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(scanCropView.frame) - cornerImage.size.width, scanCropView.frame.origin.y, cornerImage.size.width, cornerImage.size.height)];
    rightView_image.image = cornerImage;
    [self.view addSubview:rightView_image];
    cornerImage = [UIImage imageNamed:@"QRCodebottomLeft"];
    
    //底部view
    UIImageView *downView_image = [[UIImageView alloc] initWithFrame:CGRectMake(scanCropView.frame.origin.x,CGRectGetMaxY(scanCropView.frame) - cornerImage.size.height, cornerImage.size.width, cornerImage.size.height)];
    downView_image.image = cornerImage;
    [self.view addSubview:downView_image];
    
    cornerImage = [UIImage imageNamed:@"QRCodebottomRight"];
    
    UIImageView *downViewRight_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage.size.width, CGRectGetMinY(downView.frame) - cornerImage.size.height , cornerImage.size.width, cornerImage.size.height)];
    downViewRight_image.image = cornerImage;
    [self.view addSubview:downViewRight_image];
    
    //用于说明的label
    self.tipLabel= [[UILabel alloc] init];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.backgroundColor = [UIColor clearColor];
    self.tipLabel.frame=CGRectMake(0, self.scanView.bottom + 20, rc.size.width, 20);
    self.tipLabel.numberOfLines = 0;
    self.tipLabel.textColor= [UIColor whiteColor];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [self.view addSubview:self.tipLabel];
    
    //画中间的基准线
    self.lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake (scanCropView.left, scanCropView.top, scanCropView.width, 4)];
    self.lineImageView.image = [UIImage imageNamed:@"QRCodeLine"];
    [self.view addSubview:self.lineImageView];
    
    UIView * navigation = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    navigation.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:navigation];
    
    
    //标题
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, rc.size.width - 50 - 50, 44)];
    self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"扫一扫";
    [navigation addSubview:self.titleLabel];
    
    
    //返回
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"wq_code_scanner_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(pressBackButton) forControlEvents:UIControlEventTouchUpInside];
    [navigation addSubview:backButton];
}

- (void)startRunning {
    if (self.session) {
        _isReading = YES;
        [self.session startRunning];
        _timer=[NSTimer scheduledTimerWithTimeInterval:1.0/50 target:self selector:@selector(moveUpAndDownLine) userInfo:nil repeats: YES];
    }
}

- (void)stopRunning {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil ;
    }
    
    [self.session stopRunning];
}

- (void)pressBackButton {
    UINavigationController * nvc =self.navigationController;
    if (nvc) {
        if (nvc.viewControllers.count == 1) {
            [nvc dismissViewControllerAnimated:YES completion:nil];
        } else {
            [nvc popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


//二维码的横线移动
- (void)moveUpAndDownLine {
    CGRect frame = self.lineImageView.frame;
    
    if (frame.origin.y >= _height + (self.view.height - _height) * 0.5 - 4) {
        
    }else {
        [UIView animateWithDuration:1.5 animations:^{
            CGRect frame = self.lineImageView.frame;
            frame.origin.y  = _height + (self.view.height - _height) * 0.5 - 4;
            self.lineImageView.frame = frame;
        } completion:^(BOOL finished) {
            CGRect frame = self.lineImageView.frame;
            frame.origin.y = (self.view.height - _height) * 0.5 + 5;
            self.lineImageView.frame = frame;
        }];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (!_isReading) {
        return;
    }
    if (metadataObjects.count > 0) {
        _isReading = NO;
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        NSString *result = metadataObject.stringValue;
        
        if (self.resultBlock) {
            self.resultBlock(result?:@"");
        }
        [self.navigationController popToRootViewControllerAnimated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
        });
    }
}

- (void)setUpGesture {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
}

//缩放手势 用于调整焦距
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.view];
        CGPoint convertedLocation = [self.prewLayer convertPoint:location fromLayer:self.prewLayer.superlayer];
        if ( ! [self.prewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    if (allTouchesAreOnThePreviewLayer) {
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        
        
        //5.f为写死的最大放大倍数
        if (self.effectiveScale > 5.f) {
            self.effectiveScale = 5.f;
        }
    }
    
    NSError *error = nil;
    [self.deviceInput lockForConfiguration:&error];
    if (!error) {
        self.deviceInput.videoZoomFactor = self.effectiveScale;
//        [self.deviceInput rampToVideoZoomFactor:self.effectiveScale withRate:10];
    }else{
        NSLog(@"error = %@", error);
    }
    [self.deviceInput unlockForConfiguration];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}

@end
