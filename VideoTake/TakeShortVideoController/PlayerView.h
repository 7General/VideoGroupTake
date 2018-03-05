//
//  PlayerView.h
//  VideoTake
//
//  Created by zzg on 2018/3/5.
//  Copyright © 2018年 zzg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface PlayerView : UIView

//- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@property (nonatomic,copy)NSString *URLString;//视频播放地址
@property (nonatomic,copy)NSString *fileURLString;//本地文件地址
@property (nonatomic,copy)NSURL *URL;//url
@property (nonatomic,assign,getter=isMuted) BOOL muted;//静音 default is NO;
@property (nonatomic,assign) BOOL repeat;//default is YES

@property (assign,nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;//后台任务标识


- (void)play;//播放视频
- (void)pause;//暂停播放


@property (nonatomic, assign) AVPlayerStatus  playState;



//
//+ (UIImage *)thumbnailImageWithURLString:(NSString *)URLString;
//+ (UIImage *)thumbnailImageWithFileURLString:(NSString *)fileURLString;
//+ (UIImage *)thumbnailImageWithURL:(NSURL *)URL;

@end
