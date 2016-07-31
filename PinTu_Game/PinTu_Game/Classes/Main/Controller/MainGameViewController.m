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
#import "OrginImageController.h"
#import "MBProgressHUD+MJ.h"

@interface MainGameViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, GameViewDelegate, UIActionSheetDelegate>
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
    [self resetGame];
}

#pragma mark - 初始化控件
- (void)setupChildView{
    
    UIImageView *bgImageView= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"game_bg"]];
    [self.view addSubview:bgImageView];
    
    bgImageView.sd_layout.leftEqualToView(self.view).rightEqualToView(self.view).topEqualToView(self.view).bottomEqualToView(self.view);
    
    self.imageView.image = [UIImage imageNamed:@"pin_0"];
    //设置显示的拼图
    self.gameView= [[GameView alloc] init];
    self.gameView.image = [UIImage imageNamed:@"pin_0"];
    self.gameView.delegate = self;
    [self.view addSubview:self.gameView];
    self.gameView.sd_layout.centerXEqualToView(self.view).topSpaceToView(self.view, 40).widthIs(COL_COUNT * CARD_WIDTH).heightIs(ROW_COUNT * CARD_HEIGHT);
    
    //添加按钮(开始,选择图片)
    UIButton *chooseImageBtn = [self addBtnWithTitle:@"选择图片"];
    [chooseImageBtn addTarget:self action:@selector(chooseImageBtnClick) forControlEvents:UIControlEventTouchUpInside];
    chooseImageBtn.sd_layout.centerXEqualToView(self.view).topSpaceToView(_gameView, 20).widthIs(80).heightIs(44);
    
    UIButton *resetBtn = [self addBtnWithTitle:@"重置"];
    [resetBtn addTarget:self action:@selector(resetGame) forControlEvents:UIControlEventTouchUpInside];
    resetBtn.sd_layout.rightSpaceToView(chooseImageBtn, 20).topSpaceToView(_gameView, 20).widthIs(80).heightIs(44);
    
    
    UIButton *orginImageBtn = [self addBtnWithTitle:@"原图"];
    [orginImageBtn addTarget:self action:@selector(orginImageBtnClick) forControlEvents:UIControlEventTouchUpInside];
    orginImageBtn.sd_layout.leftSpaceToView(chooseImageBtn, 20).topSpaceToView(_gameView, 20).widthIs(80).heightIs(44);
    
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
/**
 *  查看原图
 */
- (void)orginImageBtnClick{
    OrginImageController *orginVc = [[OrginImageController alloc] init];
    orginVc.image = self.imageView.image;
    orginVc.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    
    [self presentViewController:orginVc animated:YES completion:nil];
}

/** 开始游戏 */
- (void)resetGame{
    //打乱图片
    [self.gameView resetCardImages];
}

#pragma mark - 选择图片
/** 选择图片 */
- (void)chooseImageBtnClick{
    [[[UIActionSheet alloc] initWithTitle:@"选择图片来源" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"内置图片",@"照像机",@"图库",@"相册", nil] showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIImagePickerController * upc;
    
    switch (buttonIndex) {
        case 0:{//内置图片
            //切换控制器保留的图片
            self.imageView.image = [UIImage imageNamed:[self nextImage]];
            //切换图片
            self.gameView.image = self.imageView.image;
            //打乱顺序
            [self resetGame];
            break;
            }
        case 1://照像机
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                
                upc = [[UIImagePickerController alloc] init];
                upc.sourceType = UIImagePickerControllerSourceTypeCamera;
                upc.delegate=self;
                [self presentViewController:upc animated:YES completion:nil];
            }else {
                [[[UIAlertView alloc] initWithTitle:@"提示" message:@"亲爱的主人，您的设备没有摄像头哦！" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil] show];
            }
            
            break;
        }
        case 2://图库
        {
            __block UIImagePickerController * upc1 = upc;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                upc1 = [[UIImagePickerController alloc] init];
                upc1.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                upc1.delegate=self;
                [self presentViewController:upc1 animated:YES completion:nil];
            });
            break;
        }
        case 3://相册
        {
            __block UIImagePickerController * upc1 = upc;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            upc1 = [[UIImagePickerController alloc] init];
            upc1.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            upc1.delegate=self;
            [self presentViewController:upc1 animated:YES completion:nil];
            });
            break;
        }
        default:
            break;
    }
}

//- (void)chooseImageBtnClick{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择图片来源" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
//    //取消
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//    
//    //内置图片下一张
//    UIAlertAction *nextImage = [UIAlertAction actionWithTitle:@"下一张" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        //切换控制器保留的图片
//        self.imageView.image = [UIImage imageNamed:[self nextImage]];
//        //切换图片
//        self.gameView.image = self.imageView.image;
//        //打乱顺序
//        [self resetGame];
//        
//    }];
//    
//    //相机
//    UIAlertAction *cameraImage = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        //[self chooseImageFromCameraOrLocation:UIImagePickerControllerSourceTypeCamera];
//       
//    }];
//    
//    //相册
//    UIAlertAction *photoImage = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        //[self chooseImageFromCameraOrLocation:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
//        UIImagePickerController *pickController = [[UIImagePickerController alloc] init];
//        
//        // 3.设置打开图库的类型
//        pickController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//        pickController.delegate = self;
//            
//       // 4.打开图片选择控制器
//       [self presentViewController:pickController animated:YES completion:nil];
//        
//    }];
//    
//    [alert addAction:cancel];
//    [alert addAction:nextImage];
//    [alert addAction:cameraImage];
//    [alert addAction:photoImage];
//    [self presentViewController:alert animated:YES completion:nil];
//}

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
//- (void)chooseImageFromCameraOrLocation:(UIImagePickerControllerSourceType)sourceType{
////    if (self.imageView.isAnimating)
////    {
////        [self.imageView stopAnimating];
////    }
//    
//    // 1.创建图片选择控制器
//    UIImagePickerController *pickController = [[UIImagePickerController alloc] init];
//    pickController.modalPresentationStyle = UIModalPresentationCurrentContext;
//     // 2.判断图库是否可用打开
//    if ([UIImagePickerController availableMediaTypesForSourceType:sourceType]) {
//        // 3.设置打开图库的类型
//        pickController.sourceType = sourceType;
//        pickController.delegate = self;
//
//        // 4.打开图片选择控制器
//        [self presentViewController:pickController animated:YES completion:nil];
//    }else{
//        [MBProgressHUD showError:@"当前设备不支持相机或者相册图片" toView:self.view];
//    }
//}

#pragma mark -- UIImagePickerController代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //取出选中的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    if (image.size.width > 640 || image.size.height > 980) {
        image = [image reSize:CGSizeMake(640, 980)];
    }
    //保留image对象,防止选完后被释放
    self.imageView.image = image;
    
    //取出imageView中的图片传给gameView
    self.gameView.image = self.imageView.image;
    //打乱顺序
    [self resetGame];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    //UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    //再来一次
    UIAlertAction *again = [UIAlertAction actionWithTitle:@"再来一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.gameView resetCardImages];
    }];
    
    //相机
    UIAlertAction *nextImage = [UIAlertAction actionWithTitle:@"下一张图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImage *image = [UIImage imageNamed:[self nextImage]];
        self.gameView.image = image;
        self.imageView.image = image;
        
        [self.gameView resetCardImages];
    }];
    
    //[alert addAction:cancel];
    [alert addAction:nextImage];
    [alert addAction:again];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)dealloc{
    NSLog(@"MainGame -- dealloc");
}


@end
