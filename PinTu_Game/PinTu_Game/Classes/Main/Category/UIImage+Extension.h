//
//  UIImage+Extension.h
//  PinTu_Game
//
//  Created by 小蔡 on 16/5/30.
//  Copyright © 2016年 xiaocai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)
/**
 *  等比例伸缩
 */
- (UIImage *)scale:(float)scaleSize;
/**
 *  设置宽高
 */
- (UIImage *)reSize:(CGSize)reSize;
@end
