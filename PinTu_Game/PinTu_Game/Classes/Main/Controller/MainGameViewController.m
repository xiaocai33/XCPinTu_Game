//
//  MainGameViewController.m
//  PinTu_Game
//
//  Created by 小蔡 on 16/5/30.
//  Copyright © 2016年 xiaocai. All rights reserved.
// 主视图控制界面

#import "MainGameViewController.h"
#import "UIView+SDAutoLayout.h"
#import "GameView.h"
#import "const.h"
#import "UIImage+Extension.h"
#import "UIView+Extension.h"

@interface MainGameViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, GameViewDelegate>
/** 显示要使用的图片 */
@property (nonatomic, strong) GameView *gameView;

@property (nonatomic, assign) int currentImageID;

@property (nonatomic, strong) UIImageView *imageView;


@end

@implementation MainGameViewController

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self.view addSubview:_imageView];
    }
    return _imageView;
}

#pragma mark - 控制器相关
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.currentImageID = 0;
    [self setupChildView];
    //开始游戏
    [self startGame];
}

#pragma mark - 初始化控件
- (void)setupChildView{
    //设置显示的拼图
    self.gameView= [[GameView alloc] init];
    self.gameView.image = [UIImage imageNamed:@"pin_0"];
    self.gameView.delegate = self;
    [self.view addSubview:self.gameView];
    self.gameView.sd_layout.centerXEqualToView(self.view).topSpaceToView(self.view, 50).widthIs(COL_COUNT * CARD_WIDTH).heightIs(ROW_COUNT * CARD_HEIGHT);
    
    //添加按钮(开始,选择图片)
    UIButton *startBtn = [self addBtnWithTitle:@"重置"];
    [startBtn addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    startBtn.sd_layout.leftSpaceToView(self.view, 100).topSpaceToView(_gameView, 10).widthIs(80).heightIs(44);
    
    UIButton *chooseImageBtn = [self addBtnWithTitle:@"选择图片"];
    [chooseImageBtn addTarget:self action:@selector(chooseImageBtnClick) forControlEvents:UIControlEventTouchUpInside];
    chooseImageBtn.sd_layout.leftSpaceToView(startBtn, 20).topSpaceToView(_gameView, 10).widthIs(80).heightIs(44);
    
}
/**
 *  添加按钮
 *  @param title 按钮标题
 */
- (UIButton *)addBtnWithTitle:(NSString *)title{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor orangeColor]];
    [self.view addSubview:btn];
    return btn;
}

#pragma mark - 开始游戏
/** 开始游戏 */
- (void)startGame{
    //打乱图片
    [self.gameView resetCardImages];
}

#pragma mark - 选择图片
/** 选择图片 */
- (void)chooseImageBtnClick{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择图片来源" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    //取消
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    //内置图片下一张
    UIAlertAction *nextImage = [UIAlertAction actionWithTitle:@"下一张" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.gameView.image = [UIImage imageNamed:[self nextImage]];
    }];
    
    //相机
    UIAlertAction *cameraImage = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self chooseImageFromCameraOrLocation:UIImagePickerControllerSourceTypeCamera];
    }];
    
    //相册
    UIAlertAction *photoImage = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self chooseImageFromCameraOrLocation:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }];
    
    [alert addAction:cancel];
    [alert addAction:nextImage];
    [alert addAction:cameraImage];
    [alert addAction:photoImage];
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

/**
 *  从相机或者相册中选择图片
 *  参数 sourceType :
 *      UIImagePickerControllerSourceTypeCamera  相机
 *      UIImagePickerControllerSourceTypeSavedPhotosAlbum  相册
 */
- (void)chooseImageFromCameraOrLocation:(UIImagePickerControllerSourceType)sourceType{
    
    // 1.创建图片选择控制器
    UIImagePickerController *pickController = [[UIImagePickerController alloc] init];
     // 2.判断图库是否可用打开
    if ([UIImagePickerController availableMediaTypesForSourceType:sourceType]) {
        // 3.设置打开图库的类型
        pickController.sourceType = sourceType;
        pickController.delegate = self;
    }
    
    // 4.打开图片选择控制器
    [self presentViewController:pickController animated:YES completion:nil];
}

#pragma mark -- UIImagePickerController代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //取出选中的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    if (image.size.width > 640 || image.size.height > 980) {
        image = [image reSize:CGSizeMake(640, 980)];
    }
    self.imageView.image = image;
    
    self.gameView.image = self.imageView.image;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark - 设置状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 设置屏幕支持方向(竖屏)
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - GameViewDelegate 代理方法
- (void)gameSuccess:(GameView *)gameView time:(NSString *)time step:(NSString *)step{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"恭喜您,拼图成功" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    //取消
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    //再来一次
    UIAlertAction *again = [UIAlertAction actionWithTitle:@"再来一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.gameView resetCardImages];
    }];
    
    //相机
    UIAlertAction *nextImage = [UIAlertAction actionWithTitle:@"下一张图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.gameView.image = [UIImage imageNamed:[self nextImage]];
    }];
    
    [alert addAction:cancel];
    [alert addAction:nextImage];
    [alert addAction:again];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)dealloc{
    NSLog(@"MainVc -- dealloc");
}


@end
