//
//  WMCWaterMarkManager.h
//  WaterMarkCamera
//
//  Created by 呛人的黑 on 2022/8/20.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMCWaterMarkManager : NSObject

/// 截取水印
+ (UIImage *)screenshotWithView:(UIView *)markView;

/// 视频添加静态水印
+ (void)addWaterMarkTypeWithVideoAsset:(AVURLAsset *)videoAsset
                                 markViews:(NSArray <UIView *> *)markViews
                               markBgViews:(NSArray <UIView *> *)markBgViews
                              cameraBgView:(UIView *)cameraBgView
                         completionHandler:(void (^)(NSURL* _Nullable outPutURL))handler;
@end

NS_ASSUME_NONNULL_END
