//
//  ViewController.m
//  PhotoMultiselect
//
//  Created by lidp on 2016/11/17.
//  Copyright © 2016年 lidp. All rights reserved.
//

#import "ViewController.h"
#import "PhotoGroupListViewController.h"

@implementation ResultCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

@end

@interface ViewController ()

@end

static NSString * const reuseIdentifier = @"Cell";
@implementation ViewController{
    NSMutableArray  *_dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataSource = [NSMutableArray new];
    [self.collectionView registerClass:ResultCell.class forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ResultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.imageView.image = _dataSource[indexPath.row];
    return cell;
}

- (IBAction)showPhotoVC:(id)sender {
    [PhotoGroupListViewController showPhotoPhotoMultiselectVCWithFromVC:self count:9 selectedImageCallback:^(NSMutableArray *imageList) {
        _dataSource = imageList;
        [self.collectionView reloadData];
    }];
}

@end
