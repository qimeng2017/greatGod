//
//  LNScrollerView.m
//  LotteryNews
//
//  Created by 邹壮壮 on 2017/3/20.
//  Copyright © 2017年 邹壮壮. All rights reserved.
//

#import "LNScrollerView.h"
#import "TriolionTopAdModel.h"
@interface LNScrollerView (){
    CGRect viewSize;
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    NSInteger currentPageIndex;
    UILabel *noteTitle;
    NSMutableArray *tempArray;
}

@end
@implementation LNScrollerView
@synthesize delegate;
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
      viewSize=frame;
      scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, viewSize.size.width, viewSize.size.height)];
      scrollView.pagingEnabled = YES;
      scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.scrollsToTop = NO;
        scrollView.delegate = self;
        [scrollView setContentOffset:CGPointMake(viewSize.size.width, 0)];
        [self addSubview:scrollView];
        //说明文字层
        UIView *noteView=[[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-33,self.bounds.size.width,33)];
        [noteView setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5]];
        

        pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(self.frame.size.width,6, 0, 0)];
        pageControl.currentPage=0;
        [noteView addSubview:pageControl];
        noteTitle=[[UILabel alloc] initWithFrame:CGRectMake(5, 6, self.frame.size.width-15, 20)];
        [noteTitle setBackgroundColor:[UIColor clearColor]];
        [noteTitle setFont:[UIFont systemFontOfSize:14]];
       [noteView addSubview:noteTitle];
        
        [self addSubview:noteView];
    }
    return self;
}
- (void)setImageArray:(NSArray *)imageArray{
    for (UIView *view in scrollView.subviews) {
        [view removeFromSuperview];
    }
    _imageArray = imageArray;
    if (_imageArray.count > 0) {
       TriolionTopAdModel *firstModel = [_imageArray objectAtIndex:0];
        noteTitle.text = firstModel.title;
    }
    
    tempArray=[NSMutableArray arrayWithArray:imageArray];
    [tempArray insertObject:[imageArray objectAtIndex:([imageArray count]-1)] atIndex:0];
    [tempArray addObject:[imageArray objectAtIndex:0]];
    NSUInteger pageCount=[tempArray count];
    scrollView.contentSize = CGSizeMake(viewSize.size.width * pageCount, viewSize.size.height);
    for (int i=0; i<pageCount; i++) {
        TriolionTopAdModel *model=[tempArray objectAtIndex:i];
        UIImageView *imgView=[[UIImageView alloc] init];
        if ([model.imgLink hasPrefix:@"http://"]||[model.imgLink hasPrefix:@"https://"]) {
            //网络图片 请使用ego异步图片库
            [imgView sd_setImageWithURL:[NSURL URLWithString:model.imgLink] placeholderImage:nil options:SDWebImageRefreshCached];
        }
        else
        {
            
            UIImage *img=[UIImage imageNamed:[tempArray objectAtIndex:i]];
            [imgView setImage:img];
        }
        
        [imgView setFrame:CGRectMake(viewSize.size.width*i, 0,viewSize.size.width, viewSize.size.height)];
        imgView.tag=i;
        UITapGestureRecognizer *Tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagePressed:)];
        [Tap setNumberOfTapsRequired:1];
        [Tap setNumberOfTouchesRequired:1];
        imgView.userInteractionEnabled=YES;
        [imgView addGestureRecognizer:Tap];
        [scrollView addSubview:imgView];
    }
    float pageControlWidth=(pageCount-2)*10.0f+40.f;
    float pagecontrolHeight=20.0f;
    pageControl.frame = CGRectMake((self.frame.size.width-pageControlWidth),6, pageControlWidth, pagecontrolHeight);
     pageControl.numberOfPages=(pageCount-2);
}
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    currentPageIndex=page;
    
    pageControl.currentPage=(page-1);
    NSInteger titleIndex=page-1;
    if (titleIndex==[_imageArray count]) {
        titleIndex=0;
    }
    if (titleIndex<0) {
        titleIndex=[_imageArray count]-1;
   }
    TriolionTopAdModel *model=[_imageArray objectAtIndex:titleIndex];
    [noteTitle setText:model.title];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView
{
    if (currentPageIndex==0) {
        
        [_scrollView setContentOffset:CGPointMake(([tempArray count]-2)*viewSize.size.width, 0)];
    }
    if (currentPageIndex==([tempArray count]-1)) {
        
        [_scrollView setContentOffset:CGPointMake(viewSize.size.width, 0)];
        
    }
    
}
- (void)imagePressed:(UITapGestureRecognizer *)sender
{
    
    if ([delegate respondsToSelector:@selector(LNScrollerViewDidClicked:)]) {
        [delegate LNScrollerViewDidClicked:sender.view.tag-1];
    }
}

@end
