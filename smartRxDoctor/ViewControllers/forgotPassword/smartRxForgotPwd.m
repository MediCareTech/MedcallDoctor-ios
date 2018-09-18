//
//  smartRxForgotPwd.m
//  smartRxDoctor
//
//  Created by Manju Basha on 05/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "smartRxForgotPwd.h"
#define kSuccessAlertTag 345
@interface smartRxForgotPwd ()
{
    MBProgressHUD *HUD;
    UIToolbar* doneToolbar;    
}
@end

@implementation smartRxForgotPwd

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self navigationBackButton];
    doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    self.txtMobileNumber.inputAccessoryView = doneToolbar;
    
    // Do any additional setup after loading the view.
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
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"MobileNumber"])
    {
        self.txtMobileNumber.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobileNumber"];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action Methods

-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButton:(id)sender
{
    [self.txtMobileNumber resignFirstResponder];
}

- (IBAction)resetPasswordClicked:(id)sender
{
    [self.txtMobileNumber resignFirstResponder];
    if ([self.txtMobileNumber.text length]> 9)
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestToGetPassword];
        }
        else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            alertView=nil;
        }
    }
    else if([self.txtMobileNumber.text length] == 0)
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Mobile number cannot be empty" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView=nil;
        
    }
    else if([self.txtMobileNumber.text length] < 10)
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Mobile number cannot be less than 10 digits." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView=nil;
    }

}
#pragma mark - Request Method
-(void)makeRequestToGetPassword
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"mobile",self.txtMobileNumber.text];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dreset"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 22 %@",response);
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        if ([[[response objectAtIndex:0]objectForKey:@"result"]integerValue] == 1)
            
        {
            [[NSUserDefaults standardUserDefaults]setObject:self.txtMobileNumber.text forKey:@"MobileNumber"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Your password has been sent to your mobile. Please enter the password to continue" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag=kSuccessAlertTag;
            [alert show];
            
        }
        else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Mobile number you entered is not registered." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading appointments failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}

-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
#pragma mark - Alert Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kSuccessAlertTag && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
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
