//
//  GameView.h
//  pintu
//
//  Created by 小蔡 on 16/5/26.
//  Copyright © 2016年 xiaocai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GameView;
//拼图成功后,调用这个协议
@protocol GameViewDelegate <NSObject>

- (void)gameSuccess:(GameView *)gameView time:(NSString *)time step:(NSString *)step;

@end

@interface GameView : UIView
/** 图片 */
//@property (nonatomic) CGImageRef gameImage;

@property (nonatomic, strong) UIImage *image;
/** 数组乱序(打乱每个card) */
- (void)resetCardImages;

@property (nonatomic, weak) id<GameViewDelegate> delegate;
@end
