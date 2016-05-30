//
//  MainGameViewController.m
//  PinTu_Game
//
//  Created by 小蔡 on 16/5/30.
//  Copyright © 2016年 xiaocai. All rights reserved.
// 主视图控制界面

#import "MainGameViewController.h"
#import "UIView+SDAutoLayout.h"

@interface MainGameViewController ()
/** 显示要使用的图片 */
@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, assign) int currentImageID;

@end

@implementation MainGameViewController
#pragma mark - 懒加载控件
- (UIImageView *)imageView{
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.view addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}

#pragma mark - 控制器相关
- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentImageID = 0;
    [self setupChildView];
}

#pragma mark - 初始化控件
- (void)setupChildView{
    //设置背景图片
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    backgroundImageView.image = [UIImage imageNamed:@"bg"];
    [self.view addSubview:backgroundImageView];
    backgroundImageView.sd_layout.leftEqualToView(self.view).rightEqualToView(self.view).topEqualToView(self.view).bottomEqualToView(self.view);
    
    //设置显示的拼图
    UIImageView *contextImageView = [[UIImageView alloc] init];
    contextImageView.image = [UIImage imageNamed:@"pin_0"];
    [self.view addSubview:contextImageView];
    _imageView = contextImageView;
    contextImageView.sd_layout.rightSpaceToView(self.view, 10).leftSpaceToView(self.view, 10).topSpaceToView(self.view, 20).bottomSpaceToView(self.view, 60);
    
    //添加按钮(开始,选择图片)
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [startBtn setTitle:@"开始" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:startBtn];
    startBtn.sd_layout.leftSpaceToView(self.view, 100).topSpaceToView(contextImageView, 10).widthIs(80).heightIs(44);
    
    UIButton *chooseImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [chooseImageBtn setTitle:@"选择图片" forState:UIControlStateNormal];
    [chooseImageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [chooseImageBtn addTarget:self action:@selector(chooseImageBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:chooseImageBtn];
    chooseImageBtn.sd_layout.leftSpaceToView(startBtn, 20).topSpaceToView(contextImageView, 10).widthIs(80).heightIs(44);
    
}

#pragma mark - 选择图片
- (void)chooseImageBtnClick{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择图片来源" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *nextImage = [UIAlertAction actionWithTitle:@"下一张" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageView.image = [UIImage imageNamed:[self nextImage]];
    }];
    
    [alert addAction:nextImage];
    [self presentViewController:alert animated:YES completion:nil];
}

/** 从本地取出下一张图片 */
- (NSString *)nextImage{
    if (self.currentImageID < 8) {
        self.currentImageID++;
    }else{
        self.currentImageID = 0;
    }
    return [NSString stringWithFormat:@"pin_%zd", self.currentImageID];
}


#pragma mark - 设置状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 设置屏幕支持方向(竖屏)
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}




@end
