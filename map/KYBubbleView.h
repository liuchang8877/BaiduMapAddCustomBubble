//
//  KYBubbleView.h
//  DrugRef
//
//  Created by chen xin on 12-6-6.
//  Copyright (c) 2012年 Kingyee. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KYPointAnnotation;

@interface KYBubbleView : UIView{
    NSDictionary *_infoDict;
    UILabel         *titleLabel;
    UILabel         *detailLabel;
    UIButton        *rightButton;
    UIButton        *leftButton;
    NSUInteger      index;
    KYPointAnnotation *findPlace;
    BOOL            useFindPlace;
    
}

@property (nonatomic, retain)NSDictionary *infoDict;
@property (nonatomic, retain)KYPointAnnotation *findPlace;
@property NSUInteger index;
@property BOOL            useFindPlace;

- (BOOL)showFromRect:(CGRect)rect;
- (void)makePhoneCall;

@end
