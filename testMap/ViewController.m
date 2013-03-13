//
//  ViewController.m
//  testMap
//
//  Created by liu on 3/9/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import "ViewController.h"
#import "GeocodeDemoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getMap:(id)sender {
    
    GeocodeDemoViewController *geocodeDemoController = [[GeocodeDemoViewController alloc] init];
	geocodeDemoController.title = @"地图";
    
    //self.navigationController.hidesBottomBarWhenPushed
    [self.navigationController pushViewController:geocodeDemoController animated:YES];
}
@end
