//
//  BannerScrollView.h
//  ProjectDemo
//
//  Created by 方远 on 2017/3/2.
//  Copyright © 2017年 方远. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageControlView : UIView 

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) UIColor *currentColor;
@property (nonatomic, strong) UIColor *nomalColor;

@end

@protocol BannerScrollViewDelegate <NSObject>

- (void)bannerTappedIndex:(NSInteger)index;

@end

@interface BannerScrollView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImage *defaultImage;
@property (nonatomic, strong) NSArray<NSString *> *images;
@property (nonatomic, weak) id<BannerScrollViewDelegate> delegate;

- (void)startTimer;
-(void)stopTimer;

@end

