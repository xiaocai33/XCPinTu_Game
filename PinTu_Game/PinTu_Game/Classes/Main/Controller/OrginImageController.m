//
//  OrginImageController.m
//  PinTu_Game
//
//  Created by 小蔡 on 16/5/31.
//  Copyright © 2016年 xiaocai. All rights reserved.
// 显示原图

#import "OrginImageController.h"
#import "UIView+SDAutoLayout.h"

@interface OrginImageController()

@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation OrginImageController
- (UIImageView *)imageView{
    if (!_imageView) {
        //设置显示的拼图
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor redColor];
        [self.view addSubview:imageView];
        imageView.sd_layout.centerXEqualToView(self.view).topSpaceToView(self.view, 50).widthIs(300).heightIs(300);
        _imageView = imageView;

    }
    return _imageView;
}


- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //初始化子控件
    [self setupChildView];
}

#pragma mark - 初始化控件
- (void)setupChildView{
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    backBtn.backgroundColor = [UIColor orangeColor];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    backBtn.sd_layout.centerXEqualToView(self.view).topSpaceToView(self.imageView, 10).widthIs(80).heightIs(44);
    
}

/**
 *  返回
 */
- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setImage:(UIImage *)image{
    _image = image;
    //设置图片
    self.imageView.image = image;
}

@end
