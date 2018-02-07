//
//  QRScannViewController.h
//  VideoTake
//
//  Created by zzg on 2018/2/6.
//  Copyright © 2018年 zzg. All rights reserved.
//

#import <UIKit/UIKit.h>


@class GZIMQRScannerController;

@protocol GZIMQRScannerDelegate <NSObject>
@optional
-(void)QRScannCode:(GZIMQRScannerController *)QRSannerVC withResoult:(NSString *)value;

@end

typedef NS_ENUM(NSInteger, QRCodeScannerType) {
    QRCodeScannerTypeAll = 0,   //扫描二维码、条形码
    QRCodeScannerTypeQRCode,    //只扫描二维码
    QRCodeScannerTypeBarcode,   //只扫描条形码
};


@interface QRScannViewController : UIViewController
@property (nonatomic, assign) QRCodeScannerType scanType;
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *tipStr;
@property (nonatomic, copy) void(^resultBlock)(NSString *value);
@property (nonatomic, weak) id<GZIMQRScannerDelegate>  scannerDelegate;


@end
