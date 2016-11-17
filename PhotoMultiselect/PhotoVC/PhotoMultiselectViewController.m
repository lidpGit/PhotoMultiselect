//
//  PhotoMultiselectViewController.m
//  TalkToWorld
//
//  Created by lidp on 2016/11/2.
//  Copyright © 2016年 对话世界. All rights reserved.
//

#import "PhotoMultiselectViewController.h"
#import "PhotoGroupListViewController.h"
#import "PhotoPreviewController.h"
#import "UIView+ExtensionMethods.h"
#import "UIButton+ExtensionMethods.h"
#import "UIImage+ExtensionMethods.h"
#import "UIColor+ExtensionMethods.h"

void photoMultiselectStartAnimation(UIView *view){
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8f, 0.8f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.01f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [view.layer addAnimation:popAnimation forKey:nil];
}

#pragma mark - model
@implementation PhotoMultiselectModel

- (void)dealloc{
    NSLog(@"%s", __FUNCTION__);
}

@end

#pragma mark UICollectionViewCell
static NSString *const chatSelectPhotoItemIdentifier = @"PhotoMultiselectItemIdentifier";
@implementation PhotoMultiselectItem{
    UIImageView     *_imageView;
    UIButton        *_selectFlagBtn;
}

- (void)dealloc{
    NSLog(@"%s", __FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor whiteColor];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        
        _selectFlagBtn = [UIButton buttonWithFrame:CGRectMake(self.viewWidth - 33, 0, 33, 33) target:self action:@selector(onClickFlagBtn)];
        [_selectFlagBtn setImage:[UIImage imageNamed:@"item_unselect_photo"] forState:UIControlStateNormal];
        [_selectFlagBtn setImage:[UIImage imageNamed:@"item_selected_photo"] forState:UIControlStateSelected];
        [self.contentView addSubview:_selectFlagBtn];
    }
    return self;
}

- (void)setModel:(PhotoMultiselectModel *)model{
    _model = model;
    if (_model == nil) {
        //拍照
        _selectFlagBtn.hidden = YES;
        _imageView.image = [UIImage imageNamed:@"item_photo_camera"];
    }else{
        _selectFlagBtn.hidden = NO;
        if (_model.image) {
            _imageView.image = _model.image;
        }else{
            [[PHImageManager defaultManager] requestImageForAsset:_model.asset targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info){
                if (_model == model) {
                    _imageView.image = result;
                    _model.image = result;
                }
            }];
        }
        _selectFlagBtn.selected = _model.isSelected;
    }
}

- (void)resetFlagState{
    if (!_model.isSelected) {
        _selectFlagBtn.selected = NO;
    }else{
        _selectFlagBtn.selected = YES;
        photoMultiselectStartAnimation(_selectFlagBtn);
    }
}

- (void)onClickFlagBtn{
    if (self.model.isSelected) {
        //取消选中状态
        _model.isSelected = NO;
        [self resetFlagState];
        if (_delegate && [_delegate respondsToSelector:@selector(selectedPhoto:)]) {
            [_delegate selectedPhoto:self.model];
        }
    }else{
        //设置选中状态
        if (_delegate && [_delegate respondsToSelector:@selector(canSelectPhoto)]) {
            if ([_delegate canSelectPhoto]) {
                _model.isSelected = YES;
                [self resetFlagState];
                if (_delegate && [_delegate respondsToSelector:@selector(selectedPhoto:)]) {
                    [_delegate selectedPhoto:self.model];
                }
            }
        }
    }
}

@end

#pragma mark ViewController
@interface PhotoMultiselectViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PhotoMultiselectItemDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *selectedModelList;/**< 已选图片列表 */

@end

@implementation PhotoMultiselectViewController{
    UIView                  *_bottomView;
    UIButton                *_sendBtn;
    UIButton                *_previewBtn;
    UICollectionView        *_collectionView;
    NSMutableArray          *_dataSource;       /**< 数据源 */
    NSMutableArray          *_selectedModelList;/**< 已选图片列表 */
}

- (void)dealloc{
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_white"] style:UIBarButtonItemStylePlain target:self action:@selector(onClickBack)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onClickCancel)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    
    [self setBottomView];
    [self setCollectionView];
    [self getAssetCollectionPhotos];
    
    _selectedModelList = [[NSMutableArray alloc] init];
}

- (PhotoGroupListViewController *)groupVC{
    return self.navigationController.viewControllers.firstObject;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - ---------------------- 数据源

- (void)getAssetCollectionPhotos{
    PHAssetCollection *assetCollection = _assetCollection;
    if (!assetCollection) {
        //传入的相册为空，默认读取相机胶卷
        PHFetchResult *smartAlbumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        assetCollection = [smartAlbumsFetchResult objectAtIndex:0];
    }
    PHFetchResult *fetch = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    
    NSMutableArray *photoList = [[NSMutableArray alloc] init];
    for (PHAsset *asset in fetch) {
        if (asset.mediaType == PHAssetMediaTypeImage) {
            PhotoMultiselectModel *model = [[PhotoMultiselectModel alloc] init];
            model.asset = asset;
            [photoList addObject:model];
        }
    }
    _dataSource = [NSMutableArray arrayWithArray:[photoList reverseObjectEnumerator].allObjects];
    [_collectionView reloadData];
}

#pragma mark - ---------------------- UI
- (void)setBottomView{
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 49, [UIScreen mainScreen].bounds.size.width, 49)];
    _bottomView.backgroundColor = [[UIColor colorWithHexString:@"#101011"] colorWithAlphaComponent:0.67f];
    [self.view addSubview:_bottomView];
    
    //发送按钮
    _sendBtn = [UIButton buttonWithFrame:CGRectMake(0, 0, 83, 32) target:self action:@selector(onClickFinish)];
    _sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_sendBtn setCornerRadiur:3];
    _sendBtn.centerY = _bottomView.viewHeight / 2;
    _sendBtn.viewX = _bottomView.viewWidth - 12 - _sendBtn.viewWidth;
    [_bottomView addSubview:_sendBtn];
    
    //预览按钮
    _previewBtn = [UIButton buttonWithFrame:CGRectMake(0, 0, 62, _bottomView.viewHeight) target:self action:@selector(onClickPreview)];
    [_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
    _previewBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_previewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_previewBtn setTitleColor:[UIColor colorWithHexString:@"#CED0D6"] forState:UIControlStateNormal];
    _previewBtn.selected = NO;
    [_bottomView addSubview:_previewBtn];
    
    [self updateBottomView];
}

- (void)updateBottomView{
    [_sendBtn setTitle:[NSString stringWithFormat:@"确定(%zi/%zi)", _selectedModelList.count, self.maxCount] forState:UIControlStateNormal];
    _sendBtn.backgroundColor = _selectedModelList.count > 0 ? [UIColor colorWithHexString:@"#3d8eff"] : [UIColor colorWithHexString:@"#CED0D6"];
    _previewBtn.selected = _selectedModelList.count > 0;
}

- (void)setCollectionView{
    CGFloat itemWidth = (self.view.viewWidth - 15) / 4;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:layout];
    _collectionView.backgroundColor = self.view.backgroundColor;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, _bottomView.viewHeight, 0);
    [_collectionView registerClass:PhotoMultiselectItem.class forCellWithReuseIdentifier:chatSelectPhotoItemIdentifier];
    [self.view insertSubview:_collectionView belowSubview:_bottomView];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataSource.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoMultiselectItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:chatSelectPhotoItemIdentifier forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.model = nil;
    }else{
        cell.model = _dataSource[indexPath.row - 1];
    }
    cell.delegate = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        //拍照
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *pickerVC = [[UIImagePickerController alloc] init];
            pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerVC.delegate = self;
            [self presentViewController:pickerVC animated:YES completion:nil];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"设备不支持拍照" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }else{
        //预览
        [self showPreviewVCWithIndex:indexPath.row - 1 dataSource:_dataSource];
    }
}

#pragma mark - ---------------------- PhotoMultiselectItemDelegate
- (void)selectedPhoto:(PhotoMultiselectModel *)model{
    if (model.isSelected) {
        if (self.maxCount == 1) {
            //取消上一个选中的图片
            if (_selectedModelList.count > 0) {
                PhotoMultiselectModel *selectedModel = _selectedModelList.firstObject;
                selectedModel.isSelected = NO;
                [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:[_dataSource indexOfObject:selectedModel] + 1 inSection:0]]];
            }
            
            //添加当前选中的图片
            [_selectedModelList removeAllObjects];
            [_selectedModelList addObject:model];
        }else{
            if (![_selectedModelList containsObject:model]) {
                [_selectedModelList addObject:model];
            }
        }
    }else{
        if ([_selectedModelList containsObject:model]) {
            [_selectedModelList removeObject:model];
        }
    }
    [self updateBottomView];
}

- (BOOL)canSelectPhoto{
    BOOL canSelect = self.maxCount == 1 || self.maxCount > _selectedModelList.count;
    if (!canSelect) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:@"最多选择%zi张照片", self.maxCount]
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    return canSelect;
}

#pragma mark - ---------------------- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if ([self groupVC].clickFinishCallback) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        image = [UIImage thumbnailWithImage:image size:image.size];
        NSMutableArray *imageList = [[NSMutableArray alloc] init];
        [imageList addObject:image];
        
        [self groupVC].clickFinishCallback(imageList);
        [self groupVC].clickFinishCallback = nil;
    }
    [picker dismissViewControllerAnimated:NO completion:nil];
    [self onClickCancel];
}

#pragma mark - ---------------------- 事件
- (void)onClickBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onClickCancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onClickPreview{
    if (_previewBtn.selected) {
        [self showPreviewVCWithIndex:0 dataSource:_selectedModelList];
    }
}

- (void)onClickFinish{
    if (_selectedModelList.count <= self.maxCount && _selectedModelList.count > 0) {
        [self fetchImageForModelIndex:0 resultArray:[[NSMutableArray alloc] init]];
    }
}

//递归获取图片
- (void)fetchImageForModelIndex:(NSInteger)index resultArray:(NSMutableArray *)resultArray{
    PhotoMultiselectModel *model = _selectedModelList[index];
    CGSize size = [UIScreen mainScreen].bounds.size;
    [[PHImageManager defaultManager] requestImageForAsset:model.asset targetSize:CGSizeMake(size.width, size.height)
                                              contentMode:PHImageContentModeAspectFit
                                                  options:nil
                                            resultHandler:^(UIImage *result, NSDictionary *info){
                                                BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                                                if (downloadFinined) {
                                                    [resultArray addObject:result];
                                                    if (resultArray.count >= self.selectedModelList.count) {
                                                        [self finishSelectImage:resultArray];
                                                    }else{
                                                        [self fetchImageForModelIndex:index + 1 resultArray:resultArray];
                                                    }
                                                }
    }];
}

- (void)finishSelectImage:(NSMutableArray *)imageList{
    if ([self groupVC].clickFinishCallback && imageList.count > 0) {
        [self groupVC].clickFinishCallback(imageList);
        [self groupVC].clickFinishCallback = nil;
    }
    [self onClickCancel];
}

#pragma mark - ---------------------- 跳转
- (void)showPreviewVCWithIndex:(NSInteger)index dataSource:(NSMutableArray *)dataSource{
    PhotoPreviewController *previewVC = [[PhotoPreviewController alloc] init];
    previewVC.dataSource = dataSource;
    previewVC.selectedModelList = [NSMutableArray arrayWithArray:_selectedModelList];
    previewVC.currentIndex = index;
    previewVC.maxCount = self.maxCount;
    
    __weak typeof(self) weakself = self;
    previewVC.onClickBackCallback = ^(NSMutableArray *selectedModelList) {
        weakself.selectedModelList = selectedModelList;
        [weakself updateBottomView];
        [weakself.collectionView reloadData];
    };
    
    previewVC.onClickSendCallback = ^(NSMutableArray *selectedModelList) {
        weakself.selectedModelList = selectedModelList;
        [weakself updateBottomView];
        [weakself onClickFinish];
    };
    [self.navigationController pushViewController:previewVC animated:YES];
}

@end
