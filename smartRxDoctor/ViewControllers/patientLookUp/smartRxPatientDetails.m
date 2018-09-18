//
//  smartRxPatientDetails.m
//  smartRxDoctor
//
//  Created by Manju Basha on 09/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "smartRxPatientDetails.h"
#import "UIImageView+WebCache.h"
#import "UIKit+AFNetworking.h"
#import "smartRxDashboardVC.h"
#import "SmartRxQuestionsPreviousVC.h"
#import "smartRxAssignedCarePlanVC.h"
#import "smartRxAssignNewCarePlan.h"
#import "ReportsVc.h"
#import "EhrDashBoardVc.h"

@interface smartRxPatientDetails ()

@end

@implementation smartRxPatientDetails

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBackButton];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height+100);
    [self setUserDetails];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUserDetails
{
    NSString *name = [self.userDetailsDict objectForKey:@"username"];
    NSString *age = nil;
    if ([[self.userDetailsDict objectForKey:@"age"] integerValue] > 0)
        age = [self.userDetailsDict objectForKey:@"age"];
    if (age != nil && [age length])
    {
        if ([[self.userDetailsDict objectForKey:@"gender"] integerValue] == 1)
            self.userName.text = [NSString stringWithFormat:@"%@/%@/M",name,age];
        else if([[self.userDetailsDict objectForKey:@"gender"] integerValue] == 2)
            self.userName.text = [NSString stringWithFormat:@"%@/%@/F",name,age];
        else
            self.userName.text = [NSString stringWithFormat:@"%@/%@",name,age];
    }
    else
    {
        if ([[self.userDetailsDict objectForKey:@"gender"] integerValue] == 1)
            self.userName.text = [NSString stringWithFormat:@"%@/M",name];
        else if([[self.userDetailsDict objectForKey:@"gender"] integerValue] == 2)
            self.userName.text = [NSString stringWithFormat:@"%@/F",name];
        else
            self.userName.text = name;
        
    }
    
    NSString *dpPlaceHolderName = @"male.png";
    if ([[self.userDetailsDict objectForKey:@"gender"] integerValue] == 1)
    {
        dpPlaceHolderName = @"male.png";
    }
    else if ([[self.userDetailsDict objectForKey:@"gender"] integerValue] == 2)
    {
        dpPlaceHolderName = @"female.png";
    }
    else
        dpPlaceHolderName = @"male.png";
    if ([[self.userDetailsDict objectForKey:@"profile_pic"] length] > 0 || [self.userDetailsDict objectForKey:@"profile_pic"])
    {
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",IMAGE_URL_TEST,[self.userDetailsDict objectForKey:@"profile_pic"]];
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlStr];
        [self.userDp  sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:dpPlaceHolderName] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (!error)
            {
            }
            else
            {
                NSLog(@"Image Error : %@", error);
            }
        }];
    }
    else
        self.userDp.image = [UIImage imageNamed:dpPlaceHolderName];
//    self.userDp.layer.cornerRadius = 10.0f;
//    self.userDp.clipsToBounds = YES;
//    self.userDp.layer.borderWidth = 1.f;
//    self.userDp.layer.borderColor = [UIColor clearColor].CGColor;
    self.userDp.layer.cornerRadius = self.userDp.frame.size.height /2;
    self.userDp.layer.masksToBounds = YES;
    self.userDp.layer.borderWidth = 0;    
    NSString *strBtn = [NSString stringWithFormat:@"Call %@",[self.userDetailsDict objectForKey:@"username"]];
    [self.callUser setTitle:strBtn forState:UIControlStateNormal];
    self.userMobile.text = [self.userDetailsDict objectForKey:@"primaryphone"];
}

-(void)navigationBackButton
{
    self.navigationItem.hidesBackButton=YES;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backBtnImage = [UIImage imageNamed:@"icn_back.png"];
    [backBtn setImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(-40, -2, 100, 40);
    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    backButtonView.bounds = CGRectOffset(backButtonView.bounds, 0, -7);
    [backButtonView addSubview:backBtn];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *btnFaq = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *faqBtnImag = [UIImage imageNamed:@"icn_home.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    [btnFaq addTarget:self action:@selector(homeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;
    
    
}
#pragma mark - Action Methods
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
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

- (IBAction)qaClicked:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"fromPatLookUp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSegueWithIdentifier:@"patientToQA" sender:nil];
}

- (IBAction)assignBtnClicked:(id)sender
{
//    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Coming Soon"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
    [self performSegueWithIdentifier:@"patLookToAssignCare" sender:nil];
}

- (IBAction)carePlanAssignedBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"patLookToCareAssigned" sender:nil];
}

- (IBAction)callBtnClicked:(id)sender
{
    NSString *phoneNumber=self.userMobile.text;    
    NSString *number = [NSString stringWithFormat:@"%@",phoneNumber];
    NSURL* callUrl=[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",number]];
    //check  Call Function available only in iphone
    if([[UIApplication sharedApplication] canOpenURL:callUrl])
    {
        [[UIApplication sharedApplication] openURL:callUrl];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"ALERT" message:@"This function is only available on the iPhone"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}
-(IBAction)clickOnReportsBtn:(id)sender{
    //personalhealthVc
    //reportsVc
    [self performSegueWithIdentifier:@"reportsVc" sender:nil];
}
-(IBAction)clickOnEhrBtn:(id)sender{
    [self performSegueWithIdentifier:@"ehrDashVc" sender:nil];

}
#pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"patientToQA"])
    {
        ((SmartRxQuestionsPreviousVC *)segue.destinationViewController).patientID = [self.userDetailsDict objectForKey:@"value"];
    }
    else if ([segue.identifier isEqualToString:@"patLookToCareAssigned"])
    {
        ((smartRxAssignedCarePlanVC *)segue.destinationViewController).patientID = [self.userDetailsDict objectForKey:@"value"];
        ((smartRxAssignedCarePlanVC *)segue.destinationViewController).patName = [self.userDetailsDict objectForKey:@"username"];
    }
    else if ([segue.identifier isEqualToString:@"patLookToAssignCare"])
    {
        ((smartRxAssignNewCarePlan *)segue.destinationViewController).patientID = [self.userDetailsDict objectForKey:@"value"];
        ((smartRxAssignNewCarePlan *)segue.destinationViewController).patName = [self.userDetailsDict objectForKey:@"username"];
    }
    else if ([segue.identifier isEqualToString:@"reportsVc"])
    {
        ((ReportsVc *)segue.destinationViewController).patientId = [self.userDetailsDict objectForKey:@"value"];
       
    }
    else if ([segue.identifier isEqualToString:@"reportsVc"])
    {
        ((EhrDashBoardVc *)segue.destinationViewController).patientId = [self.userDetailsDict objectForKey:@"value"];
        
    }
}
@end
