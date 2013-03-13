//
//  AppDelegate.h
//  testMap
//
//  Created by liu on 3/9/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@class ViewController;
@class GeocodeDemoViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, BMKGeneralDelegate>
{
    UIWindow *window;
    UINavigationController *navigationController;
    

}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (strong, nonatomic) GeocodeDemoViewController *geocodeDemoController;
@end
