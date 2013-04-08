BaiduMapAddCustomBubble
=======================

1.It is  use the BaiDu map' api  and rewrite the bubble view . It is the demo to use the BaiDu map' api

2.百度地图的API使用时有很多注意的事项：

    （1）ios 版本 的静态库分为模拟器调试和真机调试的两种
    （2）添加时注意添加framwork，例如：MapKit.framework,CoreLocation.framework,
         UIKit.framework,Foundation.framework,CoreGraphics.framework
     (3) TARHETS ---> Build Settings ---> Other Linker Flags --> 添加 “-all_load”
     (4) TARHETS ---> Build Settings ---> Library Search Paths --> 对应使用的静态库添加，还要放在首位
     
3.添加注册key
//--------AppDelegate.h
 
 #import "BMapKit.h"
 
@interface AppDelegate : UIResponder &lt;UIApplicationDelegate,UINavigationControllerDelegate,BMKGeneralDelegate&gt;
 
{
 
}
 
//---------AppDelegate.m
 
BMKMapManager* _mapManager;
 
@implementation AppDelegate
 
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 
{
 
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
 
    // 要使用百度地图，请先启动BaiduMapManager
 
    _mapManager = [[BMKMapManager alloc]init];
 
    BOOL ret = [_mapManager start:@"你的KEY" generalDelegate:self];
 
    if (!ret) {
 
        NSLog(@"manager start failed!");
 
    }
 
}

4.如果使用ARC 机制后，添加时，应该注意在TARHETS ---> Build Phases --->对应的文件 添加“-fno-objc-arc” 


欢迎大家一起交流：
Email：liuchang8877@gmail.com
weibo：www.weibo.com/we1700
