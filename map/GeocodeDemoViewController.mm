//
//  GeocodeDemoViewController.mm
//  BaiduMapApiDemo
//
//  Copyright 2011 Baidu Inc. All rights reserved.
//

#import "GeocodeDemoViewController.h"
#import "KYBubbleView.h"
#import "KYPointAnnotation.h"
#import <QuartzCore/QuartzCore.h>
#import "MXSNewsTypeListViewController.h"

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

BOOL isRetina = FALSE;

@interface RouteAnnotation : BMKPointAnnotation
{
	int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘
	int _degree;
}

@property (nonatomic) int type;
@property (nonatomic) int degree;
@end

@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;
@end

@interface UIImage(InternalMethod)

- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees;

@end

@implementation UIImage(InternalMethod)

static CGFloat kTransitionDuration = 0.45f;

- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees
{
	CGSize rotatedSize = self.size;
	if (isRetina) {
		rotatedSize.width *= 2;
		rotatedSize.height *= 2;
	}
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	CGContextRotateCTM(bitmap, degrees * M_PI / 180);
	CGContextRotateCTM(bitmap, M_PI);
	CGContextScaleCTM(bitmap, -1.0, 1.0);
	CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end

BMKUserLocation *myLocation;

@implementation GeocodeDemoViewController
@synthesize findPlace;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	_search = [[BMKSearch alloc]init];
    _locationSearch.delegate = self;

    _cityText = [[UITextField alloc]init];
    _addrText = [[UITextField alloc]init];
    _cityText.text = @"新郑";
	_addrText.text = @"皇帝故里";

	CGSize screenSize = [[UIScreen mainScreen] currentMode].size;
	if (((screenSize.width >= 639.9f))
		&& (fabs(screenSize.height >= 959.9f)))
	{
		isRetina = TRUE;
	}
   
//    CLLocationCoordinate2D coor;
//	coor = (CLLocationCoordinate2D){[@"34.3956" floatValue], [@"113.741"floatValue]};;
//    NSLog(@"-----X:%f, Y:%f",coor.latitude,coor.longitude);
//    _mapView.zoomLevel = 12;
//    [_mapView setCenterCoordinate: coor animated:YES];
    
    _mapView.delegate = self;

	_search.delegate = self;
    //
    bubbleView = [[KYBubbleView alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
    bubbleView.hidden = YES;
    
    dataArray = [[NSMutableArray alloc] initWithCapacity:10];
    //set the flag
    customFlag = YES;
    [self saveTheLocation];
    [self getAllOfSaveLocation];
    
     //X:34.402065,Y:113.746983 新郑市政府
    _mapView.zoomLevel = 14;
    //use for open the set userlocation
    _mapView.showsUserLocation = YES;
    
    CLLocationCoordinate2D coor;
    coor = (CLLocationCoordinate2D){[@"34.402065" floatValue], [@"113.746984" floatValue]};
    [_mapView setCenterCoordinate:coor animated:YES];
    
    //set the left button to return
    //UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 52, 31)];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 52, 31);
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
    [rightBtn setBackgroundColor:[UIColor redColor]];
    //[rightBtn setImage:[UIImage imageNamed:@"stu_back.png"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(clickRightButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* itemCancel = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = itemCancel;
    
    _locationSearch.delegate = self;
    
    
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    
    [self setLocationSearch:nil];
    [self setLocationSearch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (void)onGetWalkingRouteResult:(BMKPlanResult*)result errorCode:(int)error
{
}

- (void)onGetPoiResult:(NSArray*)poiResultList searchType:(int)type errorCode:(int)error
{
}

// get the find city location
- (void)onGetAddrResult:(BMKAddrInfo*)result errorCode:(int)error
{
	if (error == 0) {
		BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
		item.coordinate = result.geoPt;
		item.title = result.strAddr;
		[_mapView addAnnotation:item];
		[item release];
        
        //save the find place
        findResult = result.geoPt;
        NSLog(@"onGetAddrResult---X:%f,Y:%f",findResult.latitude,findResult.longitude);
        
	} else {

        UIAlertView *errorAddAlert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"无法找到:%@、%@",_cityText.text,_addrText.text] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [errorAddAlert show];
        
    }
}

//save the locationArry
- (void)saveTheLocation{

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    pointAnnotationArry = [[NSMutableArray alloc] init];
    KYPointAnnotation* item = [[KYPointAnnotation alloc]init];
    item.coordinate =  CLLocationCoordinate2D{[@"34.405840" floatValue],[@"113.733796" floatValue]};
    item.title = @"新郑皇帝故里";
    item.tag  = 0;
    [dict setObject:(item.title == nil) ? @"" : item.title forKey:@"Name"];
    [dict setObject:@"新郑" forKey:@"Address"];
    [dict setObject:@"2312312" forKey:@"Phone"];
    [pointAnnotationArry insertObject:item atIndex:0];
    [dataArray insertObject:dict atIndex:0];

    /////////----------
    NSMutableDictionary *dicta = [[NSMutableDictionary alloc] initWithCapacity:3];
    KYPointAnnotation* itema = [[KYPointAnnotation alloc]init];
    itema.coordinate =  CLLocationCoordinate2D{[@"34.531461" floatValue],[@"113.852597" floatValue]};
    itema.title = @"新郑国际机场";
    itema.tag  = 1;
    [dicta setObject:(itema.title == nil) ? @"" : itema.title forKey:@"Name"];
    [dicta setObject:@"新郑" forKey:@"Address"];
    [dicta setObject:@"421132123" forKey:@"Phone"];
    [pointAnnotationArry insertObject:itema atIndex:1];
    [dataArray insertObject:dicta atIndex:1];
    
    /////------------
    NSMutableDictionary *dictb = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    KYPointAnnotation* itemb = [[KYPointAnnotation alloc]init];
    itemb.coordinate =  CLLocationCoordinate2D{[@"34.401350" floatValue],[@"113.743345" floatValue]};
    itemb.title = @"炎黄广场";
    itemb.tag  = 2;
    [dictb setObject:(itemb.title == nil) ? @"" : itemb.title forKey:@"Name"];
    [dictb setObject:@"新郑" forKey:@"Address"];
    [dictb setObject:@"423443132123" forKey:@"Phone"];
    [pointAnnotationArry insertObject:itemb atIndex:2];
    [dataArray insertObject:dictb atIndex:2];


    ////-------------
    NSMutableDictionary *dictc = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    KYPointAnnotation* itemc = [[KYPointAnnotation alloc]init];
    itemc.coordinate =  CLLocationCoordinate2D{[@"34.402065" floatValue],[@"113.746983" floatValue]};
    itemc.title = @"新郑市政府";
    itemc.tag  = 3;
    [dictc setObject:(itemc.title == nil) ? @"" : itemc.title forKey:@"Name"];
    [dictc setObject:@"新郑" forKey:@"Address"];
    [dictc setObject:@"421433535123" forKey:@"Phone"];
    [pointAnnotationArry insertObject:itemc atIndex:3];
    [dataArray insertObject:dictc atIndex:3];

//
//    
//    ///-----------
//    NSMutableDictionary *dictd = [[NSMutableDictionary alloc] initWithCapacity:3];
//    KYPointAnnotation* itemd = [[KYPointAnnotation alloc]init];
//    itemd.coordinate =  CLLocationCoordinate2D{[@"34.391103" floatValue],[@"113.742527" floatValue]};
//    itemd.title = @"新郑郑王陵博物馆";
//    [dictd setObject:(item.title == nil) ? @"" : item.title forKey:@"Name"];
//    [dictd setObject:@"新郑" forKey:@"Address"];
//    [dictd setObject:@"421132123" forKey:@"Phone"];
//    [pointAnnotationArry insertObject:dictd atIndex:4];
//    [dataArray addObject:dictd];
//
//    
//    NSLog(@"GeocodeDemoViewController---saveTheLocation LEN:%d",[pointAnnotationArry count]);
//    
//    [item release];
//    [itema release];
//    [itemb release];
//    [itemc release];
//    [itemd release];
//    [dict release];
//    [dicta release];
//    [dictb release];
//    [dictc release];
//    [dictd release];
    
    //X:34.405840,Y:113.733796 新郑轩辕皇帝故里
    //X:34.531461,Y:113.852597 新郑国际机场
    //X:34.401350,Y:113.743345 炎黄广场
    //X:34.402065,Y:113.746983 新郑市政府
    //X:34.391103,Y:113.742527 新郑郑王陵博物馆
    
    

}

//get the locatonArry
- (void)getAllOfSaveLocation{
    
    for (int i= 0; i < [pointAnnotationArry count]; i++) {
//        BMKPointAnnotation *item =  (BMKPointAnnotation *)[pointAnnotationArry objectAtIndex:i];
        
//        NSLog(@"COUNT:%d getAllOfSaveLocation---X:%f,Y:%f",i,item.coordinate.latitude,item.coordinate.longitude);
        
        [_mapView addAnnotation:(KYPointAnnotation*)[pointAnnotationArry objectAtIndex:i]];
		
    }

}

-(void)onClickGeocode
{
	NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
	[_mapView removeAnnotations:array];
	array = [NSArray arrayWithArray:_mapView.overlays];
	[_mapView removeOverlays:array];
    
	NSLog(@"onClickGeocode---search the place:%@,%@",_cityText.text,_addrText.text);
    
    BOOL flag = [_search geocode:_addrText.text withCity:_cityText.text];
   
	if (!flag) {
        
		NSLog(@"onClickGeocode---search failed!");
        
	} else {
    
        NSLog(@"onClickGeocode---search ok");
    }
    
    //---location
//    CLLocationCoordinate2D coor;
//	coor = (CLLocationCoordinate2D){[@"34.3956" floatValue], [@"113.741" floatValue]};;
//    NSLog(@"-----X:%f, Y:%f",coor.latitude,coor.longitude);
//    [_mapView setCenterCoordinate: coor animated:YES];
    
    [_addrText resignFirstResponder];
    
    //use for open the set userlocation
    _mapView.showsUserLocation = YES;
    customFlag = NO;
    //[self showBubble:NO];
}

#pragma get the road between two location

- (NSString*)getMyBundlePath1:(NSString *)filename
{
	
	NSBundle * libBundle = MYBUNDLE ;
	if ( libBundle && filename ){
		NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
		NSLog ( @"%@" ,s);
		return s;
	}
	return nil ;
}


- (void)getTheRoad
{

    NSLog(@"start to get the road");
    //set the custom flag
    customFlag = NO;
    //---------
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
	[_mapView removeAnnotations:array];
	array = [NSArray arrayWithArray:_mapView.overlays];
	[_mapView removeOverlays:array];
	CLLocationCoordinate2D startPt = (CLLocationCoordinate2D){0, 0};
	CLLocationCoordinate2D endPt = (CLLocationCoordinate2D){0, 0};
    //--------
    NSLog(@"start------X:%f,Y:%f",myLocation.coordinate.latitude,myLocation.coordinate.longitude);
    //startPt = myLocation.coordinate;
    startPt = (CLLocationCoordinate2D){[@"34.402065" floatValue], [@"113.746984" floatValue]};
    //endPt = findResult;
    if (bubbleView.useFindPlace) {
        
        endPt = bubbleView.findPlace.coordinate;
    }
    
    NSLog(@"end-----X:%f, Y:%f",endPt.latitude,endPt.longitude);
    //------
    
	BMKPlanNode* start = [[BMKPlanNode alloc]init];
	start.pt = startPt;
	//start.name = _startAddrText.text;
	BMKPlanNode* end = [[BMKPlanNode alloc]init];
	//end.name = _endAddrText.text;
    end.pt = endPt;
	BOOL flag = [_search drivingSearch:@"起点" startNode:start endCity:@"终点" endNode:end];
	if (!flag) {
		NSLog(@"search failed");
	}
	[start release];
	[end release];

}

-(void)onClickGetRoad
{
    //set the custom flag 
    customFlag = NO;
    //---------
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
	[_mapView removeAnnotations:array];
	array = [NSArray arrayWithArray:_mapView.overlays];
	[_mapView removeOverlays:array];
	CLLocationCoordinate2D startPt = (CLLocationCoordinate2D){0, 0};
	CLLocationCoordinate2D endPt = (CLLocationCoordinate2D){0, 0};    
    //--------
    NSLog(@"start------X:%f,Y:%f",myLocation.coordinate.latitude,myLocation.coordinate.longitude);
    startPt = myLocation.coordinate;
   
    //endPt = findResult;
    if (bubbleView.useFindPlace) {
        
        endPt = bubbleView.findPlace.coordinate;
    }
        
    NSLog(@"end-----X:%f, Y:%f",endPt.latitude,endPt.longitude);
    //------

	BMKPlanNode* start = [[BMKPlanNode alloc]init];
	start.pt = startPt;
	//start.name = _startAddrText.text;
	BMKPlanNode* end = [[BMKPlanNode alloc]init];
	//end.name = _endAddrText.text;
    end.pt = endPt;
	BOOL flag = [_search drivingSearch:@"起点" startNode:start endCity:@"终点" endNode:end];
	if (!flag) {
		NSLog(@"search failed");
	}
	[start release];
	[end release];


}

- (IBAction)onClickGetBus:(id)sender {
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    CLLocationCoordinate2D startPt = (CLLocationCoordinate2D){0, 0};
    CLLocationCoordinate2D endPt = (CLLocationCoordinate2D){0, 0};
    //-------
    NSLog(@"start------X:%f,Y:%f",myLocation.coordinate.latitude,myLocation.coordinate.longitude);
    startPt = myLocation.coordinate;
    NSLog(@"end-----X:%f, Y:%f",findResult.latitude,findResult.longitude);

    //endPt = findResult;
    if (bubbleView.useFindPlace) {
        
        endPt = bubbleView.findPlace.coordinate;
    }
    
    //------

    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.pt = startPt;
    //start.name = _startAddrText.text;
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    //end.name = _endAddrText.text;
    end.pt = endPt;
    
    BOOL flag = [_search transitSearch:@"起点" startNode:start endNode:end];
    if (!flag) {
    		NSLog(@"search failed");
    }
    [start release];
    [end release];
    

    
}

-(void)onGetTransitRouteResult:(BMKPlanResult *)result errorCode:(int)error
{
	NSLog(@"onGetTransitRouteResult:error:%d", error);
	if (error == BMKErrorOk) {
		BMKTransitRoutePlan* plan = (BMKTransitRoutePlan*)[result.plans objectAtIndex:0];
		
		RouteAnnotation* item = [[RouteAnnotation alloc]init];
		item.coordinate = plan.startPt;
		item.title = @"起点";
		item.type = 0;
		[_mapView addAnnotation:item];
		[item release];
		item = [[RouteAnnotation alloc]init];
		item.coordinate = plan.endPt;
		item.type = 1;
		item.title = @"终点";
		[_mapView addAnnotation:item];
		[item release];
		
		int size = [plan.lines count];
		int index = 0;
		for (int i = 0; i < size; i++) {
			BMKRoute* route = [plan.routes objectAtIndex:i];
			for (int j = 0; j < route.pointsCount; j++) {
				int len = [route getPointsNum:j];
				index += len;
			}
			BMKLine* line = [plan.lines objectAtIndex:i];
			index += line.pointsCount;
			if (i == size - 1) {
				i++;
				route = [plan.routes objectAtIndex:i];
				for (int j = 0; j < route.pointsCount; j++) {
					int len = [route getPointsNum:j];
					index += len;
				}
				break;
			}
		}
		
		BMKMapPoint* points = new BMKMapPoint[index];
		index = 0;
		
		for (int i = 0; i < size; i++) {
			BMKRoute* route = [plan.routes objectAtIndex:i];
			for (int j = 0; j < route.pointsCount; j++) {
				int len = [route getPointsNum:j];
				BMKMapPoint* pointArray = (BMKMapPoint*)[route getPoints:j];
				memcpy(points + index, pointArray, len * sizeof(BMKMapPoint));
				index += len;
			}
			BMKLine* line = [plan.lines objectAtIndex:i];
			memcpy(points + index, line.points, line.pointsCount * sizeof(BMKMapPoint));
			index += line.pointsCount;
			
			item = [[RouteAnnotation alloc]init];
			item.coordinate = line.getOnStopPoiInfo.pt;
			item.title = line.tip;
			if (line.type == 0) {
				item.type = 2;
			} else {
				item.type = 3;
			}
			
			[_mapView addAnnotation:item];
			[item release];
			route = [plan.routes objectAtIndex:i+1];
			item = [[RouteAnnotation alloc]init];
			item.coordinate = line.getOffStopPoiInfo.pt;
			item.title = route.tip;
			if (line.type == 0) {
				item.type = 2;
			} else {
				item.type = 3;
			}
			[_mapView addAnnotation:item];
			[item release];
			if (i == size - 1) {
				i++;
				route = [plan.routes objectAtIndex:i];
				for (int j = 0; j < route.pointsCount; j++) {
					int len = [route getPointsNum:j];
					BMKMapPoint* pointArray = (BMKMapPoint*)[route getPoints:j];
					memcpy(points + index, pointArray, len * sizeof(BMKMapPoint));
					index += len;
				}
				break;
			}
		}
		
		BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:points count:index];
		[_mapView addOverlay:polyLine];
		delete []points;
	}
}

//add the pickture
- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation
{
	BMKAnnotationView* view = nil;
	switch (routeAnnotation.type) {
		case 0:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start.png"]];
				view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 1:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end.png"]];
				view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 2:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_bus.png"]];
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 3:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_rail.png"]];
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 4:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
				view.canShowCallout = TRUE;
			} else {
				[view setNeedsDisplay];
			}
			
			UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction.png"]];
			view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
			view.annotation = routeAnnotation;
			
		}
			break;
		default:
			break;
	}
	
	return view;
}

#pragma  Driving

- (void)onGetDrivingRouteResult:(BMKPlanResult*)result errorCode:(int)error
{
	NSLog(@"onGetDrivingRouteResult:error:%d", error);
	if (error == BMKErrorOk) {
		BMKRoutePlan* plan = (BMKRoutePlan*)[result.plans objectAtIndex:0];
		
		
		RouteAnnotation* item = [[RouteAnnotation alloc]init];
		item.coordinate = result.startNode.pt;
		item.title = @"起点";
		item.type = 0;
		[_mapView addAnnotation:item];
		[item release];
		
		int index = 0;
		int size = [plan.routes count];
		for (int i = 0; i < 1; i++) {
			BMKRoute* route = [plan.routes objectAtIndex:i];
			for (int j = 0; j < route.pointsCount; j++) {
				int len = [route getPointsNum:j];
				index += len;
			}
		}
		
		BMKMapPoint* points = new BMKMapPoint[index];
		index = 0;
		
		for (int i = 0; i < 1; i++) {
			BMKRoute* route = [plan.routes objectAtIndex:i];
			for (int j = 0; j < route.pointsCount; j++) {
				int len = [route getPointsNum:j];
				BMKMapPoint* pointArray = (BMKMapPoint*)[route getPoints:j];
				memcpy(points + index, pointArray, len * sizeof(BMKMapPoint));
				index += len;
			}
			size = route.steps.count;
			for (int j = 0; j < size; j++) {
				BMKStep* step = [route.steps objectAtIndex:j];
				item = [[RouteAnnotation alloc]init];
				item.coordinate = step.pt;
				item.title = step.content;
				item.degree = step.degree * 30;
				item.type = 4;
				[_mapView addAnnotation:item];
				[item release];
			}
			
		}
		
		item = [[RouteAnnotation alloc]init];
		item.coordinate = result.endNode.pt;
		item.type = 1;
		item.title = @"终点";
		[_mapView addAnnotation:item];
		[item release];
		BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:points count:index];
		[_mapView addOverlay:polyLine];
		delete []points;
	}
	
}

//- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
//{
//	if ([annotation isKindOfClass:[RouteAnnotation class]]) {
//		return [self getRouteAnnotationView:view viewForAnnotation:(RouteAnnotation*)annotation];
//	}
//	return nil;
//}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
	if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[[BMKPolylineView alloc] initWithOverlay:overlay] autorelease];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
	return nil;
}

#pragma use to set loaction of user

- (void)mapView:(BMKMapView *)mapView didUpdateUserLocation:(BMKUserLocation *)userLocation
{
	if (userLocation != nil) {
        
		NSLog(@"userLocation---%f %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
        //save the find location
        myLocation = userLocation;
        //jump to the location
        //[_mapView setCenterCoordinate: userLocation.location.coordinate animated:YES];
	}
	
}

-(void)mapViewDidStopLocatingUser:(BMKMapView *)mapView {

    NSLog(@"StopLocatingUser");
    myLocation = _mapView.userLocation;

}

- (void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
	if (error != nil)
		NSLog(@"locate failed: %@", [error localizedDescription]);
	else {
		NSLog(@"locate failed");
	}
	
}

- (void)mapViewWillStartLocatingUser:(BMKMapView *)mapView
{	NSLog(@"start locate");
}

#pragma  Custom annotations
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    //set the delegate
    _mapView.delegate = self;
    _search.delegate = self;
    
    //use for open the set userlocation
    _mapView.showsUserLocation = YES;
    selectedAV = nil; 
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    if (customFlag) {
//        [self cleanMap];
//        [dataArray removeAllObjects];
//    }
}

- (void)changeBubblePosition {
    if (selectedAV) {
        CGRect rect = selectedAV.frame;
        CGPoint center;
        center.x = rect.origin.x + rect.size.width/2;
        center.y = rect.origin.y - bubbleView.frame.size.height/2 + 8;
        bubbleView.center = center;
    }
}

-(void)cleanMap
{
    [dataArray removeAllObjects];
    [_mapView removeOverlays:_mapView.overlays];
    //[_mapView removeAnnotations:_mapView.annotations];
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
}

#pragma mark 标注
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{

    // it is not the custom
    if (!customFlag) {
        
        //set the load
        if ([annotation isKindOfClass:[RouteAnnotation class]]) {
            return [self getRouteAnnotationView:mapView viewForAnnotation:(RouteAnnotation*)annotation];
        }   
        return nil;
    }
    
    //BMKAnnotationView *annotationView = [mapView viewForAnnotation:annotation];
    BMKPinAnnotationView *annotationView = (BMKPinAnnotationView*)[mapView viewForAnnotation:annotation];
    
    if (annotationView == nil)
    {

        KYPointAnnotation *ann;
        if ([annotation isKindOfClass:[KYPointAnnotation class]]) {
    
            ann = annotation;
        }
        NSUInteger tag = ann.tag;
        NSString *AnnotationViewID = [NSString stringWithFormat:@"AnnotationView-%i", tag];
        
        annotationView = [[[BMKPinAnnotationView alloc] initWithAnnotation:annotation
                                                           reuseIdentifier:AnnotationViewID] autorelease];
        ((BMKPinAnnotationView*) annotationView).pinColor = BMKPinAnnotationColorRed;
        annotationView.canShowCallout = NO;//使用自定义bubble
        //}
        
		((BMKPinAnnotationView*)annotationView).animatesDrop = YES;// 设置该标注点动画显示
        
        
        annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
        annotationView.annotation = annotation;
	}
	return annotationView ;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    
 //   if ([view isKindOfClass:[BMKPinAnnotationView class]]) {
    if (customFlag) {
        selectedAV = view;
        if (bubbleView.superview == nil) {
			//bubbleView加在BMKAnnotationView的superview(UIScrollView)上,且令zPosition为1
            [view.superview addSubview:bubbleView];
            bubbleView.layer.zPosition = 1;
        }
        bubbleView.infoDict = [dataArray objectAtIndex:[(KYPointAnnotation*)view.annotation tag]];
        
        //[self showBubble:YES];
        //[self changeBubblePosition];
        //[bubbleView setFindPlace:(KYPointAnnotation*)view.annotation];
        [_mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
        [bubbleView setFindPlace:(KYPointAnnotation*)view.annotation];
    } else {
    
        selectedAV = nil;
    }

}

//- (void)mapView:(BMKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews{
//    [self showBubble:YES];
//
//}

- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view
{

    if ([view isKindOfClass:[BMKPinAnnotationView class]]) {
        [self showBubble:NO];
    }
}

#pragma mark 区域改变
- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if (selectedAV) {
#ifdef Debug
        CGPoint point = [mapView convertCoordinate:selectedAV.annotation.coordinate toPointToView:selectedAV.superview];
        //CGRect rect = selectedAV.frame;
        DLog(@"x=%.1f, y= %.1f", point.x, point.y);
#endif
        [self showBubble:NO];
    }

}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //when it is selected and it is the custom view
    //if (selectedAV && customFlag)
    if (selectedAV && customFlag) {
        
            [self showBubble:YES];
            [self changeBubblePosition];

   }

}


#pragma mark show bubble animation
- (void)bounce4AnimationStopped{
    //CGPoint point = [_mapView convertCoordinate:selectedAV.annotation.coordinate toPointToView:selectedAV.superview];
    //DLog(@"annotationPoint4:x=%.1f, y= %.1f", point.x, point.y);
    //[self changeBubblePosition];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/6];
	//[UIView setAnimationDelegate:self];
    //[UIView setAnimationDidStopSelector:@selector(bounce5AnimationStopped)];
	bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
	[UIView commitAnimations];
}

- (void)bounce3AnimationStopped{

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/6];
	[UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce4AnimationStopped)];
	bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.95);
	[UIView commitAnimations];
}

- (void)bounce2AnimationStopped{

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/6];
	[UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce3AnimationStopped)];
	bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
	[UIView commitAnimations];
}
 
- (void)bounce1AnimationStopped{

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/6];
	[UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
	bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
	[UIView commitAnimations];
}

- (void)showBubble:(BOOL)show {
    if (show) {
        [bubbleView showFromRect:selectedAV.frame];
        
        bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kTransitionDuration/3];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
        bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        bubbleView.hidden = NO;
        //bubbleView.center = center;
        [UIView commitAnimations];
        
    }
    else {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kTransitionDuration/3];
        //[UIView setAnimationDelegate:self];
        //[UIView setAnimationDidStopSelector:@selector(bubbleViewIsRemoved)];
        bubbleView.hidden = YES;
        [UIView commitAnimations];
    }
}

//reset the map
- (void)clickRightButton
{

    if (!customFlag) {
        NSLog(@"GeocodeDemoViewController---start to reset the map");
        [self cleanMap];
        [bubbleView release];
        [self viewDidLoad];

    }
}

#pragma search bar
//start to  search
/*search  Cancel button*/
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
//	[self doSearch:searchBar];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

/*keyboard search button*/
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	
    [searchBar resignFirstResponder];
	[self doSearch:searchBar];
}

/*search*/
- (void)doSearch:(UISearchBar *)searchBar{
    
	NSLog(@"doSearch---%@",searchBar.text);
    _addrText.text = [NSString stringWithFormat:@"%@",searchBar.text];
    NSLog(@"doSearch---%@",_addrText.text);
    [self onClickGeocode];
}

//begein
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

//end editing
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

@end
