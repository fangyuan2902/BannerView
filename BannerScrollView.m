//
//  BannerScrollView.m
//  ProjectDemo
//
//  Created by 方远 on 2017/3/2.
//  Copyright © 2017年 方远. All rights reserved.
//

#import "BannerScrollView.h"
#import "DefineConst.h"
#import <UIImageView+WebCache.h>
#define  imageViewCount 3

@implementation PageControlView {
    NSMutableArray *_imageArr;
}

- (instancetype)init {
    self  = [super init];
    if (self) {
        _imageArr = [NSMutableArray array];
    }
    return self;
}

- (void)setCount:(NSInteger)count {
    _count = count;
    self.frame = CGRectMake(0, 0, 28 * count + 8, 20);
    [_imageArr removeAllObjects];
    for (int i = 0; i < count; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(28 * i, 0, 20, 20);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
        if (i == 0) {
            imageView.backgroundColor = self.currentColor ? self.currentColor : [UIColor blackColor];
        } else {
            imageView.backgroundColor = self.nomalColor ? self.nomalColor : [UIColor whiteColor];
        }
        [_imageArr addObject:imageView];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    for (int i = 0; i < _imageArr.count; i++) {
        UIImageView *imageView = [_imageArr objectAtIndex:i];
        if (i == currentPage) {
            imageView.backgroundColor = self.currentColor ? self.currentColor : [UIColor whiteColor];
        } else {
            imageView.backgroundColor = self.nomalColor ? self.nomalColor : [UIColor blackColor];
        }
    }
}

- (void)setCurrentColor:(UIColor *)currentColor {
    _currentColor = currentColor;
    [self setCurrentPage:_currentPage];
}

- (void)setNomalColor:(UIColor *)nomalColor {
    _nomalColor = nomalColor;
    [self setCurrentPage:_currentPage];
}

@end

@interface BannerScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) PageControlView * pageControl;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation BannerScrollView

- (void)setImages:(NSArray<NSString *> *)images {
    _images = images;
    [self setScrollView];
    [self setPageControl];
    if (_timer == nil) {
        [self startTimer];
    }
    [self updateImage];
}

- (void)setScrollView {
    if (self.scrollView == nil) {
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.frame = CGRectMake(0, 0, SCREENWIDTH, 32 * SCREENWIDTH / 75.f);
        self.scrollView.contentSize = CGSizeMake(imageViewCount * self.frame.size.width, 0);
        
        for (NSUInteger i = 0; i < imageViewCount; i++) {
            UIImageView *imageV = [[UIImageView alloc]init];
            imageV.frame = CGRectMake(i * SCREENWIDTH, 0, SCREENWIDTH, 32 * SCREENWIDTH / 75.f);
            [self.scrollView addSubview:imageV];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
            [imageV addGestureRecognizer:tap];
        }
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.delegate = self;
        self.scrollView.bounces = NO;
        self.scrollView.pagingEnabled = YES;
        [self addSubview:self.scrollView];
    }
}

- (void)setPageControl {
    if (_pageControl == nil) {
        _pageControl = [[PageControlView alloc] init];
        _pageControl.count = self.images.count;
        _pageControl.currentPage = 0;
        _pageControl.currentColor = [UIColor redColor];
        _pageControl.nomalColor = [UIColor whiteColor];
        _pageControl.center = CGPointMake(SCREENWIDTH / 2.0,self.scrollView.frame.size.height - 15);
        [self addSubview:_pageControl];
    }
}

- (void)updateImage {//更新图片
    for (NSUInteger i = 0; i < self.scrollView.subviews.count; i++) {//取出scrollview 上的三个子试图 imageView
        UIImageView *imagV = self.scrollView.subviews[i];
        NSInteger index = _pageControl.currentPage;//拿到当前显示的页数
        if (i == 0) {//如果是第一张imageView，也就是最左边的那张imageView
            index--;//显示的图片应该是当前页数 -1
        }else if(i == 2) {//如果是第三张imageView，也就是最右边的imageView
            index++;//显示的图片应该是当前页数 +1
        }
        if (index < 0) {//如果inde < 0 把页数重置位最后一张
            index = self.images.count - 1;
        }else if(index >= self.images.count) {
            index = 0;//将右边的imageView的currentpage设为0
        }
        imagV.tag = index;//设置 iamge 的tag 值
        
        [imagV sd_setImageWithURL:[NSURL URLWithString:self.images[index]] placeholderImage:nil options:SDWebImageAllowInvalidSSLCertificates];
        imagV.userInteractionEnabled = YES;//设置允许点击
    }
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);//始终让 偏移 量停留在最中间的这张
}

- (void)tapClick:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(bannerTappedIndex:)]) {
        [self.delegate bannerTappedIndex:tap.view.tag];//代理传值
    }
}

- (void)next {//动画显示第二张
    [self.scrollView setContentOffset:CGPointMake(2 * self.scrollView.frame.size.width, 0) animated:YES];
}

#pragma mark -
#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startTimer];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateImage];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self updateImage];
}

//在此方法中 设置pageControl 的page
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = 0;
    CGFloat minDistance = MAXFLOAT;
    for (int i = 0; i<self.scrollView.subviews.count; i++) {
        UIImageView *imageView = self.scrollView.subviews[i];
        CGFloat distance = 0;
        distance = ABS(imageView.frame.origin.x - scrollView.contentOffset.x);
        if (distance < minDistance) {
            minDistance = distance;
            page = imageView.tag;
        }
    }
    _pageControl.currentPage = page;
}

#pragma mark - 定时器相关
- (void)startTimer {//开启定时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(next) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}

-(void)stopTimer {//结束定时器
    [self.timer invalidate];
    self.timer = nil;
}

@end
