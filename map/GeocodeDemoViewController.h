//
//  GeocodeDemoViewController.h
//  BaiduMapApiDemo
//
//  Copyright 2011 Baidu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@class KYBubbleView;
@class KYPointAnnotation;

@interface GeocodeDemoViewController : UIViewController<BMKMapViewDelegate, BMKSearchDelegate,UISearchBarDelegate> {
	IBOutlet BMKMapView* _mapView;
	UITextField* _cityText;
	UITextField* _addrText;
	BMKSearch* _search;
    
    //save youself loaction
    //BMKUserLocation *myLocation;
    //find place
    CLLocationCoordinate2D findResult;
    //PointAnnotationArry to save the determine target
    NSMutableArray *pointAnnotationArry;
    
    //
    BMKAnnotationView *selectedAV;
    NSMutableArray *dataArray;
    KYBubbleView *bubbleView;
    //set Custom logo
    BOOL customFlag;
    
    //
    KYPointAnnotation *findPlace;
    
}

//@property (strong, nonatomic)CLLocationCoordinate2D findResult;
@property (nonatomic, retain)KYPointAnnotation *findPlace;
@property (nonatomic, retain) IBOutlet UISearchBar *locationSearch;

-(void)onClickGeocode;
//get the dring road
-(void)onClickGetRoad;
//get the bus road
- (IBAction)onClickGetBus:(id)sender;
//get the road
- (void)getTheRoad;
@end
