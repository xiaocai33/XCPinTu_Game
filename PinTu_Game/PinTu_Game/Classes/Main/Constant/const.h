//
//  const.h
//  pintu
//
//  Created by 小蔡 on 16/5/29.
//  Copyright © 2016年 xiaocai. All rights reserved.
//
#import <Foundation/Foundation.h>

#define ROW_COUNT 3
#define COL_COUNT 3
#define CARD_WIDTH  120
#define CARD_HEIGHT 120

typedef enum{
    /** 白块-->左 */
    DIR_LEFT = 0,
    /** 白块-->上 */
    DIR_UP,
    /** 白块-->右 */
    DIR_RIGHT,
    /** 白块-->下 */
    DIR_DOWN,
    /** 白块-->无 */
    DIR_NONE
} Dir;

