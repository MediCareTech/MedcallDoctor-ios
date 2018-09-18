 //
//  smartRxDashboardVC.m
//  smartRxDoctor
//
//  Created by Manju Basha on 05/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "smartRxDashboardVC.h"
#import "UIImageView+WebCache.h"
#import "smartRxDashboardTableCell.h"
#import "MenuTableViewCell.h"
#import "smartRxEconsultVC.h"
#import "ResponseParser.h"
#import "BookingResponseModel.h"
#import "BookingItemResponseModel.h"
#import "DashBoardCell.h"
#import "DashBoardAppointmentCell.h"
#import "SmartRxeConsultDetailsVC.h"
#import "AppointmentDetailsController.h"
#import "LocationsModel.h"
#import "SmartRxChatListVC.h"

#define kLogoutAlertTag 800
#define KLogoutAlertTagFromCommon 1040
#define pwdResetSuccess 700

@interface smartRxDashboardVC ()
{
    MBProgressHUD *HUD;
    CGSize viewSize;
    NSMutableArray *dashItems, *dashItemImage;
    BOOL bIsMenuSel, bIsResetPwdSel, fromMenu;
    NSString *password, *resetPassword;
    NSString *locationName;
    NSDictionary *locationDict;
    LocationsModel *selectedLocation;
    NSInteger econsultIndex;
    BOOL infoShown, viewAppeared;
    NSDictionary *selectedEconsult;

}
@property(nonatomic,strong)NSArray *locationsArr;
@property(nonatomic,strong)NSArray *bookingList;
@property(nonatomic,strong)NSDictionary *originalData;

@end

@implementation smartRxDashboardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    viewSize=[[UIScreen mainScreen]bounds].size;
    //self.doctorDashMenu.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.noApsView.hidden = YES;

    [self.doctorDashMenu setTableFooterView:[UIView new]];
    _arrMenu=[[NSArray alloc]initWithObjects:@"View Profile",@"Send Alert",@"My Schedule",@"My Locations",@"Q & A",@"Care Plans",@"Change Password",@"Logout", nil];
    
    dashItems = [[NSMutableArray alloc] initWithArray:@[@"Appointments", @"E-Consult", @"Patient Lookup", @"Care Plans", @"Q & A"]];
    dashItemImage = [[NSMutableArray alloc] initWithArray:@[@"appointment_menu.png", @"econsult_menu.png", @"patient_lookup_menu.png", @"careplan_menu.png", @"question_menu.png"]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveChatRequestNotification:) name:@"chatNotification" object:nil];

   
    // Do any additional setup after loading the view.
}
- (void)recieveChatRequestNotification:(NSNotification *) notification
{
    NSArray *chatArr = notification.object;
    if ([[notification name] isEqualToString:@"chatNotification"]){
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        NSString *alertStr = [NSString stringWithFormat:@"You have got a new chat request from %@. Do you like to accept the request",chatArr[2]];
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Alert" message:alertStr preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *accept = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self homeBtnClicked:nil];
            [self makeRequestForChatRequestAccept:chatArr accept:@"2"];

        }];
        UIAlertAction *reject = [UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self makeRequestForChatRequestAccept:chatArr accept:@"3"];
        }];
        
        [controller addAction:accept];
        [controller addAction:reject];
        controller.preferredAction = accept;
        [self presentViewController:controller animated:YES
                         completion:nil];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    bIsMenuSel = NO;
    bIsResetPwdSel = NO;
    [self.tblMenu setTableFooterView:[UIView new]];
    [self SetNavigationBarItems];
//    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] == YES)
//    {
//        //        [self performSegueWithIdentifier:@"eConsultVC" sender:nil];
//        [self performSegueWithIdentifier:@"DBToEconsult" sender:nil];
//    }
//    else
//    {
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",IMAGE_URL_TEST,[[NSUserDefaults standardUserDefaults] objectForKey:@"profilePicLink"]];
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlStr];
        [self.doctorImg  sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"img_placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (!error)
            {
            }
            else
            {
                NSLog(@"Image Error : %@", error);
            }
        }];
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"])
        {
            self.navigationItem.title=[[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"];
        }
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"])
        {
            self.doctorName.text=[[[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"] capitalizedString];
            
            self.doctorDesignation.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"Qualification"];
        }
        //[[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];
    
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo"]];
    UIView *myView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 100, 44)];
    imageView.frame = CGRectMake(0, 0, 100, 40);
    [myView addSubview:imageView];
    self.navigationItem.titleView = myView;

    NSString *chatStr = [[NSUserDefaults standardUserDefaults]objectForKey:@"chatRequest"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"chats"]) {
        NSLog(@"chat data is available");
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"chats"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"chatRequest"];
        [NSUserDefaults standardUserDefaults];
        NSArray *chataData = [[NSUserDefaults standardUserDefaults] objectForKey:@"chatRequestData"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"chatRequestData"];

        [[NSNotificationCenter defaultCenter]postNotificationName:@"chatNotification" object:chataData];
        
//        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Chat request from patient" preferredStyle:UIAlertControllerStyleAlert];
//
//        UIAlertAction *accept = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            dispatch_async(dispatch_get_main_queue(),^{
//                [self performSegueWithIdentifier:@"chatListVc" sender:nil];
//
//            });
//
//        }];
//        UIAlertAction *reject = [UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDefault handler:nil];
//
//        [controller addAction:accept];
//        [controller addAction:reject];
//        //controller.preferredAction = accept;
//        [self presentViewController:controller animated:YES
//                         completion:nil];

    }

         [self makeeRequestForLocations];
         [self makeRequstForBookingList:@"1"];
           // [self makeRequestForDashboardDetails];
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
//    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] == YES)
//    {
//        //        [self performSegueWithIdentifier:@"eConsultVC" sender:nil];
//        [self performSegueWithIdentifier:@"DBToEconsult" sender:nil];
//    }\
    
    
    viewAppeared = YES;
    if ( selectedEconsult != nil&& [[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] == YES)
    {
        [self performSegueWithIdentifier:@"econsultDetailsVc" sender:selectedEconsult];
    }
}

-(void)SetNavigationBarItems
{
//    self.navigationItem.hidesBackButton = YES;
    UIButton *btnFaq = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *faqBtnImag = [UIImage imageNamed:@"icon_list.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    [btnFaq addTarget:self action:@selector(menuBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;

    
    UIButton *btnFaq1 = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *faqBtnImag1 = [UIImage imageNamed:@"empty_btn.png"];
    [btnFaq1 setImage:faqBtnImag1 forState:UIControlStateNormal];
    [btnFaq1 addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    btnFaq1.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView1.bounds = CGRectOffset(btnFaqView1.bounds, 0, -7);
    [btnFaqView1 addSubview:btnFaq1];
    UIBarButtonItem *leftbtn  = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView1];
    self.navigationItem.leftBarButtonItem = leftbtn;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}

#pragma mark - Custom AlertView
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    alertView.delegate = self;
    [alertView show];
    alertView=nil;
}

#pragma mark - Request Methods
-(void)makeRequestForChatRequestAccept:(NSArray *)chatData accept:(NSString *)acceptRespose{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *doctorId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&docid=%@&patid=%@&room_name=%@&notify_id=%@&response=%@",@"sessionid",sectionId,doctorId,chatData[3],chatData[1],chatData[4],acceptRespose];
    NSLog(@"request body.....:%@",bodyText);
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dchat_request_response"];
    NSLog(@"chat url...........:%@",url);
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response)
     {
         NSLog(@"chat response......:%@",response);
         if (response == nil)
         {
             [HUD hide:YES];
             [HUD removeFromSuperview];
             [self customAlertView:@"" Message:@"Internal server error" tag:0];
         }
         else{
             if ([[response  objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0 && [[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
             {
                 SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                 smartLogin.loginDelegate=self;
                 //[smartLogin makeLoginRequest];
                 
             }
             else{
                 dispatch_async(dispatch_get_main_queue(),^{
                     [HUD hide:YES];
                     [HUD removeFromSuperview];
                     if ([acceptRespose isEqualToString:@"2"]) {
                         if ([response[@"result"] integerValue] == 1) {
                             NSString *profilePic = @"";
                             if (![response[@"data"][0][@"profile_pic"] isEqualToString:@""]) {
                                 profilePic = [NSString stringWithFormat:@"%@%@",IMAGE_URL_TEST,response[@"data"][0][@"profile_pic"]];
                             }
                         NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:chatData[2],@"patienttName",chatData[3],@"patientId",chatData[1],@"roomname",chatData[4],@"notifyId",profilePic,@"profilepic", nil];
                             NSLog(@"chata dataaaa......:%@",dict);
                         [self performSegueWithIdentifier:@"chatListVc" sender:dict];
                         }else {
                             [self customAlertView:@"" Message:@"Alredy accepted by other doctor" tag:0];
                         }
                 }
                 });
                 
                 
             }}}failureHandler:^(id response) {
                 NSLog(@"failure %@",response);
                 [HUD hide:YES];
                 [HUD removeFromSuperview];
             }];

    
}
-(void)makeRequstForSearch:(NSString *)serchText{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *doctorId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&term=%@",@"sessionid",sectionId,serchText];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dpsearch"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response)
     {
         if (response == nil)
         {
             [HUD hide:YES];
             [HUD removeFromSuperview];
             [self customAlertView:@"" Message:@"Internal server error" tag:0];
         }
         else{
             if ([[response  objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0 && [[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
             {
                 SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                 smartLogin.loginDelegate=self;
                 //[smartLogin makeLoginRequest];
                 
             }
             else{
                 dispatch_async(dispatch_get_main_queue(),^{
                     [HUD hide:YES];
                     [HUD removeFromSuperview];
                     NSLog(@"search list  :%@",response);
                    
                 });
                 
                 
             }}}failureHandler:^(id response) {
                 NSLog(@"failure %@",response);
                 [HUD hide:YES];
                 [HUD removeFromSuperview];
             }];

}
-(void)makeeRequestForLocations{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *doctorId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&isopen=1&uid=%@",@"sessionid",sectionId,doctorId];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"mylocations"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response)
     {
         if (response == nil)
         {
             [HUD hide:YES];
             [HUD removeFromSuperview];
             [self customAlertView:@"" Message:@"Internal server error" tag:0];
         }
         else{
             if ([[response  objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0 && [[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
             {
                 SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                 smartLogin.loginDelegate=self;
                 //[smartLogin makeLoginRequest];
                 
             }
             else{
                 dispatch_async(dispatch_get_main_queue(),^{
                     //[HUD hide:YES];
                     //[HUD removeFromSuperview];
                     //self.locationsArr = response[@"mylocations"];
                     self.locationsArr = [ResponseParser getLocation:response[@"mylocations"]];
                     //self.locationsArr = locations;
                     
                     //NSLog(@"booking list:%@",_bookingList);
                 });
                 
                 
             }}}failureHandler:^(id response) {
                 NSLog(@"failure %@",response);
                 [HUD hide:YES];
                 [HUD removeFromSuperview];
             }];
    
}

-(void)makeRequstForBookingList:(NSString *)page{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&page=%@",@"sessionid",sectionId,page];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"daptlist"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response)
     {
         NSLog(@"response......:%@",response);
         if (response == nil)
         {
             [HUD hide:YES];
             [HUD removeFromSuperview];
             [self customAlertView:@"" Message:@"Internal server error" tag:0];
         }
         else{
             if ([[response  objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0 && [[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
             {
                 SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                 smartLogin.loginDelegate=self;
                 [smartLogin makeLoginRequest];
                 
             }
             else{
                 dispatch_async(dispatch_get_main_queue(),^{
                     [HUD hide:YES];
                     [HUD removeFromSuperview];
                self.originalData = response[@"aptlist"];

            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] == YES){
                    NSDictionary *responseDict = [response objectForKey:@"aptlist"];
                NSArray *keysArr = [response[@"aptlist"] allKeys];

                if ([keysArr count])
                {
                    NSString *appId = [[NSUserDefaults standardUserDefaults]objectForKey:@"pushEconsultID"];
                for (NSString *key in keysArr)
                {
                             
                NSArray *tempArr = responseDict[key];
                  
                for (NSDictionary *dict in tempArr) {
                    
                    
                if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] == YES)
                {
                    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultVideoPush"] == YES)
                    {
//                        NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K == %ld", @"appid", [appId integerValue]];
//                        NSArray *filteredLocationArr = [tempArr filteredArrayUsingPredicate:predicateString];
//                        if (filteredLocationArr.count) {
//                            selectedEconsult = filteredLocationArr[0];
//                            return ;
//                        }
                        
                if ([dict[@"appid"] isEqualToString:appId]) {
                    selectedEconsult = dict;
                }
                }else {
                    
//                    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K == %ld", @"conid", [appId integerValue]];
//                    NSArray *filteredLocationArr = [tempArr filteredArrayUsingPredicate:predicateString];
//                    if (filteredLocationArr.count) {
//                        selectedEconsult = filteredLocationArr[0];
//                        return ;
//                    }
                if ([dict[@"conid"] isEqualToString:appId]) {
                    selectedEconsult = dict;
                    
                }
            }
       }
                    if (selectedEconsult != nil) {
                        if (viewAppeared) {
                            [self performSegueWithIdentifier:@"econsultDetailsVc" sender:selectedEconsult];
                        }
                        return ;
                    }
    }
                    if (selectedEconsult != nil) {
                        NSLog(@"selected data2");

                        return ;
                    }
        }
        }
    }
      if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] != YES)
                {

                if (self.originalData.count ) {
                         self.bookingList = [ResponseParser getBookingItems:response[@"aptlist"]];
                    
                     } else{
                         self.noApsView.hidden = NO;
                     }
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self.doctorDashMenu reloadData];
                        [self getDateCount];


                    });
                     }else {
                         
                         [HUD hide:YES];
                         [HUD removeFromSuperview];
                         NSLog(@"push success:%@",selectedEconsult);
                         if (viewAppeared) {
                              [self performSegueWithIdentifier:@"econsultDetailsVc" sender:selectedEconsult];
                         }
                                      }
                    
                     //NSLog(@"booking list:%@",_bookingList);
                 });
                
                 
                 }}}failureHandler:^(id response) {
                 NSLog(@"failure %@",response);
                 [HUD hide:YES];
                 [HUD removeFromSuperview];
        }];

}
-(void)makeRequestToLogout
{
    
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    
    [self addSpinnerView];
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dlogout"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 15 %@",response);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            if ([[[response objectAtIndex:0] objectForKey:@"result"]intValue] == 1)
            {
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"sessionid"];
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserName"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"profilePicLink"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Qualification"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [self performSegueWithIdentifier:@"DBToLogin" sender:@"Lougout"];
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Logout" message:@"Logout failed due to network issues. Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
                alert=nil;
                
            }
            
        });
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Logout" message:@"Logout failed due to network issues. Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        alert=nil;
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
}

-(void)makeRequestForDashboardDetails
{
    
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"ddash"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response)
     {
         NSLog(@"sucess 17 %@",response);
         if (response == nil)
         {
             [HUD hide:YES];
             [HUD removeFromSuperview];
             [self customAlertView:@"" Message:@"Internal server error" tag:0];
         }
         else{
             if ([[[response objectAtIndex:0] objectForKey:@"authorized"]integerValue] == 0 && [[[response objectAtIndex:0] objectForKey:@"result"]integerValue] == 0 && [[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
             {
                 SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                 smartLogin.loginDelegate=self;
                 [smartLogin makeLoginRequest];
                 
             }
             else{
                 if ([[response objectAtIndex:0] objectForKey:@"profilepic"] && ![[[response objectAtIndex:0] objectForKey:@"profilepic"] isKindOfClass:[NSNull class]] && ![[[response objectAtIndex:0] objectForKey:@"profilepic"] isEqualToString:@"<null>"] && [[response objectAtIndex:0] objectForKey:@"profilepic"] != nil && [[[response objectAtIndex:0] objectForKey:@"profilepic"] length] > 0)
                 {
                     [[NSUserDefaults standardUserDefaults]setObject:[[response objectAtIndex:0] objectForKey:@"profilepic"] forKey:@"profilePicLink"];
                     NSString *urlStr = [NSString stringWithFormat:@"%@%@",IMAGE_URL_TEST,[[response objectAtIndex:0] objectForKey:@"profilepic"]];
                     urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                     NSURL *url = [NSURL URLWithString:urlStr];
                     [self.doctorImg  sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"img_placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                         if (!error)
                         {
                         }
                         else
                         {
                             NSLog(@"Image Error : %@", error);
                         }
                     }];
                     
                 }
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 [HUD hide:YES];
                 [HUD removeFromSuperview];
                 self.view.userInteractionEnabled = YES;
             }
             
         } }failureHandler:^(id response) {
             NSLog(@"failure %@",response);
             [HUD hide:YES];
             [HUD removeFromSuperview];
         }];
}
- (void)makeRequestToResetPassword{
  if (![HUD isHidden]) {
    [HUD hide:YES];
   }
  [self addSpinnerView];
  NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
   NSString *bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"sessionid",sectionId, @"txtpass", self.password.text];
   NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dcpass"];
[[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response)
 {
     dispatch_async(dispatch_get_main_queue(),^{
         
         NSLog(@"sucess 15 %@",response);
         if (response == nil)
         {
             [HUD hide:YES];
             [HUD removeFromSuperview];
             [self customAlertView:@"" Message:@"Internal server error" tag:0];
         }
         else{
             if ([[response objectForKey:@"cpstatus"] integerValue] == 1)
             {
                 [HUD hide:YES];
                 [HUD removeFromSuperview];
                 [self customAlertView:@"" Message:@"Password reset successfully. Please relogin using new password." tag:pwdResetSuccess];
             }
             else{
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [HUD hide:YES];
                     [HUD removeFromSuperview];
                     [self customAlertView:@"" Message:@"Password reset failed. Please try again." tag:pwdResetSuccess];
                 });
             }
             
         }
     });
 }failureHandler:^(id response) {
     NSLog(@"failure %@",response);
     [HUD hide:YES];
     [HUD removeFromSuperview];
 }];
}
-(void)getDateCount{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
    [formatter2 setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [formatter2 stringFromDate:currentDate];
    NSDate *originalDate = [formatter2 dateFromString:dateStr];

    int count = 0;
    for (BookingResponseModel *model in self.bookingList) {
        NSDate *bookingDate = [formatter dateFromString:model.date];
        
        NSComparisonResult result = [bookingDate compare:originalDate];
        if (result == NSOrderedDescending){

            count +=model.bookingItems.count;

        }else if(result == NSOrderedSame){
            if (bookingDate != nil) {
                count +=model.bookingItems.count;

            }

        }
        
    }
    
    if (count > 0) {
        self.futureBookingsLbl.text = [NSString stringWithFormat:@"You have  %d appointment / E-Consult to be noticed",count];
    }else {
        self.futureBookingsLbl.text = @"You dont have any upcoming appointment / E-consults";
    }
}

#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender
{
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequstForBookingList:@"1"];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
    
}

-(void)logOutId:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Session expired. Please Re-login" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.delegate = self;
    alert.tag = KLogoutAlertTagFromCommon;
    [alert show];
}
#pragma mark - Tableview Delegate/Datasource Methods
-(NSString *)dateConvertor:(NSString *)dateStr{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [format setTimeZone:gmt];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [format dateFromString:dateStr];
    [format setDateFormat:@"dd-MMM-yyyy"];
    return [format stringFromDate:date];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count;
    if(tableView == self.tblMenu)
        count = 1;
    else
        count = self.bookingList.count;
   // NSLog(@"numberOfSectionsInTableView");
    return count;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    view.tintColor = [UIColor lightGrayColor];
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setFont:[UIFont systemFontOfSize:15]];

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    BookingResponseModel *model = self.bookingList[section];
    NSString *dateStr = [NSString stringWithFormat:@"Date : %@",[self dateConvertor:model.date]];
    return dateStr;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height;
    if(tableView == self.tblMenu)
        height = 0;
    else
        height = 40.0f;
    return height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"numberOfRowsInSection");
    BookingResponseModel *model = self.bookingList[section];
    if(tableView == self.tblMenu)
        return [_arrMenu count];
    else
        return  model.bookingItems.count;
       // return [dashItems count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRowAtIndexPath");
    if(tableView == self.tblMenu)
    {
        static NSString *cellIdentifier=@"MenuCellID";
        MenuTableViewCell *cell=(MenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.lblMenu.text=[_arrMenu objectAtIndex:indexPath.row];
        cell.imgViwMenu.image = [UIImage imageNamed:@"menu-arrow.png"];
        cell.lblMenu.font = [UIFont systemFontOfSize:14];
        return cell;
        
    }
    else
    {  //DashBoardAppointmentCell
        BookingResponseModel *model = self.bookingList[indexPath.section];
        NSArray *itemsArr = model.bookingItems;
        BookingItemResponseModel *itemModel = itemsArr[indexPath.row];
        if ([itemModel.bookingType isEqualToString:@"E-Consult"]) {
            DashBoardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dashCell"];
            
            [cell setCellData:itemModel];
            return cell;
        } else if ([itemModel.bookingType isEqualToString:@"Appointment"]){
            
            DashBoardAppointmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dashAppCell"];
            
            [cell setCellData:itemModel];
            return cell;
        }else{
            //if ([itemModel.bookingType isEqualToString:@"Second Opinion"])
           
            if (itemModel.bookingAppType == nil) {

                DashBoardAppointmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dashAppCell"];
                [cell setCellData:itemModel];
                return cell;
            } else {
                DashBoardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dashCell"];

                [cell setCellData:itemModel];
                return cell;
            }
           
        }
        
//        static NSString *cellIdentifier=@"dashCell";
//        smartRxDashboardTableCell *cell=(smartRxDashboardTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//        [cell setCellData:[dashItems objectAtIndex:indexPath.row] imgName:[dashItemImage objectAtIndex:indexPath.row]];
//        
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        
//        return cell;
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    if (tableView == _tblMenu)
    {
        [self hideMenu];
        MenuTableViewCell *cell=(MenuTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        //DBToPatLookUp
        //docProfile
        if ([cell.lblMenu.text isEqualToString:@"View Profile"])
            [self performSegueWithIdentifier:@"docProfile" sender:nil];
        else if([cell.lblMenu.text isEqualToString:@"Change Password"])
        {
            if (!bIsResetPwdSel)
            {
                [self loadResetPasswordView];
            }
            else
                [self hideResetPasswordView];
        }
        else if([cell.lblMenu.text isEqualToString:@"My Schedule"])
        {
            [self performSegueWithIdentifier:@"scheduleVC" sender:nil];
        }
        else if([cell.lblMenu.text isEqualToString:@"My Locations"])
        {
            [self performSegueWithIdentifier:@"myLocationsVc" sender:nil];
        }else if([cell.lblMenu.text isEqualToString:@"Chats"])
        {
            [self performSegueWithIdentifier:@"chatListVc" sender:nil];
            
        }else if([cell.lblMenu.text isEqualToString:@"Care Plans"])
        {
            [self performSegueWithIdentifier:@"DBToCarePlan" sender:nil];
        }else if([cell.lblMenu.text isEqualToString:@"Q & A"])
        {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"fromPatLookUp"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
            [self performSegueWithIdentifier:@"DBToQA" sender:nil];
        }
        else if([cell.lblMenu.text isEqualToString:@"Send Alert"])
        {
            [self performSegueWithIdentifier:@"sendAlertVc" sender:nil];
        }
        else if (indexPath.row == [_arrMenu count]-1)
        {
            
            [self logoutBtnClicked:nil];
        }
            
    }
    else
    {
        BookingResponseModel *model = self.bookingList[indexPath.section];
        NSArray *itemsArr = model.bookingItems;
        BookingItemResponseModel *itemModel = itemsArr[indexPath.row];
        NSArray *bookingArr = self.originalData[itemModel.bookingDate];
        NSLog(@"booking arr:%@",bookingArr);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.conid contains[cd] %@",itemModel.bookingConId];
        NSArray *filteredArr = [bookingArr filteredArrayUsingPredicate:predicate];
        NSLog(@"selectedDict :%@",filteredArr);
        NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K == %ld", @"locationId", [itemModel.locationId integerValue]];
        //NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"locationId contains[cd] %@",itemModel.locationId];
//keySelected is NSString itself
        NSArray *filteredLocationArr = [self.locationsArr filteredArrayUsingPredicate:predicateString];
        for ( LocationsModel *location in self.locationsArr) {
            NSLog(@"location id string :%@",location.locationId);
        }
        if (filteredLocationArr.count>0) {
            selectedLocation = filteredLocationArr[0];
            locationName = selectedLocation.type;

        }
        if ([itemModel.bookingType isEqualToString:@"E-Consult"]) {
             [self performSegueWithIdentifier:@"econsultDetailsVc" sender:filteredArr[0]];
        } else if ([itemModel.bookingType isEqualToString:@"Appointment"]){
             [self performSegueWithIdentifier:@"appointmentDeatilVc" sender:filteredArr[0]];
        }else {
            if (itemModel.bookingAppType == nil) {
                [self performSegueWithIdentifier:@"appointmentDeatilVc" sender:filteredArr[0]];

            }else {
                [self performSegueWithIdentifier:@"econsultDetailsVc" sender:filteredArr[0]];

            }
        }
       
//        smartRxDashboardTableCell *cell=(smartRxDashboardTableCell *)[tableView cellForRowAtIndexPath:indexPath];
//        
//        if ([cell.menuName.text isEqualToString:@"Appointments"])
//            [self performSegueWithIdentifier:@"DBToAppointment" sender:nil];
//        else if ([cell.menuName.text isEqualToString:@"E-Consult"])
//            [self performSegueWithIdentifier:@"DBToEconsult" sender:nil];
//        else if ([cell.menuName.text isEqualToString:@"Patient Lookup"])
//            [self performSegueWithIdentifier:@"DBToPatLookUp" sender:nil];
//        else if ([cell.menuName.text isEqualToString:@"Care Plans"])
//            [self performSegueWithIdentifier:@"DBToCarePlan" sender:nil];
//        else if ([cell.menuName.text isEqualToString:@"Q & A"])
//        {
//            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"fromPatLookUp"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            [self performSegueWithIdentifier:@"DBToQA" sender:nil];
//        }
        
    }
//    [self performSegueWithIdentifier:@"eConsultDetails" sender:[self.arr_eConsult objectAtIndex:indexPath.row]];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if(tableView == self.tblMenu){
        height = 44.0f;
    } else {
        
        
        BookingResponseModel *model = self.bookingList[indexPath.section];
        NSArray *itemsArr = model.bookingItems;
        
        BookingItemResponseModel *itemModel = itemsArr[indexPath.row];
        if ([itemModel.bookingType isEqualToString:@"Appointment"] && itemModel.reason.length > 1 ) {
            // height = 100.0f;
            height = [self estimatedHeight:itemModel.reason];
            
        }else if ([itemModel.bookingType isEqualToString:@"Second Opinion"] && itemModel.reason.length > 1 ) {
            // height = 100.0f;
            height = [self estimatedHeight:itemModel.reason];
            
        } else {
            height = 80.0f;
        }
    }
    return height;
}
-(CGFloat)estimatedHeight:(NSString *)strToCalCulateHeight
{
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(40,30, self.view.frame.size.width-175,21)];
    lblHeight.text = strToCalCulateHeight;
    lblHeight.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    //    NSLog(@"The number of lines is : %d\n and the text length is: %d", [lblHeight numberOfLines], [strToCalCulateHeight length]);
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width-175,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    CGFloat height = expectedLabelSize.height+79;
    //[self setLblYPostionAndHeight:expectedLabelSize.height+20];
    return height;
}
#pragma mark -Search bar Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self performSegueWithIdentifier:@"DBToPatLookUp" sender:nil];

}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 2) {
        [self makeRequstForSearch:searchText];
    }
    //[self.doctorDashMenu reloadData];
}
#pragma mark - Action Medthods
-(void)homeBtnClicked:(id)sender
{
    
    
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[smartRxDashboardVC class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}
-(IBAction)clickOnAddLocationeBtn:(id)sender{
    [self performSegueWithIdentifier:@"myLocationsVc" sender:nil];
    
}
-(IBAction)clickOnScheduleBtn:(id)sender{
    [self performSegueWithIdentifier:@"scheduleVC" sender:nil];
    
}
-(void)logoutBtnClicked:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Logout" message:@"Are you sure? Do you want to logout?" delegate:self cancelButtonTitle:@"Logout" otherButtonTitles:@"Cancel", nil];
        alert.tag=kLogoutAlertTag;
        [alert show];
        alert=nil;
    }
}

- (IBAction)docProfileClicked:(id)sender
{
    [self performSegueWithIdentifier:@"docProfile" sender:nil];
}

- (IBAction)hideMenuBtnClicked:(id)sender
{
    [self hideMenu];
}
-(IBAction)clickOnSearchBtn:(id)sender{
 [self performSegueWithIdentifier:@"DBToPatLookUp" sender:nil];
}
#pragma mark - Alert View Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kLogoutAlertTag && buttonIndex == 0)
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestToLogout];
        }
        else{
            
            [self customAlertView:@"" Message:@"Network not available" tag:0];
            
        }
        
    }
    else if (alertView.tag == KLogoutAlertTagFromCommon)
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        self.view.userInteractionEnabled = YES;
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"sessionid"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"profilePicLink"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Qualification"];        
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self performSegueWithIdentifier:@"DBToLogin" sender:@"Lougout"];
    } else if (alertView.tag == pwdResetSuccess){
        [self hideResetPasswordView];
        [self makeRequestToLogout];
    }
}

#pragma mark - Menu Methods
-(void)hideMenu
{
    [UIView animateWithDuration:0.2 animations:^{
        _viwMenu.frame=CGRectMake(viewSize.width,  _viwMenu.frame.origin.y,  _viwMenu.frame.size.width,  _viwMenu.frame.size.height);
    } completion:^(BOOL finished) {
        bIsMenuSel=NO;
    }];
}
-(void)loadMenu
{
    [UIView animateWithDuration:0.2 animations:^{
        _viwMenu.frame=CGRectMake(0,  _viwMenu.frame.origin.y,  _viwMenu.frame.size.width,  _viwMenu.frame.size.height);
    } completion:^(BOOL finished) {
        bIsMenuSel=YES;
    }];
}
-(IBAction)menuBtnClicked:(id)sender
{
//    if (bIsResetPwdSel)
//        [self hideResetPasswordView];
    if (!bIsMenuSel)
    {
        [_tblMenu reloadData];
        [self loadMenu];
    }
    else
        [self hideMenu];
}

#pragma mark - Reset Password methods
- (void)loadResetPasswordView
{
    [UIView animateWithDuration:0.2 animations:^{
        _viewReset.frame=CGRectMake(0,  _viewReset.frame.origin.y,  _viewReset.frame.size.width,  _viewReset.frame.size.height);
    } completion:^(BOOL finished) {
        bIsResetPwdSel=YES;
        bIsMenuSel = NO;
    }];
}
-(void)hideResetPasswordView
{
    [UIView animateWithDuration:0.2 animations:^{
        _viewReset.frame=CGRectMake(viewSize.width,  _viewReset.frame.origin.y,  _viewReset.frame.size.width,  _viewReset.frame.size.height);
    } completion:^(BOOL finished) {
        bIsResetPwdSel=NO;
    }];
}
- (IBAction)resetPwdClicked:(id)sender
{
    [self.view endEditing:YES];

    if ([self.password.text length] <= 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter password"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([self.retypePassword.text length] <= 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Please retype your password"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([self.password.text length] < 6)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Your password should have atleast 6 characters"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([self.password.text length] > 12)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Your password should have minimum of 6 and maximum of 12 characters"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if (![self.retypePassword.text isEqualToString:self.password.text])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Password mismatch. Please retype your password"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self makeRequestToResetPassword];
    }
    
}

- (IBAction)resetPwdCancelClicked:(id)sender
{
    [self.view endEditing:YES];
    password = nil;
    resetPassword = nil;
    self.retypePassword.text = nil;
    self.password.text = nil;
    [self hideResetPasswordView];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DBToEconsult"])
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"firstLoad"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else if ([segue.identifier isEqualToString:@"DBToAppointment"])
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"firstLoadAppointment"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    } else if ([segue.identifier isEqualToString:@"econsultDetailsVc"])
    {
        SmartRxeConsultDetailsVC *controller = segue.destinationViewController;
        
        controller.dictResponse = sender;
        
    }  else if ([segue.identifier isEqualToString:@"appointmentDeatilVc"])
    {
        AppointmentDetailsController *controller = segue.destinationViewController;
        controller.dictResponse = sender;
        controller.locationName = locationName;
        controller.selectedLocation = selectedLocation;
        //controller.selectedModel = sender;
        
    } else if ([segue.identifier isEqualToString:@"chatListVc"])
    {
        SmartRxChatListVC *controller = segue.destinationViewController;
        controller.patientDict = sender;
    }

    
}

@end
