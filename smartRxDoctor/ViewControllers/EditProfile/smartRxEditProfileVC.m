//
//  smartRxEditProfileVC.m
//  smartRxDoctor
//
//  Created by Manju Basha on 05/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "smartRxEditProfileVC.h"
#import "UIImageView+WebCache.h"
#import "UIKit+AFNetworking.h"
#import "AFNetworking.h"
#import "smartRxDashboardVC.h"
@interface smartRxEditProfileVC ()
{
    MBProgressHUD *HUD;
    CGFloat heightLbl;

}

@end

@implementation smartRxEditProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBackButton];
//    self.backgroundView.hidden = YES;
    [self createBorderForAllBoxes];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.detailsViewContainer.frame.origin.y+self.detailsViewContainer.frame.size.height+250);
    self.detailsViewContainer.frame = CGRectMake(self.detailsViewContainer.frame.origin.x, self.doctorImg.frame.origin.y+self.doctorImg.frame.size.height+10, self.detailsViewContainer.frame.size.width, self.detailsViewContainer.frame.size.height);
    [self makeRequestToGetProfile];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods

-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)homeBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
//    for (UIViewController *controller in [self.navigationController viewControllers])
//    {
//        if ([controller isKindOfClass:[smartRxDashboardVC class]])
//        {
//            [self.navigationController popToViewController:controller animated:YES];
//        }
//    }

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)updateBtnClicked:(id)sender
{
    [self doneButton:nil];
    if (![self.docName.text length] || self.docName.text == nil)
    {
        [self customAlertView:@"" Message:@"Doctor's name cannot be empty" tag:0];
        return;
    }
    else if (![self.docEducation.text length] || self.docEducation.text == nil)
    {
        [self customAlertView:@"" Message:@"Doctor's qualification cannot be empty" tag:0];
        return;
    }
    else
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForProfileUpdation];
            //[self makeRequestForUdateProfile];
        }
        else{
            
            [self customAlertView:@"" Message:@"Network not available" tag:0];
            
        }
    }
}

- (IBAction)backButton:(id)sender
{
        [self.navigationController popViewControllerAnimated:YES];
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
-(void)estimatedHeight:(NSString *)strToCalCulateHeight
{
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(40,30, 300,21)];
    lblHeight.text = strToCalCulateHeight;
    lblHeight.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    NSLog(@"The number of lines is : %d\n and the text length is: %d", [lblHeight numberOfLines], [strToCalCulateHeight length]);
    CGSize maximumLabelSize = CGSizeMake(300,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    heightLbl=expectedLabelSize.height;
    //[self setLblYPostionAndHeight:expectedLabelSize.height+20];
}

#pragma mark - Request Methods
-(void)makeRequestToGetProfile
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dprofile"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 16 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            if ([[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"profilepic"] && ![[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"profilepic"] isKindOfClass:[NSNull class]] && ![[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"profilepic"] isEqualToString:@"<null>"] && [[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"profilepic"] != nil && [[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"profilepic"] length] > 0)
            {
                NSString *urlStr = [NSString stringWithFormat:@"%@%@",IMAGE_URL_TEST,[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"profilepic"]];
                urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL *url = [NSURL URLWithString:urlStr];
                [[NSUserDefaults standardUserDefaults]setObject:[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"profilepic"] forKey:@"profilePicLink"];
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
            else
            {
                self.doctorImg.image = [UIImage imageNamed:@"img_placeholder.png"];
            }
            self.docName.text = [[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"dispname"];
            [self estimatedHeight:[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"qualification"]];
            self.docEducation.text = [[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"qualification"];
            [[NSUserDefaults standardUserDefaults] setObject:[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"qualification"] forKey:@"Qualification"];
            [[NSUserDefaults standardUserDefaults]setObject:[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"dispname"] forKey:@"UserName"];
            [[NSUserDefaults standardUserDefaults]synchronize];            
            self.docEducationPlaceHolder.hidden = YES;
            if (heightLbl > 30)
            {
                self.docEducation.frame = CGRectMake(self.docEducation.frame.origin.x, self.docEducation.frame.origin.y, self.docEducation.frame.size.width, self.docEducation.frame.size.height+heightLbl);
                self.docEducationPlaceHolder.frame = CGRectMake(self.docEducation.frame.origin.x, self.docEducation.frame.origin.y, self.docEducation.frame.size.width, self.docEducationPlaceHolder.frame.size.height);
                [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + heightLbl+250)];
                self.detailsViewContainer.frame = CGRectMake(self.detailsViewContainer.frame.origin.x, self.detailsViewContainer.frame.origin.y, self.detailsViewContainer.frame.size.width, self.detailsViewContainer.frame.size.height+heightLbl);
                
                
            }

            if ([[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"experience"] && ![[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"experience"] isKindOfClass:[NSNull class]] && ![[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"experience"] isEqualToString:@"<null>"] && [[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"experience"] != nil && [[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"experience"] length] > 0)
            {
                NSString *htmlString=[[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"experience"]stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
                NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                
                self.docExp.frame = CGRectMake(self.docExp.frame.origin.x, self.docEducation.frame.origin.y+self.docEducation.frame.size.height+15, self.docExp.frame.size.width, self.docExp.frame.size.height);
                self.docExp.text = [attrStr string];//[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"experience"];
            }
            if ([[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"profsummary"] && ![[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"profsummary"] isKindOfClass:[NSNull class]] && ![[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"profsummary"] isEqualToString:@"<null>"] && [[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"profsummary"] != nil && [[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"profsummary"] length] > 0)
            {
                [self estimatedHeight:[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"profsummary"]];
                self.docDesignation.text = [[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"profsummary"];
                if (heightLbl > 30)
                {
                    self.docDesignation.frame = CGRectMake(self.docDesignation.frame.origin.x, self.docExp.frame.origin.y + self.docExp.frame.size.height + 15, self.docDesignation.frame.size.width, self.docDesignation.frame.size.height+heightLbl);
                    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + heightLbl+250)];
                    self.detailsViewContainer.frame = CGRectMake(self.detailsViewContainer.frame.origin.x, self.detailsViewContainer.frame.origin.y, self.detailsViewContainer.frame.size.width, self.detailsViewContainer.frame.size.height+heightLbl);
                    self.docDesignationPlaceHolder.frame = CGRectMake(self.detailsViewContainer.frame.origin.x, self.detailsViewContainer.frame.origin.y, self.detailsViewContainer.frame.size.width, self.docDesignationPlaceHolder.frame.size.height);
                }
                else
                {
                    self.docDesignation.frame = CGRectMake(self.docDesignation.frame.origin.x, self.docExp.frame.origin.y + self.docExp.frame.size.height + 15, self.docDesignation.frame.size.width, self.docDesignation.frame.size.height);
                    self.docDesignationPlaceHolder.frame = CGRectMake(self.docDesignation.frame.origin.x, self.docExp.frame.origin.y + self.docExp.frame.size.height + 15, self.docDesignation.frame.size.width, self.docDesignationPlaceHolder.frame.size.height);
                }
                self.docDesignationPlaceHolder.hidden = YES;
//                self.docDesignationPlaceHolder.frame = [self.docDesignation bounds];
            }
            
            if ([[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"biography"] && ![[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"biography"] isKindOfClass:[NSNull class]] && ![[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"biography"] isEqualToString:@"<null>"] && [[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"biography"] != nil && [[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"biography"] length] > 0)
            {

                NSString *htmlString=[[[[response objectForKey:@"profie"] objectAtIndex:0] objectForKey:@"biography"]stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
                NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                [self estimatedHeight:[attrStr string]];
                self.docExpertise.text = [attrStr string];
                self.docExpertisePlaceHolder.hidden = YES;
                if (heightLbl > 30)
                {
                    self.docExpertise.frame = CGRectMake(self.docExpertise.frame.origin.x, self.docDesignation.frame.origin.y+self.docDesignation.frame.size.height+15, self.docExpertise.frame.size.width, self.docExpertise.frame.size.height+heightLbl);
                    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + heightLbl+250)];
                    self.detailsViewContainer.frame = CGRectMake(self.detailsViewContainer.frame.origin.x, self.detailsViewContainer.frame.origin.y, self.detailsViewContainer.frame.size.width, self.detailsViewContainer.frame.size.height+heightLbl);
                    self.docExpertisePlaceHolder.frame = CGRectMake(self.detailsViewContainer.frame.origin.x, self.detailsViewContainer.frame.origin.y, self.detailsViewContainer.frame.size.width, self.docExpertisePlaceHolder.frame.size.height);
                }
                else
                {
                    self.docExpertise.frame = CGRectMake(self.docExpertise.frame.origin.x, self.docDesignation.frame.origin.y+self.docDesignation.frame.size.height+15, self.docExpertise.frame.size.width, self.docExpertise.frame.size.height);
                    self.docExpertisePlaceHolder.frame = CGRectMake(self.docExpertise.frame.origin.x, self.docDesignation.frame.origin.y+self.docDesignation.frame.size.height+15, self.docExpertise.frame.size.width, self.docExpertisePlaceHolder.frame.size.height);
                }
            }
            self.updateBtn.frame = CGRectMake(self.updateBtn.frame.origin.x, self.docExpertise.frame.origin.y+self.docExpertise.frame.size.height+25, self.updateBtn.frame.size.width, self.updateBtn.frame.size.height);
            self.backBtn.frame = CGRectMake(self.backBtn.frame.origin.x, self.docExpertise.frame.origin.y+self.docExpertise.frame.size.height+25, self.backBtn.frame.size.width, self.backBtn.frame.size.height);
            if ((self.backBtn.frame.origin.y + self.backBtn.frame.size.height + heightLbl) > self.scrollView.contentSize.height)
                [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.backBtn.frame.origin.y + self.backBtn.frame.size.height + heightLbl+250)];
            else
                [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.backBtn.frame.origin.y + self.backBtn.frame.size.height + heightLbl + 750)];
            self.detailsViewContainer.frame = CGRectMake(self.detailsViewContainer.frame.origin.x, self.detailsViewContainer.frame.origin.y, self.detailsViewContainer.frame.size.width, self.detailsViewContainer.frame.size.height+heightLbl+300);
        }
    } failureHandler:^(id response) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"The request timed out" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
       // [alert show];
        [self customAlertView:@"Error" Message:@"Loading profile failed due to network issues" tag:0];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}
-(void)makeRequestForProfileUpdation
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strSeccionName=[[NSUserDefaults standardUserDefaults]objectForKey:@"SessionName"];
    NSDictionary *dictTemp=[[NSDictionary alloc]initWithObjectsAndKeys:sectionId,@"sessionid",self.docName.text,@"dispname",@"",@"langs",self.docEducation.text,@"qual",self.docExp.text,@"exp",self.docDesignation.text,@"psumm",self.docExpertise.text,@"bio",self.docRecNo.text,@"expertise",strSeccionName,@"session_name",self.docDepartment.text,@"spectxt", nil];
    NSLog(@"BODY TEXT = %@",dictTemp);
    [self addSpinnerView];
    [self uploadImage:dictTemp];
}

#pragma mark - posting profile using AFNetworking
-(void) uploadImage:(NSDictionary *)info
{
    
    CGSize newSize = CGSizeMake(100.0f, 100.0f);
    UIGraphicsBeginImageContext(newSize);
    [self.doctorImg.image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage=nil;
    if (self.doctorImg.image != nil)
    {
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    
    //    NSData *imgData = UIImageJPEGRepresentation(newImage, 1); //1 it represents the quality of the image.
    //    NSLog(@" final Size of Image(bytes):%lu",(unsigned long)[imgData length]);
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:WB_BASEURL]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *cokie = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
    [manager.requestSerializer setValue:cokie forHTTPHeaderField:@"Cookie"];
    UIImage *image = newImage;//self.imgProfile.image;
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSString *strUrl=[NSString stringWithFormat:@"%@dupdtepro",WB_BASEURL];
    
    AFHTTPRequestOperation * op = [manager POST:strUrl parameters:info constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        // NSTimeInterval is defined as double
        NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];

        [formData appendPartWithFileData:imageData name:@"photoimg" fileName:[NSString stringWithFormat:@"temp%@.jpg",timeStampObj] mimeType:@"image/jpeg"];
        [manager.requestSerializer setTimeoutInterval:30.0];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        
        if ([[responseObject objectForKey:@"authorized"]integerValue] == 0 && [[responseObject objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.view.userInteractionEnabled = YES;
                
                if ([[responseObject objectForKey:@"dataupdate"]intValue] == 1 && [[responseObject objectForKey:@"authorized"]intValue] == 1 && [[responseObject objectForKey:@"fileupload"]intValue] == 1 && [[responseObject objectForKey:@"result"]intValue] == 1)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:self.docEducation.text forKey:@"Qualification"];
                    [[NSUserDefaults standardUserDefaults]setObject:self.docName.text forKey:@"UserName"];
                    [[NSUserDefaults standardUserDefaults]setObject:[responseObject objectForKey:@"pictureupdate"] forKey:@"profilePicLink"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    [self customAlertView:@"" Message:@"Profile updated successfully" tag:100];
                }
                else if ([[responseObject objectForKey:@"dataupdate"]intValue] == 1 && [[responseObject objectForKey:@"authorized"]intValue] == 1 && [[responseObject objectForKey:@"fileupload"]intValue] == 0 && [[responseObject objectForKey:@"result"]intValue] == 1)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:self.docEducation.text forKey:@"Qualification"];
                    [[NSUserDefaults standardUserDefaults]setObject:self.docName.text forKey:@"UserName"];
                    [[NSUserDefaults standardUserDefaults]setObject:[responseObject objectForKey:@"pictureupdate"] forKey:@"profilePicLink"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    [self customAlertView:@"" Message:@"Profile details updated successfully, but profile picture update failed due to network issues. Please try again later" tag:200];
                }
                else if ([[responseObject objectForKey:@"added"]intValue] == 0 && [[responseObject objectForKey:@"authorized"]intValue] == 1 && [[responseObject objectForKey:@"fileupload"]intValue] == 0 && [[responseObject objectForKey:@"result"]intValue] == 0)
                {
                    [self customAlertView:@"" Message:@"Adding details and profile picture uploading failed due to network issues. Please try again later" tag:0];
                }
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
    
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [op start];
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

- (IBAction)imgaePickerBtnClicked:(id)sender
{
    [self showActionSheet:nil];
}

-(void)showActionSheet:(id)sender {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Gallery", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}
#pragma mark borderMethod
- (void)createBorderForAllBoxes
{
    self.docEducation.layer.cornerRadius=0.0f;
    self.docEducation.layer.masksToBounds = YES;
    self.docEducation.layer.borderColor = [[UIColor blackColor] CGColor];
    //[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.docEducation.layer.borderWidth= 1.0f;
    
    self.docDesignation.layer.cornerRadius=0.0f;
    self.docDesignation.layer.masksToBounds = YES;
    self.docDesignation.layer.borderColor = [[UIColor blackColor] CGColor];
    //[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.docDesignation.layer.borderWidth= 1.0f;

    self.docExpertise.layer.cornerRadius=0.0f;
    self.docExpertise.layer.masksToBounds = YES;
    self.docExpertise.layer.borderColor = [[UIColor blackColor] CGColor];
    //[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.docExpertise.layer.borderWidth= 1.0f;
    
}
#pragma mark - Alert view Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100 || alertView.tag == 200)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - Action Sheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
    {
        NSLog(@"Camera Clicked");
        [self takePhoto];
        
    } else if (buttonIndex == 1)
    {
        NSLog(@"Gallery Clicked");
        [[SmartRxCommonClass sharedManager] openGallary:self];
    } else if (buttonIndex == 2) {
        NSLog(@"Cancel Clicked");
    }
    
}
- (void)takePhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}
#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // self.imgProfile.image=info[UIImagePickerControllerEditedImage];
    [self compression:info[UIImagePickerControllerEditedImage]];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
-(void)imageSelected:(UIImage *)image{
    //self.imgProfile.image=image;
    [self compression:image];
}

-(void)compression:(UIImage *)image
{
    
    //compression of image
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.01f;
    int maxFileSize = 250*1024;
    
    NSData *imageData = UIImageJPEGRepresentation(image,compression);
    
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 10.9;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    //display image
    
    [self.doctorImg setImage:[UIImage imageWithData:imageData]];
    
    
}
#pragma mark - Textfield Delegates

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    textField.inputAccessoryView = doneToolbar;
    self.backgroundView.hidden = NO;
}
- (void)doneButton:(id)sender {
    self.backgroundView.hidden = YES;
    [self.docDepartment resignFirstResponder];
    [self.docDesignation resignFirstResponder];
    [self.docEducation resignFirstResponder];
    [self.docExp resignFirstResponder];
    [self.docExpertise resignFirstResponder];
    
    [self.docName resignFirstResponder];
    [self.docRecNo resignFirstResponder];
}
#pragma mark - TextView Delegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    textView.inputAccessoryView = doneToolbar;
    self.backgroundView.hidden = NO;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 800)];
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.docEducation)
        self.docEducationPlaceHolder.hidden = YES;
    else if (textView == self.docDesignation)
        self.docDesignationPlaceHolder.hidden = YES;
    else if (textView == self.docExpertise)
        self.docExpertisePlaceHolder.hidden = YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];    
    if (textView == self.docEducation)
    {
        if ([textView.text length] <=0)
        {
            self.docEducationPlaceHolder.hidden=NO;
        }
    }
    else if (textView == self.docDesignation)
    {
        if ([textView.text length] <=0)
        {
            self.docDesignationPlaceHolder.hidden=NO;
        }
    }
    else if (textView == self.docExpertise)
    {
        if ([textView.text length] <=0)
        {
            self.docExpertisePlaceHolder.hidden=NO;
        }
    }
//    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height-400)];
}
- (void)textViewDidChange:(UITextView *)textView {
    
    if (textView == self.docEducation)
    {
        if ([textView.text length] <=0)
        {
            self.docEducationPlaceHolder.hidden = NO;
        }
        else
        {
            self.docEducationPlaceHolder.hidden = YES;
        }
    }
    else if (textView == self.docDesignation)
    {
        if ([textView.text length] <=0)
        {
            self.docDesignationPlaceHolder.hidden = NO;
        }
        else
        {
            self.docDesignationPlaceHolder.hidden = YES;
        }
    }
    else if (textView == self.docExpertise)
    {
        if ([textView.text length] <=0)
        {
            self.docExpertisePlaceHolder.hidden = NO;
        }
        else
        {
            self.docExpertisePlaceHolder.hidden = YES;
        }
    }
}
@end
