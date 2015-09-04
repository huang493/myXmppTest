//
//  EmotionView.m
//  tt3
//
//  Created by hsm on 15/8/2.
//  Copyright (c) 2015年 apple. All rights reserved.
//
/****************************************************
 黄诗猛：
 1.UICollectionView,如果使用多个UICollectionView，则在reload的
 时候，有可能会出现：Assertion failure in -[UICollectionViewData validateLayoutInRect:]
 报错。解决：reload的时候不能使用同一个collectionViewLayout,可以重新alloc一个新的。
 ****************************************************/
#import "EmotionView.h"
#define BigCellTagBeginNumber  20000
#define SamollCellTagBeginNumber 10000
#define EmoticonTipsTag    100
#define imgViewTag         101
#define imgSelectedTag     102

#define PageCount (ceilf( (CGFloat)itemCounts / [self getPreCount]))


@implementation EmotionView
{
    UICollectionViewFlowLayout *layout;
    UICollectionViewFlowLayout *samollLayOut;
    CGFloat   minRowSpace;
    CGFloat   minColumnSpace;
    UIEdgeInsets contentEdg;
    CGFloat   factory;
    NSInteger itemCounts;
    NSInteger totalCounts;
    CGSize    itemSize;
    NSArray   *preCountList;    //保存这不同屏幕大小，不同表情下，单页的表情个数
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self loadProperty];
        [self loadLayout];
        [self addBigCollectionView];
        [self addPageControllerView];
        [self addEmotionChangeView];
        
    }
    return self;
}

-(void)loadProperty{
    /* preCountList 适配使用
     [2][3]
     QQEmotion   5s, 6, 6p
     others      5s, 6, 6p
     */
    preCountList = @[@18,@21,@24,@8,@10,@12];
    factory = 1;//SCREENWIDTH / 320.0;
    minRowSpace = 18.5;
    minColumnSpace = 15;
    contentEdg = UIEdgeInsetsMake(10, 10, 10, 10);
    itemCounts = 43;
    totalCounts = PageCount*[self getPreCount];
    itemSize = CGSizeMake(35, 35);
    _emotionType = QQEmotion;
    
}

-(void)loadLayout{
    //bigCollectionView layout
    layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    
    //smallCollectionView layout
    samollLayOut = [[UICollectionViewFlowLayout alloc] init];
    samollLayOut.minimumInteritemSpacing = minColumnSpace;
    samollLayOut.minimumLineSpacing = minRowSpace;
    samollLayOut.sectionInset = contentEdg;
    samollLayOut.scrollDirection = UICollectionViewScrollDirectionVertical;
}
#pragma -mark addSubViews
-(void)addBigCollectionView{
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 155) collectionViewLayout:layout];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"bigcell"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:_collectionView];
}

-(void)addPageControllerView{
    _pageC = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame)+2, self.bounds.size.width, 8)];
    _pageC.numberOfPages =  PageCount;
    _pageC.currentPageIndicatorTintColor = [UIColor purpleColor];
    _pageC.pageIndicatorTintColor = [UIColor lightGrayColor];
    [_pageC addTarget:self action:@selector(pageCAction:) forControlEvents:UIControlEventValueChanged];
    _pageC.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:_pageC];
}
-(void)addEmotionChangeView{
    NSArray *arr = @[
                     [[UIImage imageNamed:@"[@000]"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                     [[UIImage imageNamed:@"GOIMEggEmotionBg"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                     [[UIImage imageNamed:@"carEmotion"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                     [[UIImage imageNamed:@"hjy"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                     [[UIImage imageNamed:@"add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                     ];
    
    _sectionView = [[SectionView alloc] initWithFrame:CGRectMake(0, 165, SCREENWIDTH, 35)];
    _sectionView.imgs = arr;
    __weak EmotionView   *weakSelf = self;
    _sectionView.clickSection = ^(NSInteger index){
        [weakSelf sectionsClickAction:(enum EmotionType)index];
    };
    [_sectionView addSubviews];
    _sectionView.backgroundColor = [UIColor whiteColor];
    
    
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:_sectionView];
}



-(void)pageCAction:(UIPageControl *)pageC{
    
    
    [UIView animateWithDuration:0.25 animations:^{
        _collectionView.contentOffset = CGPointMake(pageC.currentPage * self.frame.size.width, 0);
    }];
    
    
}

-(void)sectionsClickAction:(enum EmotionType )emotionType{
    
    if (emotionType == _emotionType) {
        return ;
    }
    
    /*
     QQEmotion = 0,
     EggEmotion,
     CarEmotion,
     HjyEmotion,
     Other
     */
    switch (emotionType) {
        case QQEmotion:
        {
            itemCounts = 43;
            itemSize = CGSizeMake(35, 35);
            minRowSpace = 18.5;
            minColumnSpace = 10.0;
            _emotionType = QQEmotion;
        }
            break;
        case EggEmotion:
        {
            itemCounts = 25;
            itemSize = CGSizeMake(55, 55);//CGSizeMake(55*factory, 55*factory);
            minRowSpace = 25*factory;
            minColumnSpace = 10.0 / factory;
            _emotionType = EggEmotion;


        }
            break;
        case CarEmotion:
        {
            itemCounts = 17;
            itemSize = CGSizeMake(55, 55);//CGSizeMake(55*factory, 55*factory);
            minRowSpace = 25*factory;
            minColumnSpace = 10.0 / factory;
            _emotionType = CarEmotion;


        }
            break;
        case HjyEmotion:
        {
            itemCounts = 20;
            itemSize = CGSizeMake(55, 55);//CGSizeMake(55*factory, 55*factory);
            minRowSpace = 25*factory;
            minColumnSpace = 10.0 / factory;
            _emotionType = HjyEmotion;


        }
            break;
        case Other:
        {
            itemCounts = 43;
            itemSize = CGSizeMake(55, 55);//CGSizeMake(55*factory, 55*factory);
            minRowSpace = 25*factory;
            minColumnSpace = 10.0 / factory;
            contentEdg = UIEdgeInsetsMake(10, 15*factory, 10, 15*factory);
            _emotionType = Other;


        }
            break;
            
        default:
            break;
    }
    
    //itemTotal setUp
    _pageC.numberOfPages = PageCount;
    totalCounts = _pageC.numberOfPages *  [self getPreCount];
    _pageC.currentPage = 0;
    
    
    
    //_collectionView Reload setUp
//    _collectionView.contentOffset = CGPointMake(0, 0);
//    samollLayOut.minimumLineSpacing = minRowSpace;
//    samollLayOut.minimumInteritemSpacing = minColumnSpace;
//    samollLayOut.sectionInset = contentEdg;
    [self loadLayout];
    [_collectionView reloadData];

}


#pragma -mark UIScrolViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGFloat y = scrollView.contentOffset.x / self.bounds.size.width;
    _pageC.currentPage = ceilf(y);
}


#pragma -mark UICollectionDetegate&UICollectionDataDelegate
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView == _collectionView) {
        return _collectionView.frame.size;
    }
    else{
        return  itemSize;
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == _collectionView) {
        return PageCount;
    }
    else{
        return [self getPreCount];
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (collectionView == _collectionView) {
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bigcell" forIndexPath:indexPath];
        cell.contentView.tag = BigCellTagBeginNumber + indexPath.row;
        UICollectionView *collectV = [[UICollectionView alloc] initWithFrame:cell.contentView.frame collectionViewLayout:samollLayOut];
        collectV.delegate = self;
        collectV.dataSource = self;
        collectV.showsVerticalScrollIndicator = NO;
        collectV.scrollEnabled = NO;
        [collectV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"samollcell"];
        collectV.backgroundColor = [UIColor whiteColor];

        [cell.contentView addSubview:collectV];
        
        return cell;
    }
    else{
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"samollcell" forIndexPath:indexPath];
        //cell.tag以1000开头
        cell.tag = SamollCellTagBeginNumber + (collectionView.superview.tag - BigCellTagBeginNumber) * 100 + indexPath.row;
        UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:imgViewTag];
        
        cell.hidden = NO;
        
        
        if (imgView == nil ) {
            
            imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height)];
            imgView.tag = imgViewTag;
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.userInteractionEnabled = YES;
            UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(emotionLongPressAction:)];
            [imgView addGestureRecognizer:tap];
            [cell.contentView addSubview:imgView];
        }
        
        NSInteger pictureIndex = (collectionView.superview.tag - BigCellTagBeginNumber)*[self getPreCount] + (long)indexPath.row;
        NSString *imgName = [self getPictureNameByIndex:pictureIndex];
        
        imgView.image = [UIImage imageNamed:imgName];
        
        if ((collectionView.superview.tag - BigCellTagBeginNumber)*[self getPreCount]+indexPath.row>=itemCounts) {
            cell.hidden = YES;
        }
        
        return cell;
    }
    

}


-(void)emotionLongPressAction:(UITapGestureRecognizer *)tap{
    //获取图片名
    NSInteger tmp = tap.view.superview.superview.tag - SamollCellTagBeginNumber;
    NSInteger index = tmp/100*[self getPreCount] + tmp%100;
    NSString *emoName = [self getPictureNameByIndex:index];
    
    if (tap.state == UIGestureRecognizerStateBegan) {
        //添加提示大图
        CGRect frame = tap.view.frame;
        frame = [tap.view convertRect:frame toView:self];
        frame.origin.y = CGRectGetMaxY(frame) - itemSize.height*2;
        frame  = CGRectMake(frame.origin.x - 10.0, frame.origin.y , itemSize.width + 20, itemSize.height*2);
        
        
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:frame];
        imgV.tag = EmoticonTipsTag;
        imgV.image = [UIImage  imageNamed:@"EmoticonTips"];
        
        
        UIImageView *emImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemSize.width*1.3, itemSize.height*1.3)];
        emImgV.center = CGPointMake(imgV.frame.size.width/2, imgV.frame.size.height/4 + 8);
        emImgV.tag = imgSelectedTag;

        emImgV.image = [UIImage imageNamed:emoName];
        [imgV addSubview:emImgV];
        [self addSubview:imgV];
        
    }
    else if(tap.state == UIGestureRecognizerStateEnded){
        //删除提示大图
        for (UIView *vi in [self subviews]) {
            if (vi.tag == EmoticonTipsTag) {
                
                if (_selectPictureBlock) {
                    
                    if (_emotionType == QQEmotion) {
                        _selectPictureBlock(emoName,nil,Text);

                    }
                    else if (_emotionType == EggEmotion || _emotionType == CarEmotion || _emotionType == HjyEmotion){
                        UIImageView *imgView = (UIImageView *)[vi viewWithTag:imgSelectedTag];
                        NSData *data = UIImageJPEGRepresentation(imgView.image, 1.0);
                        _selectPictureBlock(nil,data,Image);
                    }
                    else {
#pragma -mark TODO:其他类型的图片的转换，回传等操作。
                    }

                    
                }
                
                [vi removeFromSuperview];
                break;
            }
        }
        
    }
    
}

-(NSString *)getPictureNameByIndex:(NSInteger)index{
    NSString *emoName = nil;
    switch (_emotionType) {
        case QQEmotion:
        {
            emoName = [NSString stringWithFormat:@"[@%03ld]",(long)index];
        }
            break;
        case EggEmotion:
        {
            emoName = [NSString stringWithFormat:@"[@pic%03ld]",(long)index + 19];
        }
            break;
        case CarEmotion:
        {
            emoName = [NSString stringWithFormat:@"[@pic%03ld]",(long)index+ 64];
        }
            break;
        case HjyEmotion:
        {
            emoName = [NSString stringWithFormat:@"[@pic%03ld]",(long)index + 44];
        }
            break;
        case Other:
        {
            emoName = [NSString stringWithFormat:@"[@pic%03ld]",(long)index];
        }
            break;
            
        default:
            break;
    }
    return emoName;
}
/*
 iphone screen width list:
 640x1136
 750x1334
 1242x2208
 */

/* preCountList 适配使用
 [2][3]
 QQEmotion   5s, 6, 6p
 others      5s, 6, 6p
 */

-(NSInteger)getPreCount{
    //@[@18,@21,@24,@8,@10,@12];
    NSInteger count = 0;
    if (SCREENWIDTH == 320) {
        
        if (_emotionType == QQEmotion) {
            count = [preCountList[0] integerValue];
        }
        else {
            count = [preCountList[3] integerValue];
        }
    }
    else if(SCREENWIDTH == 375)
    {
        if (_emotionType == QQEmotion) {
            count = [preCountList[1] integerValue];
        }
        else {
            count = [preCountList[4] integerValue];
        }
    }
    else if(SCREENWIDTH == 414){
        if (_emotionType == QQEmotion) {
            count = [preCountList[2] integerValue];
        }
        else {
            count = [preCountList[5] integerValue];
        }

    }
    return count;
}


@end
