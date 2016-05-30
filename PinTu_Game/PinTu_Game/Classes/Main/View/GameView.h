//
//  GameView.h
//  pintu
//
//  Created by 小蔡 on 16/5/26.
//  Copyright © 2016年 xiaocai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameView : UIView
/** 图片 */
@property (nonatomic, strong) UIImage *image;

/** 数组乱序(打乱每个card) */
- (void)resetCardImages;
@end
