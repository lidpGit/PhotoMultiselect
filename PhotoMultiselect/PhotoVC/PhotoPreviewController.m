//
//  PhotoPreviewController.m
//  TalkToWorld
//
//  Created by lidp on 2016/11/2.
//  Copyright © 2016年 对话世界. All rights reserved.
//

#import "PhotoPreviewController.h"
#import "UIView+ExtensionMethods.h"
#import "UIColor+ExtensionMethods.h"
#import "UIButton+ExtensionMethods.h"
#import "UILabel+ExtensionMethods.h"

static const CGFloat outOffset = 10.0f;

#pragma mark - UICollectionViewCell
@interface PhotoPreviewItem ()<UIScrollViewDelegate>

@end

@implementation PhotoPreviewItem{
    UIScrollView    *_scrollView;
    UIImageView     *_imageView;
}

- (void)dealloc{
    NSLog(@"%s", __FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor blackColor];
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(outOffset, 0, self.contentView.viewWidth - outOffset * 2, self.contentView.viewHeight)];
    _scrollView.backgroundColor = self.contentView.backgroundColor;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = 3;
    _scrollView.delegate = self;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:_scrollView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapEvent)];
    [_scrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapEvent:)];
    doubleTap.numberOfTapsRequired = 2;
    [_scrollView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.backgroundColor = _scrollView.backgroundColor;
    [_scrollView addSubview:_imageView];
}

- (void)setModel:(PhotoMultiselectModel *)model{
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:NO];
    _model = model;
    CGSize size = [UIScreen mainScreen].bounds.size;
    [[PHImageManager defaultManager] requestImageForAsset:_model.asset targetSize:CGSizeMake(size.width * 1.5, size.height * 1.5) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (_model == model) {
            _imageView.image = result;
            [self setImageViewFrame];
        }
    }];
}

- (void)setImageViewFrame{
    UIImage *image = _imageView.image;
    CGFloat scale = 0;
    if (image && image.size.width > 0) {
        scale = _scrollView.viewWidth / image.size.width;
    }
    
    CGRect frame = _imageView.frame;
    frame.size.width = _scrollView.viewWidth;
    frame.size.height = scale * image.size.height;
    frame.origin.x = 0;
    if (frame.size.height > _scrollView.viewHeight) {
        frame.origin.y = 0;
    }else{
        frame.origin.y = (_scrollView.viewHeight - frame.size.height) / 2;
    }
    _imageView.frame = frame;
}

#pragma mark - ---------------------- 手势
- (void)singleTapEvent{
    if (_delegate && [_delegate respondsToSelector:@selector(singleTapScrollView)]) {
        [_delegate singleTapScrollView];
    }
}

- (void)doubleTapEvent:(UITapGestureRecognizer *)sender{
    if (_scrollView.zoomScale != _scrollView.minimumZoomScale) {
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    } else {
        //放大倍数
        CGFloat newZoomScale = (_scrollView.maximumZoomScale + _scrollView.minimumZoomScale) / 2.0f;
        CGFloat xsize = _scrollView.bounds.size.width / newZoomScale;
        CGFloat ysize = _scrollView.bounds.size.height / newZoomScale;
        
        //获取到双击的点
        CGFloat touchX = [sender locationInView:sender.view].x;
        CGFloat touchY = [sender locationInView:sender.view].y;
        
        //计算偏移量
        touchX *= 1 / _scrollView.zoomScale + _scrollView.contentOffset.x;
        touchY *= 1 / _scrollView.zoomScale + _scrollView.contentOffset.y;
        
        CGRect frame = CGRectMake(touchX - xsize/2, touchY - ysize/2, xsize, ysize);
        [_scrollView zoomToRect:frame animated:YES];
    }
}

#pragma mark - ---------------------- UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (_scrollView.zoomScale > _scrollView.maximumZoomScale){
        [_scrollView setZoomScale:_scrollView.maximumZoomScale animated:YES];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    //放大过程中需要设置图片的中心点
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) / 2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) / 2 : 0.0;
    _imageView.center = CGPointMake(scrollView.contentSize.width / 2 + offsetX,scrollView.contentSize.height / 2 + offsetY);
}

@end

#pragma mark - ViewController
@interface PhotoPreviewController ()<UICollectionViewDelegate, UICollectionViewDataSource, PhotoPreviewItemDelegate>

@end

static NSString *const itemIdentifier = @"PhotoPreviewItem";

@implementation PhotoPreviewController{
    UICollectionView    *_collectionView;
    UIView              *_topView;
    UIButton            *_chooseBtn;
    UIView              *_bottomView;
    UIButton            *_sendBtn;
}

- (void)dealloc{
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setCollectionView];
    [self setTopView];
    [self setBottomView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - ---------------------- UI
- (void)setTopView{
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.viewWidth, 64)];
    _topView.backgroundColor = [[UIColor colorWithHexString:@"#101011"] colorWithAlphaComponent:0.84];
    [self.view addSubview:_topView];
    
    //标题
    UILabel *titleLabel = [UILabel labelWithFrame:CGRectZero text:@"预览" fontSize:18 textColor:[UIColor whiteColor] line:1];
    [titleLabel sizeToFit];
    titleLabel.viewY = 20;
    titleLabel.viewHeight = 44;
    titleLabel.centerX = _topView.viewWidth / 2;
    [_topView addSubview:titleLabel];
    
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithFrame:CGRectMake(0, 20, 65, 44) target:self action:@selector(onClickBack)];
    [backBtn setImage:[UIImage imageNamed:@"nav_back_white"] forState:UIControlStateNormal];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);
    [_topView addSubview:backBtn];
    
    //选择按钮
    _chooseBtn = [UIButton buttonWithFrame:CGRectMake(_topView.viewWidth - 47, 20, 47, 44) target:self action:@selector(onClickChoose)];
    [_chooseBtn setImage:[UIImage imageNamed:@"item_unselect_photo"] forState:UIControlStateNormal];
    [_chooseBtn setImage:[UIImage imageNamed:@"item_selected_photo"] forState:UIControlStateSelected];
    [_topView addSubview:_chooseBtn];
    
    [self updateChooseBtnStateForModel:_dataSource[_currentIndex]];
}

- (void)updateChooseBtnStateForModel:(PhotoMultiselectModel *)model{
    _chooseBtn.selected = model.isSelected;
}

- (void)setBottomView{
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 49, [UIScreen mainScreen].bounds.size.width, 49)];
    _bottomView.backgroundColor = [[UIColor colorWithHexString:@"#101011"] colorWithAlphaComponent:0.67f];
    [self.view addSubview:_bottomView];
    
    //发送按钮
    _sendBtn = [UIButton buttonWithFrame:CGRectMake(0, 0, 83, 32) target:self action:@selector(onClickSend)];
    _sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_sendBtn setCornerRadiur:3];
    _sendBtn.centerY = _bottomView.viewHeight / 2;
    _sendBtn.viewX = _bottomView.viewWidth - 12 - _sendBtn.viewWidth;
    [_bottomView addSubview:_sendBtn];
    
    [self updateBottomView];
}

- (void)updateBottomView{
    [_sendBtn setTitle:[NSString stringWithFormat:@"确定(%zi/%zi)", _selectedModelList.count, self.maxCount] forState:UIControlStateNormal];
    _sendBtn.backgroundColor = _selectedModelList.count > 0 ? [UIColor colorWithHexString:@"#3d8eff"] : [UIColor colorWithHexString:@"#CED0D6"];
}

- (void)setCollectionView{
    CGFloat itemWidth = [UIScreen mainScreen].bounds.size.width + outOffset * 2;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(itemWidth, [UIScreen mainScreen].bounds.size.height);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-outOffset, 0, itemWidth, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.alwaysBounceHorizontal = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = self.view.backgroundColor;
    _collectionView.pagingEnabled = YES;
    [_collectionView registerClass:PhotoPreviewItem.class forCellWithReuseIdentifier:itemIdentifier];
    [self.view addSubview:_collectionView];
    _collectionView.contentOffset = CGPointMake(self.currentIndex * _collectionView.viewWidth, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoPreviewItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:itemIdentifier forIndexPath:indexPath];
    item.model = _dataSource[indexPath.row];
    item.delegate = self;
    return item;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //设置当前model选中状态，如果在滑动过程中且滑动距离超过scrollView宽度的一半，则获取下一个model的选中状态
    CGFloat offsetX = scrollView.contentOffset.x / scrollView.viewWidth;
    NSInteger index = scrollView.contentOffset.x / scrollView.viewWidth;
    
    PhotoMultiselectModel *model = _dataSource[index];
    if (offsetX >= index + 0.5f) {
        if (index + 1 < _dataSource.count) {
            model = _dataSource[index + 1];
        }
    }
    [self updateChooseBtnStateForModel:model];
}

#pragma mark - ---------------------- PhotoPreviewItemDelegate
- (void)singleTapScrollView{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        _topView.viewY = _topView.viewY == 0 ? -_topView.viewHeight : 0;
        _bottomView.viewY = _bottomView.viewY == screenHeight ? screenHeight - _bottomView.viewHeight : screenHeight;
    }];
}

#pragma mark - ---------------------- 事件
- (void)onClickBack{
    if (_onClickBackCallback) {
        _onClickBackCallback(self.selectedModelList);
        _onClickBackCallback = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onClickChoose{
    //设置当前model选中状态
    NSInteger index = _collectionView.contentOffset.x / _collectionView.viewWidth;
    PhotoMultiselectModel *model = _dataSource[index];
    if (self.selectedModelList.count >= self.maxCount && !model.isSelected) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:@"最多选择%zi张照片", self.maxCount]
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    model.isSelected = !model.isSelected;
    if (self.maxCount == 1) {
        if (model.isSelected) {
            [self.selectedModelList removeAllObjects];
            [self.selectedModelList addObject:model];
        }else{
            [self.selectedModelList removeAllObjects];
        }
    }else{
        if (model.isSelected) {
            if (![self.selectedModelList containsObject:model]) {
                [self.selectedModelList addObject:model];
            }
        }else{
            if ([self.selectedModelList containsObject:model]) {
                [self.selectedModelList removeObject:model];
            }
        }
    }
    [self updateChooseBtnStateForModel:model];
    [self updateBottomView];
}

- (void)onClickSend{
    if (_selectedModelList.count > 0) {
        if (_onClickSendCallback) {
            _onClickSendCallback(self.selectedModelList);
            _onClickSendCallback = nil;
        }
    }
}

@end
