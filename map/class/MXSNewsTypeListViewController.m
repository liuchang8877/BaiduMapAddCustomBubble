//
//  MXSNewsTypeListViewController.m
//  xzyApp
//
//  Created by rbyyy on 3/8/13.
//  Copyright (c) 2013 rbyyy. All rights reserved.
//

#import "MXSNewsTypeListViewController.h"
//#import "MXSHandleDao.h"

@interface MXSNewsTypeListViewController ()

@end

@implementation MXSNewsTypeListViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.hidesBottomBarWhenPushed = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)testDB:(id)sender {
//
//    [MXSHandleDao createXZMapLocationTable];
//    
//}
@end
