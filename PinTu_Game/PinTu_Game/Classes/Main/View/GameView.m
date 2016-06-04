//
//  GameView.m
//  pintu
//
//  Created by 小蔡 on 16/5/26.
//  Copyright © 2016年 xiaocai. All rights reserved.
//

#import "GameView.h"
#import "CardImageView.h"
#import "const.h"

@interface GameView(){
    /** 存在CardImageView的数组 */
    CardImageView *_cardsMap[ROW_COUNT][COL_COUNT];
}

/** 白块的位置 */
@property (nonatomic, assign) int currentNullIndexI;
@property (nonatomic, assign) int currentNullIndexJ;

/** 存放每一个小cardImage图片 */
@property (nonatomic, strong) NSMutableArray *cards;
/** 上一次可移动的方向 */
@property (nonatomic, assign) Dir lastDir;
/** 是否开始移动 */
@property (nonatomic, assign) BOOL touchStart;

@end

@implementation GameView

- (NSMutableArray *)cards{
    if (!_cards) {
        _cards = [NSMutableArray array];
    }
    return _cards;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _lastDir = DIR_NONE;
    }
    return self;
}



#pragma mark - 初始化切割图片
- (void)setImage:(UIImage *)image{
    _image = image;
    [self cupImage:[image CGImage]];
}
/**
 *  切割图片
 */
- (void)cupImage:(CGImageRef)gameImage{
    CGImageRelease(gameImage);
    //清空上一次的视图(方便切换图片)
    for (CardImageView *cardView in self.cards) {
        [cardView removeFromSuperview];
    }
    self.cards = nil;
    
    CGFloat imageWidth = CGImageGetWidth(gameImage);
    CGFloat imageHeight = CGImageGetHeight(gameImage);
    CGFloat cardImageWidth = imageWidth / COL_COUNT;
    CGFloat cardImageHeight = imageHeight / ROW_COUNT;
    CGRect rect = CGRectMake(0, 0, cardImageWidth, cardImageHeight);
    
    //九宫格布局
    CardImageView *cardImage;
    for (int i=0; i<ROW_COUNT; i++) {
        for (int j=0; j<COL_COUNT; j++) {
            if (i != ROW_COUNT - 1 || j != COL_COUNT - 1){
                //计算位置
                rect.origin.x = cardImageWidth * j;
                rect.origin.y = cardImageHeight * i;
                //切割图片
                cardImage = [[CardImageView alloc] initWithImage:[[UIImage alloc] initWithCGImage:CGImageCreateWithImageInRect(gameImage, rect)]];
                //设置正确位置
                cardImage.rightIndexI = i;
                cardImage.rightIndexJ = j;
                //设置目前的位置
                cardImage.indexI = i;
                cardImage.indexJ = j;
                [cardImage resetPositionByIndexIJ];
                [self addSubview:cardImage];
                //将每一个小图片存放到_cardsMap中
                _cardsMap[i][j] = cardImage;
                
                [self.cards addObject:cardImage];
            }
        }
    }
    //将最后一个图片保存(当拼图完成的时候,显示)
    rect.origin.x = cardImageWidth * (ROW_COUNT -1);
    rect.origin.y = cardImageHeight * (COL_COUNT -1);
    cardImage = [[CardImageView alloc] initWithImage:[[UIImage alloc] initWithCGImage:CGImageCreateWithImageInRect(gameImage, rect)]];
    [self.cards addObject:cardImage];
    
    //空白块的位置
    self.currentNullIndexI = ROW_COUNT - 1;
    self.currentNullIndexJ = COL_COUNT - 1;
    _cardsMap[self.currentNullIndexI][self.currentNullIndexJ] = nil;
}

#pragma mark - 触摸移动图片
/**
 *  找到触摸到的方块位置
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (!_touchStart) {
        //NSLog(@"touchesStart---%zd", _touchStart);
    
    _touchStart = YES;
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    //找出触摸到的坐标
    CGPoint point = [touch locationInView:self];
    
    int indexI = point.y/CARD_HEIGHT;
    int indexJ = point.x/CARD_WIDTH;
    if (indexI < 0 || indexJ < 0 || indexI > ROW_COUNT-1 || indexJ > COL_COUNT-1) return;
    
    CardImageView *cardImage = _cardsMap[indexI][indexJ];
    
    /**
     *  移动空白块
     *  @param int 移动的的坐标I(空白块的I坐标)
     *  @param int 移动的的坐标J(空白块的J坐标)
     */
        NSLog(@"%zd--%zd", indexI, indexJ);
    void (^moveTouchCard)(int, int) = ^(int i, int j){
        //将当期位置设为空白块
        _cardsMap[indexI][indexJ] = nil;
        
        NSLog(@"白块位置--%zd--%zd", indexI, indexJ);
        //更改空白块的坐标
        self.currentNullIndexI = indexI;
        self.currentNullIndexJ = indexJ;
        
        //设置原空白块的位置处为cardImage
        _cardsMap[i][j] = cardImage;
        
        //重新设置当期块的坐标
        cardImage.indexI = i;
        cardImage.indexJ = j;
        
        //移动图片
        [cardImage moveToPositionByIndexIJ];
        
        //设置当前点击结束
        _touchStart = NO;
        
        //检测是否成功
        [self successPinTu];
        
    };
    //NSLog(@"%zd", [self cardImageMoveDir:cardImage]);
    switch ([self cardImageMoveDir:cardImage]) {
        //触摸块 上移-->  白块 下移
        case DIR_UP:
            moveTouchCard(indexI-1, indexJ);
            break;
            
        //触摸块 下移-->  白块 上移
        case DIR_DOWN:
            moveTouchCard(indexI+1, indexJ);
            break;
            
        //触摸块 左移-->  白块 右移
        case DIR_LEFT:
            moveTouchCard(indexI, indexJ-1);
            break;
            
        //触摸块 右移-->  白块 左移
        case DIR_RIGHT:
            moveTouchCard(indexI, indexJ+1);
            break;
            
        case DIR_NONE:
            //设置当前点击结束
            _touchStart = NO;
            break;
        default:
            break;
    };
    
    }
}

/**
 *  得到触摸点位置可移动的位置,然后移动
 */
- (Dir)cardImageMoveDir:(CardImageView *)cardImage{
    int indexI = cardImage.indexI;
    int indexJ = cardImage.indexJ;
    
    //触摸到的块,上边有白块,将触摸块上移
    if (indexI >0 &&!_cardsMap[indexI-1][indexJ]) {
        return DIR_UP;
    }
    
    //触摸到的块,下边有白块,将触摸块下移
    if (indexI < ROW_COUNT -1 && !_cardsMap[indexI + 1][indexJ]) {
        return DIR_DOWN;
    }
    
    //触摸到的块,左边有白块,将触摸块左移
    if (indexJ > 0 && !_cardsMap[indexI][indexJ - 1]) {
        return DIR_LEFT;
    }
    
    //触摸到的块,右边有白块,将触摸块右移
    if (indexJ < COL_COUNT -1 && !_cardsMap[indexI][indexJ + 1]) {
        return DIR_RIGHT;
    }
    
    return DIR_NONE;
}

/**
 *  检测是否成功
 */
- (BOOL)checkSuccess{
    for (CardImageView *imageView in self.subviews) {
        if(![imageView onRightLocation]){
            return NO;
        }
    }
    
    return YES;
}

/**
 *  成功完成拼图后调用
 */
- (void)successPinTu{
    if ([self checkSuccess]) {
        //填充最后一张图片
        CardImageView *lastCardImage = [_cards lastObject];
        lastCardImage.indexI = self.currentNullIndexI;
        lastCardImage.indexJ = self.currentNullIndexJ;
        [lastCardImage resetPositionByIndexIJ];
        [self addSubview:lastCardImage];
        _cardsMap[self.currentNullIndexI][self.currentNullIndexJ] = lastCardImage;
        //成功了提醒
        if ([self.delegate respondsToSelector:@selector(gameSuccess:time:step:)]){
            [self.delegate gameSuccess:self time:@"10" step:@"5"];
        }
        
        //NSLog(@"恭喜你,成功了");
    }
}


#pragma mark - (开始按钮后调用)数组乱序(打乱每个cardImage的位置)
/**
 *  数组乱序(打乱每个cardImage的位置)
 */
- (void)resetCardImages{
    if (_cards.count > 0) {
        CardImageView *lastCardImage = [_cards lastObject];
        [lastCardImage removeFromSuperview];
    }
    
    int count = 10;
    while(count){
        --count;
        Dir dir = [self autoMoveDir];
        
        __block CardImageView *cardImage;
        /**
         *  用block块封装代码
         *
         *  @param int  要移动块的位置的I
         *  @param int  要移动块的位置的J
         */
        void (^moveDir)(int, int) = ^(int nullI, int nullJ){
            cardImage = _cardsMap[nullI][nullJ];
            _cardsMap[self.currentNullIndexI][self.currentNullIndexJ] = cardImage;
            _cardsMap[nullI][nullJ] = nil;
            cardImage.indexI = self.currentNullIndexI;
            cardImage.indexJ = self.currentNullIndexJ;
            
            //移动图片
            [cardImage moveToPositionByIndexIJ];
        };
        
        switch (dir) {
            case DIR_UP://白块上移
                moveDir(self.currentNullIndexI-1, self.currentNullIndexJ);
                self.currentNullIndexI -= 1;
                break;
                
            case DIR_DOWN://白块下移
                moveDir(self.currentNullIndexI+1, self.currentNullIndexJ);
                self.currentNullIndexI += 1;
                break;
                
            case DIR_LEFT://白块左移
                moveDir(self.currentNullIndexI, self.currentNullIndexJ-1);
                self.currentNullIndexJ -= 1;
                break;
                
            case DIR_RIGHT://白块右移
                moveDir(self.currentNullIndexI, self.currentNullIndexJ+1);
                self.currentNullIndexJ += 1;
                break;
                
            default:
                break;
        }
    }
}

/**
 *  随机得到当前可以白块移动的方向
 */
- (Dir)autoMoveDir{
    NSMutableArray *dirs = [NSMutableArray array];
    //白块不在最上边,可以向上移动
    if (self.currentNullIndexI > 0 && _lastDir != DIR_DOWN) {
        [dirs addObject:[NSString stringWithFormat:@"%zd", DIR_UP]];
    }
    //白块不在最下边,可以向下移动
    if (self.currentNullIndexI < ROW_COUNT -1 && _lastDir != DIR_UP){
        [dirs addObject:[NSString stringWithFormat:@"%zd", DIR_DOWN]];
    }
    //白块不在最左边,可以向左移动
    if (self.currentNullIndexJ>0 && _lastDir != DIR_RIGHT){
        [dirs addObject:[NSString stringWithFormat:@"%zd", DIR_LEFT]];
    }
    //白块不在最右边,可以向右移动
    if (self.currentNullIndexJ < COL_COUNT-1 && _lastDir != DIR_LEFT){
        [dirs addObject:[NSString stringWithFormat:@"%zd", DIR_RIGHT]];
    }

    self.lastDir = [[dirs objectAtIndex:arc4random()%(dirs.count)] intValue];
    return self.lastDir;
}

/**
 *  设置背景图片
 */
- (void)drawRect:(CGRect)rect{
    UIImage *bgImage = [UIImage imageNamed:@"blank"];
    [bgImage drawInRect:rect];
}

- (void)dealloc{
    NSLog(@"GameView -- dealloc");
}

@end
