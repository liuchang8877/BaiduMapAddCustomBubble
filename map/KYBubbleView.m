//
//  KYBubbleView.m
//  DrugRef
//
//  Created by chen xin on 12-6-6.
//  Copyright (c) 2012年 Kingyee. All rights reserved.
//

#import "KYBubbleView.h"
#import "MXSNewsTypeListViewController.h"

@implementation KYBubbleView

static const float kBorderWidth = 10.0f;
static const float kEndCapWidth = 20.0f;
static const float kMaxLabelWidth = 220.0f;

@synthesize infoDict = _infoDict;
@synthesize index;
@synthesize findPlace;
@synthesize useFindPlace;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:14.0f];
        //[self addSubview:titleLabel];
        
        detailLabel = [[UILabel alloc] init];
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.numberOfLines = 0;
        detailLabel.font = [UIFont systemFontOfSize:12.0f];
        [self addSubview:detailLabel];
        
        //set the detail info 
        UIImage *phonecall = [UIImage imageNamed:@"mapapi.bundle/images/icon_nav_end"];
        CGRect rect = CGRectZero;
        rect.size = phonecall.size;
        rightButton = [[UIButton alloc] initWithFrame:rect];
        [rightButton setImage:phonecall forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(setDest)forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightButton];
        rightButton.hidden = YES;
        
        //set desination
        UIImage *destination = [UIImage imageNamed:@"mapapi.bundle/images/baidumap_logo.png"];
        CGRect desRect = CGRectMake(0, 0, 60, 40);
        //desRect.size = destination.size;
        leftButton = [[UIButton alloc] initWithFrame:desRect];
        //[leftButton setImage:destination forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(makePhoneCall) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftButton];
        //leftButton.hidden = NO;
        
        
        UIImage *imageNormal, *imageHighlighted;
        imageNormal = [[UIImage imageNamed:@"mapapi.bundle/images/icon_paopao_middle_left.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:13];
        imageHighlighted = [[UIImage imageNamed:@"mapapi.bundle/images/icon_paopao_middle_left_highlighted.png"]
                            stretchableImageWithLeftCapWidth:10 topCapHeight:13];
        UIImageView *leftBgd = [[UIImageView alloc] initWithImage:imageNormal
                                                 highlightedImage:imageHighlighted];
        leftBgd.tag = 11;
        
        imageNormal = [[UIImage imageNamed:@"mapapi.bundle/images/icon_paopao_middle_right.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:13];
        imageHighlighted = [[UIImage imageNamed:@"mapapi.bundle/images/icon_paopao_middle_right_highlighted.png"]
                            stretchableImageWithLeftCapWidth:10 topCapHeight:13];
        UIImageView *rightBgd = [[UIImageView alloc] initWithImage:imageNormal
                                                 highlightedImage:imageHighlighted];
        rightBgd.tag = 12;
        
        [self addSubview:leftBgd];
        [self sendSubviewToBack:leftBgd];
        [self addSubview:rightBgd];
        [self sendSubviewToBack:rightBgd];
        [leftBgd release];
        [rightBgd release];
        //not usetfind place
        useFindPlace = NO;
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [titleLabel release];
    [detailLabel release];
    [rightButton release];
    [_infoDict release];
    [super dealloc];
}

- (BOOL)showFromRect:(CGRect)rect {
    if (self.infoDict == nil) {
        return NO;
    }
    
    titleLabel.text = [_infoDict objectForKey:@"Name"];
    titleLabel.frame = CGRectZero;
    [titleLabel sizeToFit];
    CGRect rect1 = titleLabel.frame;
    rect1.origin = CGPointMake(kBorderWidth, kBorderWidth);
    if (rect1.size.width > kMaxLabelWidth) {
        rect1.size.width = kMaxLabelWidth;
    }
    titleLabel.frame = rect1;
    
    [leftButton addSubview:titleLabel];
    
//    NSString *addr = [_infoDict objectForKey:@"Address"];
//    NSString *phone = [_infoDict objectForKey:@"Phone"];
    
//    if ([phone isEqual: @""]) {
//        detailLabel.text = [NSString stringWithFormat:@"地址：%@", addr];
//        rightButton.hidden = YES;
//    }
//    else {
//        detailLabel.text = [NSString stringWithFormat:@"地址：%@\n电话：%@", addr, phone];
//        rightButton.hidden = NO;
//    }
    rightButton.hidden = NO;
    detailLabel.frame = CGRectZero;
    [detailLabel sizeToFit];
    CGRect rect2 = detailLabel.frame;
    rect2.origin.x = kBorderWidth;
    rect2.origin.y = rect1.size.height + 2*kBorderWidth;
    if (rect2.size.width > kMaxLabelWidth) {
        rect2.size.width = kMaxLabelWidth;
    }
    detailLabel.frame = rect2;
    
    CGFloat longWidth = (rect1.size.width > rect2.size.width) ? rect1.size.width : rect2.size.width;
    CGRect rect0 = self.frame;
    rect0.size.height = rect1.size.height + rect2.size.height + 2*kBorderWidth + kEndCapWidth;
    rect0.size.width = longWidth + 2*kBorderWidth;
    
    if (rightButton.hidden == NO) {
        CGRect rect3 = rightButton.frame;
        rect3.origin.x = longWidth + 2*kBorderWidth;
        rect3.origin.y = kBorderWidth;
        rightButton.frame = rect3;
        rect0.size.width += rect3.size.width + kBorderWidth;
    }
    
    //self.frame = rect0;
    self.frame = rect0;
    
    //CGPoint center = self.superview.center;
    //center.y -= (rect0.size.height/2 + 25);
    //self.center = center;
    /*
    CGPoint center;
    center.x = rect.origin.x + rect.size.width/2;
    center.y = rect.origin.y - rect0.size.height/2 + 8;
    self.center = center;
     */
    
    CGFloat halfWidth = rect0.size.width/2;
    UIView *image = [self viewWithTag:11];
    CGRect iRect = CGRectZero;
    iRect.size.width = halfWidth;
    iRect.size.height = rect0.size.height;
    image.frame = iRect;
    image = [self viewWithTag:12];
    iRect.origin.x = halfWidth;
    image.frame = iRect;
    
    return YES;
}

#pragma  set destination
- (void)setDest{
    useFindPlace = YES;
    UIViewController *viewController = [self viewController];
    [viewController getTheRoad];
}

- (void)makePhoneCall {
//    UIWebView *webView = (UIWebView*)[self viewWithTag:123];
//    if (webView == nil) {
//        webView = [[UIWebView alloc] initWithFrame:CGRectZero];
//    }
//    NSString *url = [NSString stringWithFormat:@"tel://%@", [_infoDict objectForKey:@"Phone"]];
//    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
    MXSNewsTypeListViewController *newsTypeList = [[MXSNewsTypeListViewController alloc] initWithNibName:@"MXSNewsTypeListViewController" bundle:nil];
    
    newsTypeList.hidesBottomBarWhenPushed = YES;
    newsTypeList.navigationItem.title = titleLabel.text;
    //[self.navigationController pushViewController:newsTypeList animated:YES];
    UIViewController *viewController = [self viewController];
    [viewController.navigationController pushViewController:newsTypeList animated:YES];

}

- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

@end
