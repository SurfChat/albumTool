//
//  WMCWaterMarkManager.m
//  WaterMarkCamera
//
//  Created by 呛人的黑 on 2022/8/20.
//

#import "WMCWaterMarkManager.h"


@implementation WMCWaterMarkManager

// 截取水印
+ (UIImage *)screenshotWithView:(UIView *)markView {
    UIGraphicsBeginImageContextWithOptions(markView.bounds.size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (context == NULL)
    {
        return nil;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, -markView.bounds.origin.x, -markView.bounds.origin.y);
    [markView snapshotViewAfterScreenUpdates:YES];
    [markView.layer renderInContext:context];
    
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


+ (void)addWaterMarkTypeWithVideoAsset:(AVURLAsset *)videoAsset markViews:(NSArray <UIView *> *)markViews markBgViews:(NSArray <UIView *> *)markBgViews cameraBgView:(UIView *)cameraBgView completionHandler:(void (^)(NSURL* _Nullable outPutURL))handler {
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                        ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject]
                         atTime:kCMTimeZero error:nil];
    //2 音频通道
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio                                         preferredTrackID:kCMPersistentTrackID_Invalid];
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                        ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject]
                         atTime:kCMTimeZero error:nil];
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize naturalSize = videoAssetTrack.naturalSize;
    
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [videolayerInstruction setOpacity:0.0 atTime:videoAsset.duration];
    // 修改视频方向
    CGAffineTransform mixedTransform = CGAffineTransformIdentity;
    
    mixedTransform = CGAffineTransformTranslate(mixedTransform, naturalSize.height, 0);
    mixedTransform = CGAffineTransformRotate(mixedTransform, M_PI_2);
    
    [videolayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
    
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    
    float renderWidth, renderHeight;
    renderWidth = naturalSize.height;
    renderHeight = naturalSize.width;
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    
    [self applyVideoEffectsToComposition:mainCompositionInst size:CGSizeMake(renderWidth, renderHeight) markViews:markViews markBgViews:markBgViews cameraBgView:cameraBgView];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"FinalVideo-%f.mp4",[NSDate date].timeIntervalSince1970]];
    NSURL* videoUrl = [NSURL fileURLWithPath:myPathDocs];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition     presetName:AVAssetExportPreset1920x1080];
    exporter.outputURL = videoUrl;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if( exporter.status == AVAssetExportSessionStatusCompleted ){
                handler(videoUrl);
            }else if( exporter.status == AVAssetExportSessionStatusFailed )
            {
                handler(nil);
            }
        });
    }];
}

+ (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size markViews:(NSArray <UIView *> *)markViews  markBgViews:(NSArray <UIView *> *)markBgViews cameraBgView:(UIView *)cameraBgView {
    
    CALayer *overlayLayer = [CALayer layer];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    for (int i = 0; i < markBgViews.count; ++i) {
        UIImage *big = [self screenshotWithView:markViews[i]];
        UIView *markView = markBgViews[i];
        // 当前缩放比例
        CGFloat currentScale = [[markView.layer valueForKeyPath:@"transform.scale"] floatValue];
        // 换算尺寸 水印宽高在页面中的比例 换算在视频中的尺寸
        CGFloat wScale = size.width / cameraBgView.bounds.size.width;
        CGFloat hScale = size.height / cameraBgView.bounds.size.height;
        // 需要乘上缩放比例 因为缩放不改变bounds
        CGFloat layerW = markView.bounds.size.width * wScale * currentScale;
        CGFloat layerH = markView.bounds.size.height * hScale * currentScale;
        
        // x y 与页面宽高的比例 换算在视频的位置
        CGFloat xScale = markView.frame.origin.x / markView.superview.bounds.size.width;
        CGFloat yScale = markView.frame.origin.y / markView.superview.bounds.size.height;
        
        CGFloat layerX = size.width*xScale;
        // 因为视图做了旋转 所以y要取反
        CGFloat layerY = size.height*(1-yScale) - layerH;
        
        //图片
        CALayer*picLayer = [CALayer layer];
        picLayer.contents = (id)big.CGImage;
        picLayer.frame = CGRectMake(layerX, layerY, layerW, layerH);

        [overlayLayer addSublayer:picLayer];
    }

    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

@end
