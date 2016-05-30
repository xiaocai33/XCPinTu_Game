//
//  CardImageView.h
//  pintu
//
//  Created by 小蔡 on 16/5/26.
//  Copyright © 2016年 xiaocai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardImageView : UIImageView
/** 正确的位置 */
@property(nonatomic, assign) int rightIndexI;
@property(nonatomic, assign) int rightIndexJ;
/** 实际的位置 */
@property(nonatomic, assign) int indexI;
@property(nonatomic, assign) int indexJ;

/** 根据cardIamgeView的IJ,设置cardIamgeView的位置 */
- (void)resetPositionByIndexIJ;

/** 检测屏图是否完成 */
- (BOOL)onRightLocation;

/**
 *  将图片移动到固定的frame处
 */
- (void)moveToPositionByIndexIJ;

@end
