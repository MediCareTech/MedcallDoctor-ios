//
//  smartRxLoginVC.m
//  smartRxDoctor
//
//  Created by Manju Basha on 04/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "smartRxLoginVC.h"
#import "NetworkChecking.h"
#import "NSString+MD5.h"
#import "smartRxRegisterVC.h"
#define kMobileTxtTag 5002
#define kPwdTxtTag 5003

@interface smartRxLoginVC ()
{
    MBProgressHUD *HUD;
    UIToolbar* doneToolbar;
}
@end

@implementation smartRxLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.txtPassword.secureTextEntry=YES;
//    self.navigationItem.leftBarButtonItem = nil;
//    self.navigationItem.hidesBackButton=YES;
    [self SetNavigationBarItems];
    doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    self.txtPassword.inputAccessoryView = doneToolbar;
    self.txtMobile.inputAccessoryView = doneToolbar;
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"MobileNumber"])
    {
        self.txtMobile.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobileNumber"];
    }
    
}
-(void)SetNavigationBarItems
{
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
#pragma mark - Action Methods

- (IBAction)signInBtnClicked:(id)sender
{
    [self.txtMobile resignFirstResponder];
    
    if ([self.txtMobile.text length] > 0)
    {
        if ([self.txtMobile.text length] <10)
        {
            [self customAlertView:@"" Message:@"Phone number cannot be less than 10 digits" tag:0];
        }
        else if (![self.txtPassword.text length] || self.txtPassword.text == nil)
        {
            [self customAlertView:@"" Message:@"Password cannot be empty" tag:0];
        }
        else{
            NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
            if ([networkAvailabilityCheck reachable])
            {
                [self makeLoginRequest:nil];
            }
            else{
                
                [self customAlertView:@"" Message:@"Network not available" tag:0];
            }
        }
    }
    else if (![self.txtMobile.text length] || self.txtMobile.text == nil)
    {
        [self customAlertView:@"" Message:@"Phone number cannot be empty" tag:0];
    }
    else if (![self.txtPassword.text length] || self.txtPassword.text != nil)
    {
        [self customAlertView:@"" Message:@"Password cannot be empty" tag:0];
    }
}

- (IBAction)registerClicked:(id)sender
{
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[smartRxRegisterVC class]])
        {
            [self.navigationController popToViewController:controller animated:NO];
        }
    }
}

- (IBAction)forgotPwdClicked:(id)sender
{
    [self performSegueWithIdentifier:@"resetPwd" sender:nil];
}
- (void)doneButton:(id)sender {
    [self.txtMobile resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    if (self.currentTextField.tag == kPwdTxtTag)
    {
        [self signInBtnClicked:nil];
    }
    
}
#pragma mark - Text filed Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == kMobileTxtTag)
    {
        self.currentTextField = self.txtMobile;
        
    }
    if (textField.tag == kPwdTxtTag)
    {
        self.currentTextField = self.txtPassword;
    }
    
}
#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
    
}

#pragma mark - Make Request methods
-(void)addSpinnerView
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
-(void)makeLoginRequest :(NSString *)cid
{
    [[NSUserDefaults standardUserDefaults]setObject:self.txtMobile.text forKey:@"MobileNumber"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    NSString *strPasword=nil;
    
    if ([self.txtPassword.text length] > 0)
    {
        strPasword = self.txtPassword.text;
        //strPasword=[NSString md5:self.txtPassword.text];//@"172603"];
    }
    if (strPasword && [self.txtMobile.text length] > 0)
    {
        
        if (![HUD isHidden]) {
            [HUD hide:YES];
        }
        [self addSpinnerView];
        
        NSData *data = [[NSUserDefaults standardUserDefaults] valueForKey:@"PushToken"];
        NSString *strPushToken = [[[data description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"push token.....:%@",strPushToken);
        NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
        NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"mobile",self.txtMobile.text];
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"cid",strCid]];
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"pass",strPasword]];
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"regId",strPushToken]];
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"mode",@"2"]];
        
        
        NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dlogin"];
        
        [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
            NSLog(@"sucess 23 %@",response);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (response == nil || response == NULL || response == [NSNull null])
                {
                    //[self customAlertView:@"Login error" Message:@"Try again" tag:0];
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    
                    [self makeLoginRequest:nil];
                }
                else if ([response isKindOfClass:[NSArray class]])
                {
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    //[[response objectForKey:@"result"] integerValue] == 0
                    self.view.userInteractionEnabled = YES;
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Wrong password" message:@"Enter correct password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
                else{
                    
                    if ([response objectForKey:@"biography"] && ![[response objectForKey:@"biography"] isKindOfClass:[NSNull class]] && [response objectForKey:@"biography"] != nil && [[response objectForKey:@"biography"] length] > 0)
                    {
                            [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"biography"] forKey:@"Biography"];
                    }
                    if ([response objectForKey:@"qualification"] && ![[response objectForKey:@"qualification"] isKindOfClass:[NSNull class]] && ![[response objectForKey:@"qualification"] isEqualToString:@"<null>"] && [response objectForKey:@"qualification"] != nil && [[response objectForKey:@"qualification"] length] > 0)
                    {
                            [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"qualification"] forKey:@"Qualification"];
                    }

                    if ([response objectForKey:@"profilepic"] && ![[response objectForKey:@"profilepic"] isKindOfClass:[NSNull class]] && ![[response objectForKey:@"profilepic"] isEqualToString:@"<null>"] && [response objectForKey:@"profilepic"] != nil && [[response objectForKey:@"profilepic"] length] > 0)
                    {
                            [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"profilepic"] forKey:@"profilePicLink"];

                    }
                    [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"hosid"] forKey:@"hosid"];
                    
                    [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"sessionid"] forKey:@"sessionid"];
                    [[NSUserDefaults standardUserDefaults]setObject:self.txtMobile.text forKey:@"MobileNumber"];
                    [[NSUserDefaults standardUserDefaults]setObject:self.txtPassword.text forKey:@"Password"];
                    [[NSUserDefaults standardUserDefaults]setObject:cid forKey:@"cid"];
                    [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"dispname"] forKey:@"UserName"];
                    [[NSUserDefaults standardUserDefaults]setObject:self.txtMobile.text forKey:@"MobileNumber"];
                    [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"session_name"] forKey:@"SessionName"];
                    [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"recno"] forKey:@"userid"];
                    [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"emailid"] forKey:@"emailId"];
                    [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"usertype"] forKey:@"usertype"];

                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [HUD hide:YES];
                        [HUD removeFromSuperview];
                        self.view.userInteractionEnabled = YES;
                        
//                        [self.navigationController popViewControllerAnimated:YES];
                        
                        [self performSegueWithIdentifier:@"loginDashBoard" sender:nil];
                    });
                }
            });
        } failureHandler:^(id response) {
            NSLog(@"failure %@",response);
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Login failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [HUD hide:YES];
            [HUD removeFromSuperview];
        }];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
