//
//  smartRxRegisterVC.m
//  smartRxDoctor
//
//  Created by Manju Basha on 04/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "smartRxRegisterVC.h"
#import "NetworkChecking.h"
#define kMobileTxtTag 5001
#define kCodeTxtTag 5000

@interface smartRxRegisterVC()
{
    UIToolbar* doneToolbar;
    MBProgressHUD *HUD;
}
@end

@implementation smartRxRegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.hidesBackButton = YES;
//    self.navigationItem.leftBarButtonItem = nil;
    doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    self.txtCode.inputAccessoryView = doneToolbar;
    self.txtMobile.inputAccessoryView = doneToolbar;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"MobileNumber"])
    {
        self.txtMobile.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"MobileNumber"];
        self.txtCode.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"custCode"];
    }
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"Reinstalling"])
    {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"Reinstalling"];
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"] boolValue])
        {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"sessionid"])
            {
                [self performSegueWithIdentifier:@"validToDashboard" sender:nil];
            }
            else
            {
                [self performSegueWithIdentifier:@"loginSegue" sender:nil];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Make Request methods
-(void)addSpinnerView
{
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
    [alertView show];
    alertView=nil;
}
#pragma mark - Text filed Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == kCodeTxtTag)
    {
        self.currentBtn = self.txtCode;
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.frame=CGRectMake(self.scrollView.frame.origin.x,self.scrollView.frame.origin.y-2*self.txtCode.frame.size.height, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        }];
        
    }
    if (textField.tag == kMobileTxtTag)
    {
        self.currentBtn = self.txtMobile;
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-doneToolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == kCodeTxtTag)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.frame=CGRectMake(self.scrollView.frame.origin.x,self.scrollView.frame.origin.y+2*self.txtCode.frame.size.height, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        }];
        
    }
    if (textField.tag == kMobileTxtTag)
    {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+doneToolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        }];
        
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.txtMobile)
    {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 10) ? NO : YES;
    }
    return YES;
}
#pragma mark - Action Methods
- (IBAction)validateBtnClicked:(id)sender
{
    [self.txtMobile resignFirstResponder];
    [self.txtCode resignFirstResponder];
    
    if ([self.txtMobile.text length] > 0 && [self.txtCode.text length] > 0)
    {
        if ([self.txtMobile.text length] <10)
        {
            //[self customAlertView:@"Phone number cannot be less than 10 digits"];
            [self customAlertView:@"" Message:@"Phone number cannot be less than 10 digits" tag:0];
        }
        else if([self.txtMobile.text length] > 10)
        {
            [self customAlertView:@"" Message:@"Phone number cannot be more than 10 digits" tag:0];
        }
        else{
            NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
            if ([networkAvailabilityCheck reachable])
            {
                [self makeRequestForUserRegister];
            }
            else{
                
                [self customAlertView:@"" Message:@"Network not available" tag:0];
            }
        }
    }
    else if (![self.txtCode.text length] || self.txtCode.text == nil)
    {
        [self customAlertView:@"" Message:@"Customer code cannot be empty" tag:0];        
    }
    else
    {
        [self customAlertView:@"" Message:@"Phone Number cannot be empty" tag:0];
    }
}

- (void)doneButton:(id)sender {
    [self.txtMobile resignFirstResponder];
    [self.txtCode resignFirstResponder];    
}
#pragma mark - Request Methods

-(void)makeRequestForUserRegister
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    
    [self addSpinnerView];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"mobile",self.txtMobile.text];
    bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"code",self.txtCode.text]];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dregister"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 33 %@",response);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            [[NSUserDefaults standardUserDefaults]setObject:self.txtCode.text forKey:@"code"];
            [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cidd"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            if ([[response objectForKey:@"dvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [self customAlertView:@"" Message:@"Invalid Customer code or mobile number. Please try again later" tag:0];
            }
            else if ([[response objectForKey:@"dvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [self performSegueWithIdentifier:@"loginSegue" sender:nil];
//                [self customAlertView:@"User already registered" Message:@"Login now" tag:kRegistredUserAlertTag];
            }
            else if ([[response objectForKey:@"dvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"" Message:@"Invalid Customer code or mobile number. Please try again later" tag:0];
            }
            else if ([[response objectForKey:@"dvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"" Message:@"Invalid Customer code or mobile number. Please try again later" tag:0];
            }
            
             if ([[[response objectForKey:@"hinfo"] objectForKey:@"customer_settings"] integerValue] == 1)
                    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"custSettings"];
            else
                    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"custSettings"];                
            [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cid"];
            NSString *strFrontDestNum=[[response objectForKey:@"hinfo"]objectForKey:@"frontDeskNo" ];
            
            [[NSUserDefaults standardUserDefaults]setObject:strFrontDestNum forKey:@"EmNumber"];
            [[NSUserDefaults standardUserDefaults]setObject:self.txtCode.text forKey:@"custCode"];
            NSString *strHospName=[[response objectForKey:@"hinfo"]objectForKey:@"hospitalName" ];
            
            [[NSUserDefaults standardUserDefaults]setObject:strHospName forKey:@"HosName"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [[NSUserDefaults standardUserDefaults]setObject:self.txtMobile.text forKey:@"MobileNumber"];
            [[NSUserDefaults standardUserDefaults] setObject:[[response objectForKey:@"hinfo"] objectForKey:@"splash_screen"] forKey:@"splash_screen"];//logo
            if ([[response objectForKey:@"hinfo"] objectForKey:@"mlogo"] && [[response objectForKey:@"hinfo"] objectForKey:@"mlogo"] != [NSNull null])
                [[NSUserDefaults standardUserDefaults] setObject:[[response objectForKey:@"hinfo"] objectForKey:@"mlogo"] forKey:@"logo"];
            else
                [[NSUserDefaults standardUserDefaults] setObject:[[response objectForKey:@"hinfo"] objectForKey:@"logo"] forKey:@"logo"];
            //             [[NSUserDefaults standardUserDefaults] setObject:[[response objectForKey:@"hinfo"] objectForKey:@"mlogo"] forKey:@"logo"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            //change
        });
    } failureHandler:^(id response) {
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Error occured" Message:@"Try again" tag:0];
        
    }];
}
@end
