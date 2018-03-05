//
//  PlayerView.m
//  VideoTake
//
//  Created by zzg on 2018/3/5.
//  Copyright © 2018年 zzg. All rights reserved.
//

#import "PlayerView.h"

@interface PlayerView()

@property (nonatomic, strong)AVPlayer *player;//播放器
@property (nonatomic, strong)AVPlayerItem *playerItem;//playerItem

@end

@implementation PlayerView

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    _repeat = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(playbackFinished:)
                                                name:AVPlayerItemDidPlayToEndTimeNotification
                                              object:self.player.currentItem];
}

#pragma mark -- setPlayerItem dataSource
- (void)setURLString:(NSString *)URLString{
    _URLString = URLString;
    self.URL = [NSURL URLWithString:_URLString];
}

- (void)setFileURLString:(NSString *)fileURLString{
    _fileURLString = fileURLString;
    self.URL = [NSURL fileURLWithPath:_fileURLString];
}

- (void)setURL:(NSURL *)URL{
    _URL = URL;
    self.playerItem = [AVPlayerItem playerItemWithURL:_URL];
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem{
    _playerItem = playerItem;
    if (_playerItem) {
        if (!self.player) {
            self.player = [AVPlayer playerWithPlayerItem:_playerItem];
            AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            playerLayer.frame = self.bounds;
            [self.layer addSublayer:playerLayer];
        } else {
            [self.player replaceCurrentItemWithPlayerItem:_playerItem];
        }
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [session setActive:YES error:nil];
        
        self.player.muted = _muted;
        [self play];
    }
}

#pragma mark -- player control
- (void)setMuted:(BOOL)muted{
    _muted = muted;
    if (self.player) {
        self.player.muted = muted;
    }
}

- (void)play{
    if (self.player) {
        [self.player play];
    }
}
- (void)pause{
    if (self.player) {
        [self.player pause];
    }
}

- (AVPlayerStatus)playState {
    return self.player.status;
}

- (void)playbackFinished:(NSNotification *)notify{
    
    if (_repeat && self.player) {
        [self.player seekToTime:CMTimeMakeWithSeconds(0, 10)
              completionHandler:^(BOOL finished) {
                  [self play];
              }];
    }
}


#pragma mark -- class method
//+ (UIImage *)thumbnailImageWithURLString:(NSString *)URLString{
//    return [self thumbnailImageWithURL:[NSURL URLWithString:URLString]];
//}
//
//+ (UIImage *)thumbnailImageWithFileURLString:(NSString *)fileURLString{
//    return [self thumbnailImageWithURL:[NSURL fileURLWithPath:fileURLString]];
//}
//
//+ (UIImage *)thumbnailImageWithURL:(NSURL *)URL{
//    return [self thumbnailImageWithURL:URL time:1];
//}
//
//+ (UIImage *)thumbnailImageWithURL:(NSURL *)URL time:(CGFloat)timeBySecond{
//    //根据url创建AVURLAsset
//    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:URL];
//    //根据AVURLAsset创建AVAssetImageGenerator
//    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator
//                                             assetImageGeneratorWithAsset:urlAsset];
//    /*截图
//     * requestTime:缩略图创建时间
//     * actualTime:缩略图实际生成的时间
//     */
//    NSError *error = nil;
//    CMTime time = CMTimeMakeWithSeconds(timeBySecond, 10);//CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
//    CMTime actualTime;
//    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time
//                                                actualTime:&actualTime
//                                                     error:&error];
//    if(error){
//        NSLog(@"截取视频缩略图时发生错误，错误信息：%@",error.localizedDescription);
//        return nil;
//    }
//    CMTimeShow(actualTime);
//    UIImage *image = [UIImage imageWithCGImage:cgImage];//转化为UIImage
//    CGImageRelease(cgImage);
//    return image;
//}

@end
