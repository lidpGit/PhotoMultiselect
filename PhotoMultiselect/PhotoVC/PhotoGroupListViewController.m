//
//  PhotoGroupListViewController.m
//  PhotoMultiselect
//
//  Created by lidp on 2016/11/17.
//  Copyright © 2016年 lidp. All rights reserved.
//

#import "PhotoGroupListViewController.h"
#import "UIImage+ExtensionMethods.h"
#import "UIView+ExtensionMethods.h"
#import "PhotoMultiselectViewController.h"

#pragma mark - model
@implementation PhotoGroupModel

@end

#pragma mark - cell
@implementation PhotoGroupCell

- (void)dealloc{
    NSLog(@"%s", __FUNCTION__);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (void)setModel:(PhotoGroupModel *)model{
    _model = model;
    if (_model.lastAsset) {
        if (_model.image) {
            self.imageView.image = _model.image;
        }else{
            [[PHImageManager defaultManager] requestImageForAsset:_model.lastAsset targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info){
                if (_model == model) {
                    self.imageView.image = result;
                    _model.image = result;
                }
            }];
        }
    }else{
        self.imageView.image = [UIImage imageNamed:@"group_default"];
    }
    self.textLabel.text = [NSString stringWithFormat:@"%@(%zi)", model.assetCollection.localizedTitle, model.count];
    [self.textLabel sizeToFit];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.viewX = 8;
    self.imageView.viewY = 10;
    self.imageView.viewHeight = self.viewHeight - 20;
    self.imageView.viewWidth = self.imageView.viewHeight;
    
    self.textLabel.viewX = self.imageView.viewMaxX + 10;
    self.textLabel.centerY = self.viewHeight / 2;
    self.textLabel.viewWidth = self.viewWidth - 10 - self.textLabel.viewX;
}

@end

#pragma mark - viewController
@interface PhotoGroupListViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

static NSString *const cell_identifier = @"PhotoGroupCell";
@implementation PhotoGroupListViewController{
    UITableView         *_tableView;
    NSMutableArray      *_dataSource;
}

#pragma mark - ---------------------- class method
+ (void)showPhotoPhotoMultiselectVCWithFromVC:(UIViewController *)fromVC count:(NSInteger)count selectedImageCallback:(void (^)(NSMutableArray *))callback{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied) {
        //相册权限未开启
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:@"请在iPhone的“设置->隐私->照片”开启%@访问你的手机相册", appName]
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }else if(status == PHAuthorizationStatusNotDetermined){
        //第一次授权
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
            if (status == PHAuthorizationStatusAuthorized){
                dispatch_async(dispatch_get_main_queue(), ^{
                    PhotoGroupListViewController *photoGroupListVC = [[PhotoGroupListViewController alloc] init];
                    photoGroupListVC.maxCount = count;
                    photoGroupListVC.clickFinishCallback = callback;
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoGroupListVC];
                    [fromVC presentViewController:nav animated:YES completion:nil];
                });
            }
        }];
    }else{
        //已授权
        PhotoGroupListViewController *photoGroupListVC = [[PhotoGroupListViewController alloc] init];
        photoGroupListVC.maxCount = count;
        photoGroupListVC.clickFinishCallback = callback;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoGroupListVC];
        [fromVC presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - ---------------------- instance method
- (void)dealloc{
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if (self.maxCount <= 0) {
        self.maxCount = 9;
    }
    self.navigationItem.title = @"照片";
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor blackColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_white"] style:UIBarButtonItemStylePlain target:self action:@selector(onClickCancel)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onClickCancel)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    
    [self getAllGroups];
    
    [self showPhotoMultiselectVC:NO title:@"相机胶卷" assetCollection:nil];
}

- (void)showTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    _tableView.tableFooterView = [UIView new];
    [_tableView registerClass:[PhotoGroupCell class] forCellReuseIdentifier:cell_identifier];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showPhotoMultiselectVC:(BOOL)animated title:(NSString *)title assetCollection:(PHAssetCollection *)assetCollection{
    PhotoMultiselectViewController *photoMultiselectVC = [[PhotoMultiselectViewController alloc] init];
    photoMultiselectVC.maxCount = self.maxCount;
    photoMultiselectVC.assetCollection = assetCollection;
    photoMultiselectVC.navigationItem.title = title;
    [self.navigationController pushViewController:photoMultiselectVC animated:animated];
}

#pragma mark - ---------------------- 数据源
- (void)getAllGroups{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        _dataSource = [NSMutableArray new];
        
        //所有系统相册
        PHFetchResult *systemCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        [self setDataSourceWithFetchResult:systemCollections];
        
        //所有用户创建的相册
        PHFetchResult *userCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        [self setDataSourceWithFetchResult:userCollections];
        
        [self showTableView];
    });
}

- (void)setDataSourceWithFetchResult:(PHFetchResult *)result{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    //只取图片
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
    for (NSInteger i = 0; i < result.count; i++) {
        PHAssetCollection *assetCollection = result[i];
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
        PhotoGroupModel *model = [[PhotoGroupModel alloc] init];
        model.count = assetsFetchResult.count;
        model.assetCollection = assetCollection;
        
        if (assetsFetchResult.count > 0) {
            model.lastAsset = [assetsFetchResult objectAtIndex:assetsFetchResult.count - 1];
        }
        
        [_dataSource addObject:model];
    }
}

#pragma mark - ---------------------- UITableViewDelegate/UITableDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PhotoGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_identifier];
    cell.model = _dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PhotoGroupModel *model = _dataSource[indexPath.row];
    [self showPhotoMultiselectVC:YES title:model.assetCollection.localizedTitle assetCollection:model.assetCollection];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    UIEdgeInsets edge = UIEdgeInsetsMake(0, 88, 0, 0);
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = edge;
        tableView.layoutMargins = edge;
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = edge;
        tableView.separatorInset = edge;
    }
}

#pragma mark - ---------------------- 事件
- (void)onClickCancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
