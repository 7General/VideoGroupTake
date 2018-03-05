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
#import "TakePressButton.h"
#import "RecordToolBar.h"
#import "PlayerView.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface TakeShortVideoViewController ()<AVCaptureFileOutputRecordingDelegate,RecordToolBarDelegate>

/* 管理输入，输出对象的数据传递 */
@property (nonatomic, weak)  AVCaptureSession * captureSession;
/* 获取输入数据，从AVCaptureDevice中获取 */
@property (nonatomic, weak) AVCaptureDeviceInput * captureDeviceInput;
/* 照片输出流 */
@property (nonatomic, weak) AVCaptureMovieFileOutput * captureMovieFileOutput;
/* 相机拍摄预览图层 */
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *captureMovePreviewLayer;

/**
 Target resolution for video files (data output used)，default is 320*240
 */
@property (nonatomic,strong,nonnull)NSString * targetSize;

@property (nonatomic, strong) PlayerView * playerView;


@property (assign,nonatomic) BOOL enableRotation;//是否允许旋转（注意在视频录制过程中禁止屏幕旋转）
@property (assign,nonatomic) CGRect *lastBounds;//旋转的前大小
@property (assign,nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;//后台任务标识


@property (nonatomic, strong) AVPlayer * player;
@end

@implementation TakeShortVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    self.title = @"拍摄短视频";
    
    NSString * path1 = [[NSBundle mainBundle] pathForResource:@"123.mp4" ofType:nil];
    AVPlayerItem*playerItem=[AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:path1]];
    self.player= [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = self.view.bounds;
    self.player.muted = YES;
    [self.view.layer addSublayer:playerLayer];
    [self.player play];
//
//    self.playerView = [[PlayerView alloc]initWithFrame:self.view.bounds];
//    self.playerView.muted = YES;
//    [self.view insertSubview:self.playerView atIndex:1];

//    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:path1]];
//    self.player = [AVPlayer playerWithPlayerItem:playerItem];
//    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//    playerLayer.frame = self.view.bounds;
//    [self.view.layer addSublayer:playerLayer];
//    [self.player play];
    
    
    
//
    NSString * path = [[NSBundle mainBundle] pathForResource:@"123.mp4" ofType:nil];
    NSURL * url = [NSURL fileURLWithPath:path];
    [self prepareToPublishWithFileURL:url];
//
//
//
    return;
    
    self.targetSize = AVAssetExportPreset640x480;
    [self steupTakePhoto];
    
    RecordToolBar * toolBar = [[RecordToolBar alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT - 180, SCREENWIDTH, 180)];
    toolBar.delegate = self;
    [self.view addSubview:toolBar];
    __weak typeof(self) WeakSelf = self;
    [toolBar setButtonAction:^(LDPressButtonState state) {
                switch (state) {
                    case Begin:
                        NSLog(@"-------begin");
                        [WeakSelf startRecorder];
                        break;
                    case Moving:
                        NSLog(@"-------moving");
                        break;
                    case WillCancle:
                        NSLog(@"-------WillCancle");
                        break;
                    case DidCancle:
                        NSLog(@"-------DidCancle");
                        [WeakSelf startRecorder];
                        break;
                    case End:
                        NSLog(@"-------End");
                        [WeakSelf startRecorder];
                        break;
                    case Click:
                        NSLog(@"-------Click");
                        break;
                    default:
                        break;
                }
    }];
}

#pragma mark - recordDelegate

/**
 重新拍摄
 */
-(void)reMakeVideo {
    [self.playerView removeFromSuperview];
    self.playerView = nil;
    if (!self.captureSession.isRunning) {
        [self.captureSession startRunning];
    }
}

/**
 完成，上传录像
 */
- (void)finishTakeVideo {
    
}


/**
 开始录像
 */
- (void)startRecorder {
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection=[self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    //根据连接取得设备输出的数据
    if (![self.captureMovieFileOutput isRecording]) {
        //预览图层和视频方向保持一致
        captureConnection.videoOrientation=[self.captureMovePreviewLayer connection].videoOrientation;
        NSURL * fileUrl = [NSURL fileURLWithPath:[self tempFilePath]];
        [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
    }
    else{
        [self.captureMovieFileOutput stopRecording];//停止录制
    }
}

/**
 停止录像
 */
- (void)stopRecorder {
    [self.captureMovieFileOutput stopRecording];//停止录制
}


//-(void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    if (self.captureSession) {
//        [self.captureSession startRunning];
//    }
//}
//
//-(void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    if (self.captureSession) {
//        [self.captureSession stopRunning];
//    }
//}

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



#pragma mark - AVCaptureFileOutput delegate

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"开始录制...URL = %@",fileURL);
}
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    if (outputFileURL.absoluteString.length == 0 && captureOutput.outputFileURL.absoluteString.length == 0) {
        return;
    }
    NSLog(@"视频录制结束.-->outputFileURL:%@",outputFileURL);
    // 压缩视频
    [self cropVideoWithFilrURL:(outputFileURL)];
    
}
- (CGFloat)fileSize:(NSURL *)path {
    return [[NSData dataWithContentsOfURL:path] length]/1024.00 /1024.00;
}
// 获取保存路径
- (NSString *)tempFilePath {
    NSString *outputFileDir = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/Library/tempVideo"];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:outputFileDir isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)){
        [fileManager createDirectoryAtPath:outputFileDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
//    NSString *filePath = [NSString stringWithFormat:@"%@/%@%@",outputFileDir,[[NSDate date].description stringByReplacingOccurrencesOfString:@" " withString:@"_"],@".mov"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",outputFileDir,@"mymv.mov"];
    return filePath;
}

// 文件输出路径
- (NSString *)outputFilePath {
    NSString *outputFileDir = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/Library/outputVideo"];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:outputFileDir isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)){
        [fileManager createDirectoryAtPath:outputFileDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [NSString stringWithFormat:@"%@/%@%@",outputFileDir,[[NSDate date].description stringByReplacingOccurrencesOfString:@" " withString:@"_"],@".mp4"];
    return filePath;
}
// 删除生成的文件
- (BOOL)deleteVideoFileWithFileURL:(NSURL *)fileURL{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL.absoluteString substringFromIndex:7]]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:[fileURL.absoluteString substringFromIndex:7] error:&error];
        if (!error) {
            NSLog(@"delete success");
            return YES;
        } else {
            NSLog(@"delete error: %@",error);
            return NO;
        }
    }
    NSLog(@"delete file does not exist");
    return NO;
}


#pragma mark -- crop video （压缩视频）
- (void)cropVideoWithFilrURL:(NSURL *)fileURL {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[fileURL.absoluteString substringFromIndex:7]]){
        return;
    }
    
    NSLog(@"开始压缩,压缩前大小 %f MB",[self fileSize:fileURL]);
    AVAsset *asset = [AVAsset assetWithURL:fileURL];
    AVMutableVideoComposition *videoComposition;

    NSLog(@"视频分辨率 ： %@",self.targetSize);
    // export
    NSString *outputFilePath = [self outputFilePath];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset
                                                                      presetName:_targetSize];
    //优化网络
    exporter.shouldOptimizeForNetworkUse = true;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.videoComposition = videoComposition;
    exporter.outputURL = [NSURL fileURLWithPath:outputFilePath];
    
    [exporter exportAsynchronouslyWithCompletionHandler:^(void){
        // 如果导出的状态为完成
        if ([exporter status] == AVAssetExportSessionStatusCompleted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //回放
                [self prepareToPublishWithFileURL:[NSURL fileURLWithPath:outputFilePath]];
                NSLog(@"---文件最终路径%@",outputFilePath);
                [self writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:outputFilePath]];
                NSLog(@"压缩完毕,压缩后大小 %f MB",[self fileSize:[NSURL fileURLWithPath:outputFilePath]]);
            });
//            [self deleteVideoFileWithFileURL:fileURL];
            NSLog(@"Export done!");
        }
    }];
}

- (void)prepareToPublishWithFileURL:(NSURL *)fileURL{
    self.playerView = [[PlayerView alloc]initWithFrame:self.view.bounds];
    self.playerView.muted = YES;
    [self.view insertSubview:self.playerView atIndex:1];
    self.playerView.URL = fileURL;
}

/**
 把视频存入相册

 @param outputFileURL 视频输出路劲
 */
- (void)writeVideoAtPathToSavedPhotosAlbum:(NSURL *) outputFileURL {
    //视频录入完成之后在后台将视频存储到相簿
    ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"保存视频到相簿过程中发生错误，错误信息：%@",error.localizedDescription);
        }
        NSLog(@"成功保存视频到相簿.");
    }];
}




@end

