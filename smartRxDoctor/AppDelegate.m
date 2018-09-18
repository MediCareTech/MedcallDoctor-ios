//
//  AppDelegate.m
//  smartRxDoctor
//
//  Created by Manju Basha on 04/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "AppDelegate.h"
#import "NSUserDefaults+Settings.h"

@import Firebase;


#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [NSUserDefaults saveIncomingAvatarSetting:YES];
    [NSUserDefaults saveOutgoingAvatarSetting:YES];
    [FIRApp configure];

    
    NSDictionary *userInfo =[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    // Override point for customization after application launch.
     [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"EConsultPush"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"InEconsult"];
//    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
//        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//        center.delegate = self;
//        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
//            if(!error){
//                dispatch_async(dispatch_get_main_queue(),^{
//
//                    [[UIApplication sharedApplication] registerForRemoteNotifications];
//
//                });
//            }
//        }];
//    }else{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
//    [self voipRegistration];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"FromLogin"];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Reinstalling"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    if (userInfo){
        self.payLoadDict = userInfo;
        NSLog(@"payload dict......:%@",self.payLoadDict);
        [self application:application didReceiveRemoteNotification:userInfo];
    };
    
    return YES;
}
#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if (notificationSettings.types != UIUserNotificationTypeNone) {
//        NSLog(@"didRegisterUser");
        [application registerForRemoteNotifications];
    }
    //register to receive notifications
    //    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    [[NSUserDefaults standardUserDefaults]setObject:deviceToken forKey:@"PushToken"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"push recived  %@",userInfo);
    
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Reinstalling"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    if ( application.applicationState == UIApplicationStateActive )
    {
        // app was already in the foreground, hence showing as a seperate message
        NSString *strHspName = nil;
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"] length] > 0)
            strHspName=[[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"];
        if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 1)
        {
            NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
            NSString *htmlString=[message stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            message = [attrStr string];
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"PushNotes"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            UIStoryboard *storyBoardID=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *mainVC=[storyBoardID instantiateInitialViewController];
            self.window.rootViewController = mainVC;
            [self.window makeKeyAndVisible];
        }
        else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 3)
        {
            NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
            NSArray *strArray = [message componentsSeparatedByString:@"***"];
            if ([strArray count] >= 6)
                message = [strArray objectAtIndex:5];
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"EConsultPush"];
            [[NSUserDefaults standardUserDefaults] setObject:[[userInfo valueForKey:@"aps"] valueForKey:@"keyid"] forKey:@"pushEconsultID"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            UIStoryboard *storyBoardID=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *mainVC=[storyBoardID instantiateInitialViewController];
            self.window.rootViewController = mainVC;
            [self.window makeKeyAndVisible];
        }
        else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 4)
        {            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"InEconsult"] != YES)
            {
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"EConsultPush"];
                [[NSUserDefaults standardUserDefaults] setObject:[[userInfo valueForKey:@"aps"] valueForKey:@"keyid"] forKey:@"pushEconsultID"];
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"EConsultVideoPush"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                UIStoryboard *storyBoardID=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *mainVC=[storyBoardID instantiateInitialViewController];
                self.window.rootViewController = mainVC;
                [self.window makeKeyAndVisible];
            }
        }else {
            if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] != 7) {
                
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
                NSArray *strArray = [message componentsSeparatedByString:@"***"];
                NSLog(@"push array......:%@",strArray);
                //[[NSUserDefaults standardUserDefaults]setObject:strArray forKey:@"pushChatData"];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"chatNotification" object:strArray];
            }
           
//            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//            UIStoryboard *storyBoardID=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            UIViewController *mainVC=[storyBoardID instantiateInitialViewController];
//            self.window.rootViewController = mainVC;
//            [self.window makeKeyAndVisible];
            
        }
        
    }
    else if ( application.applicationState == UIApplicationStateBackground || application.applicationState == UIApplicationStateInactive)
    {
        if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 1)
        {
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"PushNotes"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            UIStoryboard *storyBoardID=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *mainVC=[storyBoardID instantiateInitialViewController];
            self.window.rootViewController = mainVC;
            [self.window makeKeyAndVisible];
        }
        else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 3)
        {
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"EConsultPush"];
            [[NSUserDefaults standardUserDefaults] setObject:[[userInfo valueForKey:@"aps"] valueForKey:@"keyid"] forKey:@"pushEconsultID"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            UIStoryboard *storyBoardID=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *mainVC=[storyBoardID instantiateInitialViewController];
            self.window.rootViewController = mainVC;
            [self.window makeKeyAndVisible];
        }
        else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 4)
        {
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"EConsultPush"];
            [[NSUserDefaults standardUserDefaults] setObject:[[userInfo valueForKey:@"aps"] valueForKey:@"keyid"] forKey:@"pushEconsultID"];
            if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 4)
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"EConsultVideoPush"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            UIStoryboard *storyBoardID=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *mainVC=[storyBoardID instantiateInitialViewController];
            self.window.rootViewController = mainVC;
            [self.window makeKeyAndVisible];
        }else {
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
            NSArray *strArray = [message componentsSeparatedByString:@"***"];
            
            if (self.payLoadDict) {
                [[NSUserDefaults standardUserDefaults] setObject:@"chatNotify" forKey:@"chatRequest"];
                [[NSUserDefaults standardUserDefaults] setObject:strArray forKey:@"chatRequestData"];

                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"chats"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                UIStoryboard *storyBoardID=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *mainVC=[storyBoardID instantiateInitialViewController];
                self.window.rootViewController = mainVC;
                [self.window makeKeyAndVisible];

            }else {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"chatNotification" object:strArray];
            }
           
           
        }
        
    }

}
//-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
//    NSLog(@"User Info : %@",notification.request.content.userInfo);
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"chatNotification" object:nil];
//
//    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
//}
//
////Called to let your app know which action was selected by the user for a given notification.
//-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
//    NSLog(@"User Info : %@",response.notification.request.content.userInfo);
//    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//
//    completionHandler();
//}
//#pragma mark ViOP methods
//// Register for VoIP notifications
//- (void) voipRegistration {
//    // Create a push registry object
//    PKPushRegistry * voipRegistry = [[PKPushRegistry alloc] initWithQueue: dispatch_get_main_queue()];
//    // Set the registry's delegate to self
//    voipRegistry.delegate = self;
//    // Set the push type to VoIP
//    voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP]; // register
//}
//
//// Handle updated push credentials
//- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials: (PKPushCredentials *)credentials forType:(NSString *)type {
//    // Register VoIP push token (a property of PKPushCredentials) with server
//}
//// Handle incoming pushes
//- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type {
//    // Process the received push
//}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "in.smartrx.doctor.smartRxDoctor" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"smartRxDoctor" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"smartRxDoctor.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
