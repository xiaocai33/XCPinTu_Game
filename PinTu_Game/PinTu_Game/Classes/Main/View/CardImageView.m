//
//  CardImageView.m
//  pintu
//
//  Created by 小蔡 on 16/5/26.
//  Copyright © 2016年 xiaocai. All rights reserved.
//

#import "CardImageView.h"
#import "const.h"
#import "UIView+Extension.h"

@interface CardImageView()

@end


@implementation CardImageView

- (instancetype)initWithImage:(UIImage *)image{
    self = [super initWithImage:image];
    if (self) {
        [self setFrame:CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT)];
    }
    return self;
}
/**
 *  初始化设置图片的frame
 */
- (void)resetPositionByIndexIJ{
    self.x= self.indexJ * CARD_WIDTH;
    self.y= self.indexI * CARD_HEIGHT;
}
/**
 *  判断图片是否在正确的位置
 */
- (BOOL)onRightLocation{
    return self.indexI == self.rightIndexI && self.indexJ == self.rightIndexJ;
}

/**
 *  将图片移动到固定的frame处
 */
- (void)moveToPositionByIndexIJ{
    [UIView animateWithDuration:0.05 animations:^{
        self.x = self.indexJ * CARD_WIDTH;
        self.y = self.indexI * CARD_HEIGHT;
    }];
}

//- (void)dealloc{
//    NSLog(@"CardImageView -- dealloc");
//}

@end
