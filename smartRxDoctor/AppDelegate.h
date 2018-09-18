//
//  AppDelegate.h
//  smartRxDoctor
//
//  Created by Manju Basha on 04/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
//#import <PushKit/PushKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>//, PKPushRegistryDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic,strong) NSDictionary *payLoadDict;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (retain, nonatomic) UIScrollView *videoContainerAppDelegate;
@property (strong, nonatomic) UIView *viewSlpash;
@property (strong, nonatomic) UIView *transSlpash;
@property (strong, nonatomic) UIImage *imgSlpash;
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) NSArray *timeStampArray;
@property (strong, nonatomic) UIView *bottomOverlayViewAppDelegate;
@property (strong, nonatomic) UIView *topOverlayViewAppDelegate;
@property (retain, nonatomic) UIButton *cameraToggleButtonAppDelegate;
@property (retain, nonatomic) UIButton *audioPubUnpubButtonAppDelegate;
@property (retain, nonatomic) UILabel *userNameLabelAppDelegate;
@property (retain, nonatomic) NSTimer *overlayTimerAppDelegate;
@property (retain, nonatomic) UIButton *audioSubUnsubButtonAppDelegate;
@property (retain, nonatomic) UIButton *endCallButtonAppDelegate;
@property (retain, nonatomic) UIView *micSeparatorAppDelegate;
@property (retain, nonatomic) UIView *cameraSeparatorAppDelegate;
@property (retain, nonatomic) UIView *archiveOverlayAppDelegate;
@property (retain, nonatomic) UILabel *archiveStatusLblAppDelegate;
@property (retain, nonatomic) UIImageView *archiveStatusImgViewAppDelegate;
@property (retain, nonatomic) NSString *ridAppDelegate;
@property (retain, nonatomic) NSString *publisherNameAppDelegate;
@property (retain, nonatomic) UIImageView *rightArrowImgViewAppDelegate;
@property (retain, nonatomic) UIImageView *leftArrowImgViewAppDelegate;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

