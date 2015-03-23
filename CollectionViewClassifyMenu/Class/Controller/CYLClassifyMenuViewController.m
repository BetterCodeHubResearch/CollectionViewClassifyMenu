
//  CYLClassifyMenuViewController.m
//  CollectionViewClassifyMenu
//
//  Created by chenyilong on 15/3/17.
//  Copyright (c) 2015年 chenyilong. All rights reserved.
//
#define kCollectionViewCellsHorizonMargin 12
#define kCollectionViewCellHeight 30

#define kCollectionViewToLeftMargin 16
#define kCollectionViewToTopMargin 12
#define kCollectionViewToRightMargin 16
#define kCollectionViewToBottomtMargin 10

#define kCellImageToLabelMargin 10
#define kCellBtnCenterToBorderMargin 10
#import "CYLClassifyMenuViewController.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "CollectionViewCell.h"
#import "FilterHeaderView.h"
#import "MJExtension.h"

static NSString * const kCellIdentifier = @"CellIdentifier";
static NSString * const kHeaderViewCellIdentifier = @"HeaderViewCellIdentifier";

@interface CYLClassifyMenuViewController () <UICollectionViewDataSource,UICollectionViewDelegate,FilterHeaderViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) float priorCellY;
@property (nonatomic, assign) int rowLine;
@property (nonatomic, strong) NSMutableArray *collectionHeaderMoreBtnHideBoolArray;
@property (nonatomic, strong) NSMutableArray *firstLineWidthArray;
@property (nonatomic, strong) NSMutableArray *firstLineCellCountArray;
@property (nonatomic, strong) NSMutableArray *expandSectionArray;
@end

@implementation CYLClassifyMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self addCollectionView];
    [self judgeMoreBtnShow];
    self.view.backgroundColor = [UIColor blueColor];
}

- (NSMutableArray *)collectionHeaderMoreBtnHideBoolArray
{
    if (_collectionHeaderMoreBtnHideBoolArray == nil) {
        _collectionHeaderMoreBtnHideBoolArray = [[NSMutableArray alloc] init];
    }
    return _collectionHeaderMoreBtnHideBoolArray;
}

- (NSMutableArray *)firstLineWidthArray
{
    if (_firstLineWidthArray == nil) {
        _firstLineWidthArray = [[NSMutableArray alloc] init];
    }
    return _firstLineWidthArray;
}

- (NSMutableArray *)firstLineCellCountArray
{
    if (_firstLineCellCountArray == nil) {
        _firstLineCellCountArray = [[NSMutableArray alloc] init];
    }
    return _firstLineCellCountArray;
}

- (NSMutableArray *)expandSectionArray
{
    if (_expandSectionArray == nil) {
        _expandSectionArray = [[NSMutableArray alloc] init];
    }
    return _expandSectionArray;
}


- (void)initData {
    self.firstLineWidthArray = [NSMutableArray array];
    self.firstLineCellCountArray = [NSMutableArray array];
    self.rowLine = 0;
    self.collectionHeaderMoreBtnHideBoolArray = [NSMutableArray array];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    //    [json writeToFile:@"/Users/chenyilong/Documents/123.plist" atomically:YES];
    self.dataSource = [NSMutableArray arrayWithArray:json];
}

- (void)judgeMoreBtnShow {
    [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *symptoms = [NSArray arrayWithArray:[obj objectForKey:@"Symptoms"]];
        NSMutableArray *widthArray = [NSMutableArray array];
        __block int firstLineCellCount = 0;
        [symptoms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *text = [obj objectForKey:@"Patient_Name"];
            CGSize size = [text sizeWithAttributes:
                           @{NSFontAttributeName:
                                 [UIFont systemFontOfSize:16]}];
            //            float textWidth = size.width;
            float cellImageToLabelMargin = 0;
            float textAndImageWidth;
            if (obj == [symptoms lastObject]) {
                textAndImageWidth = size.width+cellImageToLabelMargin+kCellBtnCenterToBorderMargin;
            } else {
                textAndImageWidth = size.width+cellImageToLabelMargin+kCellBtnCenterToBorderMargin+kCollectionViewCellsHorizonMargin;
            }
            [widthArray  addObject:@(textAndImageWidth)];
            NSArray *sumArray = [NSArray arrayWithArray:widthArray];
            NSNumber* sum = [sumArray valueForKeyPath: @"@sum.self"];
            if ([sum intValue]<(self.collectionView.frame.size.width-kCollectionViewToLeftMargin-kCollectionViewToRightMargin)||[sum intValue]==(self.collectionView.frame.size.width-kCollectionViewToLeftMargin-kCollectionViewToRightMargin)) {
                firstLineCellCount ++;
            }
        }];
        [self.firstLineCellCountArray addObject:@(firstLineCellCount)];
        NSArray *sumArray = [NSArray arrayWithArray:widthArray];
        NSNumber* sum = [sumArray valueForKeyPath: @"@sum.self"];
        [self.firstLineWidthArray addObject:sum];
        [self.firstLineWidthArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj intValue]> (self.collectionView.frame.size.width-kCollectionViewToLeftMargin-kCollectionViewToRightMargin)) {
                [self.collectionHeaderMoreBtnHideBoolArray addObject:@NO];
            } else {
                [self.collectionHeaderMoreBtnHideBoolArray addObject:@YES];
            }
        }];
    }];
}

- (void)addCollectionView {
    CGRect collectionViewFrame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-40);
    UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:layout];
    //    layout.headerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, CYLFilterHeaderViewHeigt);  //设置head大小
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[FilterHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewCellIdentifier];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    self.collectionView.scrollsToTop = NO;
    //    self.collectionView.scrollEnabled = NO;
    [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.dataSource count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *symptoms = [NSArray arrayWithArray:[self.dataSource[section] objectForKey:@"Symptoms"]];
    for (NSNumber *ii in self.expandSectionArray) {
        if (section == [ii integerValue]) {
            return [symptoms count];
        }
    }
    return [self.firstLineCellCountArray[section] integerValue];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.button.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    NSMutableArray *symptoms = [NSMutableArray arrayWithArray:[self.dataSource[indexPath.section] objectForKey:@"Symptoms"]];
    NSString *text = [symptoms[indexPath.row] objectForKey:@"Patient_Name"];
    [cell.button setTitle:text forState:UIControlStateNormal];
    [cell.button setTitle:text forState:UIControlStateSelected];
    [cell.button addTarget:self action:@selector(itemButtonClicked:)
        forControlEvents:UIControlEventTouchUpInside];
    cell.button.section = indexPath.section;
    cell.button.row = indexPath.row;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        FilterHeaderView *filterHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewCellIdentifier forIndexPath:indexPath];
        filterHeaderView.moreButton.hidden = [self.collectionHeaderMoreBtnHideBoolArray[indexPath.section] boolValue];
        filterHeaderView.delegate = self;
        NSString *sectionTitle = [self.dataSource[indexPath.section] objectForKey:@"Type"];
        filterHeaderView.titleButton.tag = indexPath.section;
        filterHeaderView.moreButton.tag = indexPath.section;
        filterHeaderView.moreButton.selected = NO;
        [filterHeaderView.titleButton setTitle:sectionTitle forState:UIControlStateNormal];
        [filterHeaderView.titleButton setTitle:sectionTitle forState:UIControlStateSelected];
        if((int)[[self.firstLineWidthArray objectAtIndex:indexPath.section] intValue]> self.collectionView.frame.size.width-kCollectionViewToLeftMargin-kCollectionViewToRightMargin) {
        } else {
            filterHeaderView.moreButton.hidden = YES;
        }
        switch (indexPath.section) {
            case 0:
                [filterHeaderView.titleButton setImage:[UIImage imageNamed:@"home_btn_face"] forState:UIControlStateNormal];
                break;
            case 1:
                [filterHeaderView.titleButton setImage:[UIImage imageNamed:@"home_btn_common"] forState:UIControlStateNormal];
                break;
            case 2:
                [filterHeaderView.titleButton setImage:[UIImage imageNamed:@"home_btn_child"] forState:UIControlStateNormal];
                break;
            case 3:
                [filterHeaderView.titleButton setImage:[UIImage imageNamed:@"home_btn_cosmetic"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        for (NSNumber *ii in self.expandSectionArray) {
            if (indexPath.section == [ii integerValue]) {
                filterHeaderView.moreButton.selected = YES;
            }
        }
        return (UICollectionReusableView *)filterHeaderView;
    }
    return nil;
}

- (void)itemButtonClicked:(CYLIndexPathButton *)button
{
    //二级菜单数组
    NSArray *symptoms = [NSArray arrayWithArray:[self.dataSource[button.section] objectForKey:@"Symptoms"]];
    NSString *sectionTitle = [self.dataSource[button.section] objectForKey:@"Type"];
    NSString *cellTitle = [symptoms[button.row] objectForKey:@"Patient_Name"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:cellTitle message:sectionTitle delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - FilterHeaderViewDelegateMethod
-(void)filterHeaderViewMoreBtnClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.expandSectionArray addObject:[NSNumber numberWithInteger:sender.tag]];
    } else {
        [self.expandSectionArray removeObject:[NSNumber numberWithInteger:sender.tag]];
    }
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag]];
    } completion:nil];
}

#pragma mark - UICollectionViewDelegateLeftAlignedLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *symptoms = [NSArray arrayWithArray:[self.dataSource[indexPath.section] objectForKey:@"Symptoms"]];
    NSString *text = [symptoms[indexPath.row] objectForKey:@"Patient_Name"];
    CGSize size = [text sizeWithAttributes:
                   @{NSFontAttributeName:
                         [UIFont systemFontOfSize:16]}];
    return CGSizeMake(ceilf(size.width) + kCellBtnCenterToBorderMargin, kCollectionViewCellHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kCollectionViewCellsHorizonMargin;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 38);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kCollectionViewToTopMargin, kCollectionViewToLeftMargin, kCollectionViewToBottomtMargin, kCollectionViewToRightMargin);
}

@end
