//
//  SmartRxeConsultModify.m
//  smartRxDoctor
//
//  Created by Manju Basha on 01/09/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "SmartRxeConsultModify.h"
#import "NSString+DateConvertion.h"
#import "smartRxDashboardVC.h"
#import "smartRxEconsultVC.h"

@interface SmartRxeConsultModify ()
{
    MBProgressHUD *HUD;
    NSInteger statusIndex, timeIndex, methodIndex;
    CGSize viewSize;
    NSMutableArray *econsultDetailsArr;
    NSDateComponents *componentsOfDate;
    NSDate *dateFromUnixStamp;
    NSDate *currentDate;
    NSDateComponents *currentComponent;
    NSMutableArray *componentsArray;
    NSMutableArray *slotArr, *methodArr, *statusArr;
}
@end

@implementation SmartRxeConsultModify

- (void)viewDidLoad {
    [super viewDidLoad];
    statusIndex = 0;
    timeIndex = 0;
    methodIndex = 0;
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
//    self.reasonTxtView.text = @"Reason for cancellation";
//    self.reasonTxtView.textColor = [UIColor lightGrayColor];
    self.reasonTxtView.inputAccessoryView = doneToolbar;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.selectedDates = [[NSMutableArray alloc] init];
    viewSize=[[UIScreen mainScreen]bounds].size;
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *tempDate = [self.dateFormatter dateFromString:[self.dictResponse objectForKey:@"appdate"]];
    [self.dateFormatter setDateFormat:@"dd-MM-yyyy"];
    self.dateLbl.text = [self.dateFormatter stringFromDate:tempDate];
    NSString *strDatTime=[NSString stringWithFormat:@"%@ %@",[self.dictResponse objectForKey:@"appdate"],[self.dictResponse objectForKey:@"apptime"]];
   // self.timeLbl.text=[NSString timeFormating:strDatTime funcName:@"appointment"];
    NSDateFormatter *dateFormat =  [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    NSDate *date =[dateFormat dateFromString:self.dictResponse[@"apptime"]];
    [dateFormat setDateFormat:@"hh:mm a"];
    self.timeLbl.text = [dateFormat stringFromDate:date];
    
    methodArr = [[NSMutableArray alloc] initWithArray:@[@"Video Conference", @"Phone Call"]];
    statusArr = [[NSMutableArray alloc] initWithArray:@[@"Pending", @"Confirmed", @"Completed", @"Cancel"]];
    _actionSheet = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    _actionSheet.hidden = YES;
    [self makeRequestForSlots];
    if ([[self.dictResponse objectForKey:@"status"] integerValue] == 1)
    {
        self.statusLbl.text = @"Pending";
        statusIndex = 0;
    }
    else if ([[self.dictResponse objectForKey:@"status"] integerValue] == 2)
    {
        self.statusLbl.text = @"Confirmed";
        statusIndex = 1;
    }
    else if ([[self.dictResponse objectForKey:@"status"] integerValue] == 3)
    {
        self.statusLbl.text = @"Completed";
        statusIndex = 2;
    }
    else if ([[self.dictResponse objectForKey:@"status"] integerValue] == 4)
    {
        self.statusLbl.text = @"Cancelled";
        statusIndex = 3;
    }
    
    if ([[self.dictResponse objectForKey:@"app_method"] integerValue] == 1)
    {
        self.eConsultMethodLbl.text = @"Video Conference";
        methodIndex = 0;
    }
    else
    {
        self.eConsultMethodLbl.text = @"Phone Call";
        methodIndex = 1;
    }
    
        
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = _actionSheet.bounds;
    [_actionSheet addSubview:backgroundView];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = _actionSheet.bounds;
    [self.calendarContainer addSubview:background];
    [self.calendarContainer sendSubviewToBack:background];
    
    [self navigationBackButton];
    [self createBorderForAllBoxes];
    [self initializePickers];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];
    [self makeRequestForDates];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addSpinnerView
{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
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

- (void)showPicker
{
    _pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewSize.height-260, 320, 44)];
    _pickerToolbar.barStyle = UIBarStyleBlackTranslucent; //UIBarStyleBlackOpaque;
    [_pickerToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    [barItems addObject:cancelBtn];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    flexSpace.width = 200.0f;
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    [barItems addObject:doneBtn];
    
    
    [_pickerToolbar setItems:barItems animated:YES];
    
    [_actionSheet addSubview:_pickerToolbar];
    
    if (self.currentButton == self.timeButton)
    {
        [_actionSheet addSubview:self.timePicker];
        [self.timePicker reloadAllComponents];
        [self.timePicker selectRow:timeIndex inComponent:0 animated:NO];  //TO-DO
    }
    else if (self.currentButton == self.eConsultMethodBtn)
    {
        [_actionSheet addSubview:self.eConsultMethodPicker];
        [self.eConsultMethodPicker reloadAllComponents];
        [self.eConsultMethodPicker selectRow:methodIndex inComponent:0 animated:NO];  //TO-DO
    }
    else if (self.currentButton==self.statusBtn)
    {
        [_actionSheet addSubview:self.eConsultStatusPicker];
        [self.eConsultStatusPicker reloadAllComponents];
        [self.eConsultStatusPicker selectRow:statusIndex inComponent:0 animated:NO];  //TO-DO
    }
    
    [self.view addSubview:_actionSheet];
    [self.view bringSubviewToFront:_actionSheet];
    _actionSheet.hidden = NO;
    
    
}

#pragma mark Action Methods
- (IBAction)updateBtnClicked:(id)sender
{
    if([self.timeLbl.text isEqualToString: @"No time slots available"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Select available time and re-try" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ((statusIndex+1 == 4)&&(![self.reasonTxtView.text length] || self.reasonTxtView.text == nil))
    {
        
        if (![self.reasonTxtView.text length] || self.reasonTxtView.text == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Request you to enter reason for cancelling consultation" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        [self makeRequestToModify];
    }
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dateButtonClicked:(id)sender
{
    [self showOrHideCalendar:nil];
}

- (IBAction)timeButtonClicked:(id)sender
{
    if (![self.timeLbl.text isEqualToString: @"No time slots available"])
    {
        self.currentButton = self.timeButton;
        self.currentButton.tag = 1;
        if ([slotArr count])
            [self showPicker];
    }
    else
    {
        if([self.timeLbl.text isEqualToString: @"No time slots available"])
        {
            if ([self.dateLbl.text isEqualToString:@"Select a date"])
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please pick a date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"No time slots available please select another date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
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

-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)cancelButtonPressed:(id)sender
{
    _actionSheet.hidden = YES;
}
-(void)doneButtonPressed:(id)sender
{
    if (self.currentButton == self.eConsultMethodBtn)
    {
        self.eConsultMethodLbl.text = [methodArr objectAtIndex:[self.eConsultMethodPicker selectedRowInComponent:0]];
    }
    else if (self.currentButton == self.timeButton)
    {
        self.timeLbl.text = [slotArr objectAtIndex:[self.timePicker selectedRowInComponent:0]];
        timeIndex = [self.timePicker selectedRowInComponent:0];
        self.timeLbl.textColor = [UIColor blackColor];
    }
    else if (self.currentButton == self.statusBtn)
    {
        self.statusLbl.text = [statusArr objectAtIndex:[self.eConsultStatusPicker selectedRowInComponent:0]];
        self.statusLbl.textColor = [UIColor blackColor];
        if ([[statusArr objectAtIndex:[self.eConsultStatusPicker selectedRowInComponent:0]] isEqualToString:@"Cancel"])
        {
            self.reasonTxtView.hidden = NO;
            self.reasonPlaceHolder.hidden = NO;
            self.updateButton.frame = CGRectMake(self.updateButton.frame.origin.x, self.reasonTxtView.frame.origin.y+self.reasonTxtView.frame.size.height+30, self.updateButton.frame.size.width, self.updateButton.frame.size.height);
            self.backButton.frame = CGRectMake(self.backButton.frame.origin.x, self.reasonTxtView.frame.origin.y+self.reasonTxtView.frame.size.height+30, self.backButton.frame.size.width, self.backButton.frame.size.height);
        }
        else
        {
            self.reasonTxtView.hidden = YES;
            self.reasonPlaceHolder.hidden = YES;
            self.updateButton.frame = CGRectMake(self.updateButton.frame.origin.x, self.statusBtn.frame.origin.y+self.statusBtn.frame.size.height+30, self.updateButton.frame.size.width, self.updateButton.frame.size.height);
            self.backButton.frame = CGRectMake(self.backButton.frame.origin.x, self.statusBtn.frame.origin.y+self.statusBtn.frame.size.height+30, self.backButton.frame.size.width, self.backButton.frame.size.height);
        }
    }
    _actionSheet.hidden = YES;
    
}
- (IBAction)eConsultMethodBtnClicked:(id)sender
{
    self.currentButton = self.eConsultMethodBtn;
    self.currentButton.tag = 2;
    [self showPicker];
}

- (IBAction)statusBtnClicked:(id)sender
{
    self.currentButton = self.statusBtn;
    self.currentButton.tag = 3;
    [self showPicker];
}

- (void)doneButton:(id)sender
{
    [self.reasonTxtView resignFirstResponder];
}
#pragma mark - Alertview Delegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 987)
    {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"EConsultPush"];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"EConsultVideoPush"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self homeBtnClicked:nil];
//        for (UIViewController *controller in [self.navigationController viewControllers])
//        {
//            if ([controller isKindOfClass:[smartRxEconsultVC class]])
//            {
//                [self.navigationController popToViewController:controller animated:YES];
//            }
//        }
    }
}
#pragma mark - Calendar Methods
- (void)showOrHideCalendar:(id)sender
{
    if ([self.calendar isHidden])
    {
        self.calendar.hidden = NO;
        self.calendarContainer.hidden = NO;
    }
    else
    {
        
        self.calendar.hidden = YES;
        self.calendarContainer.hidden = YES;
    }
    
}
- (BOOL)dateIsApt:(NSDate *)date
{
    if ([self.selectedDates count])
    {
        for (NSDate *enableDate in self.selectedDates) {
            if ([enableDate isEqualToDate:date]) {
                return YES;
            }
        }
    }
    return NO;
    
}
- (void)initCalendar
{
    CKCalendarView *calendar = [[CKCalendarView alloc] initWithStartDay:startMonday];
    self.calendar = calendar;
    calendar.delegate = self;
    calendar.onlyShowCurrentMonth = NO;
    calendar.adaptHeightToNumberOfWeeksInMonth = YES;
    
    calendar.frame = CGRectMake(0, 0, 320, 320);
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.calendarContainer addSubview:calendar];
    self.calendarContainer.hidden = YES;
    self.calendar.hidden = YES;

    //    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(calendar.frame) + 4, self.view.bounds.size.width, 24)];
    [self.view addSubview:self.dateLabel];
    
}
- (void)getDateValues:(double)intVal
{
    NSDate * myDate = [NSDate dateWithTimeIntervalSince1970:intVal];
    dateFromUnixStamp = myDate;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    componentsOfDate    = [calendar components:(NSCalendarCalendarUnit |
                                                NSYearCalendarUnit     |
                                                NSMonthCalendarUnit    |
                                                NSDayCalendarUnit      |
                                                NSWeekdayCalendarUnit) fromDate:myDate];
    //    componentsOfDate    = [calendar components:(NSCalendarCalendarUnit |
    //                                                NSYearCalendarUnit     |
    //                                                NSMonthCalendarUnit    |
    //                                                NSDayCalendarUnit      |
    //                                                NSHourCalendarUnit     |
    //                                                NSMinuteCalendarUnit   |
    //                                                NSWeekdayCalendarUnit  |
    //                                                NSSecondCalendarUnit) fromDate:myDate];
    
    [componentsArray addObject:componentsOfDate];
}
#pragma mark - CKCalendarDelegate
- (void)calendar:(CKCalendarView *)calendar configureDateItem:(CKDateItem *)dateItem forDate:(NSDate *)date {
    // TODO: play with the coloring if we want to...
    if ([self dateIsApt:date])
    {
        //        dateItem.backgroundColor = [UIColor blackColor];
        //        dateItem.textColor = [UIColor whiteColor];
        dateItem.backGroundImg = [UIImage imageNamed:@"dayMarked.png"];
    }
}
- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    self.dateLbl.text = [self.dateFormatter stringFromDate:date];
    [econsultDetailsArr removeAllObjects];
    [self.econsultDetails removeAllObjects];
    self.timeLbl.text = @"No time slots available";
    [self makeRequestForSlots];
    if ([self dateIsApt:date])
    {
        NSLog(@"%@",[self.appointmentDetails objectAtIndex:[self.selectedDates indexOfObject:date]]);
        [self.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj isEqualToDate:date])
             {
                 NSDictionary *tempDict = [self.appointmentDetails objectAtIndex:idx];
                 [econsultDetailsArr addObject:tempDict];
             }
         }];
        self.econsultDetails = econsultDetailsArr;
        [self showOrHideCalendar:nil];
        //        [self performSegueWithIdentifier:@"econsultListVC" sender:econsultDetailsArr];
    }
    
}

- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    return [date laterDate:self.minimumDate] == date;
}
#pragma mark - Request method
- (void)makeRequestForDates
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText;
    bodyText = [NSString stringWithFormat:@"%@=%@&type=%d&docid=%@",@"sessionid",sectionId, 2,[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]];
    
    if (self.scheduleType != nil) {
        NSLog(@"scheduleType");
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&sch_type=3&sc_type=2&locid="]];
    }
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"decondt"];
    NSLog(@"Body text : %@", bodyText);
    NSLog(@"URL : %@", url);
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        NSLog(@"sucess 1 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *type = NSStringFromClass([[response objectForKey:@"econdates"] class]);
                if(![type isEqualToString:@"__NSCFNumber"])
                {
                    NSMutableArray *sample = [[NSMutableArray alloc]initWithArray:[response objectForKey:@"econdates"]];
                    self.calendarContainer.hidden = NO;
                    [self.view bringSubviewToFront:self.calendarContainer];
                    for (int i=0;i<[sample count];i++)
                    {
                        for (int j=0; j<[[sample objectAtIndex:i] count];j++)
                        {
                            [self getDateValues:[[[sample objectAtIndex:i] objectAtIndex:j] doubleValue]];
                            [self.selectedDates addObject:[self.dateFormatter dateFromString:[self.dateFormatter stringFromDate:dateFromUnixStamp]]];
                        }
                    }
                }
                [self initCalendar];

            });
        }
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error loading dates please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}

- (void)makeRequestForSlots
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText;
    bodyText = [NSString stringWithFormat:@"%@=%@&type=%d&doa=%@&docid=%@",@"sessionid",sectionId, 2, self.dateLbl.text,[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]];
    if (self.scheduleType != nil) {
        NSLog(@"scheduleType");
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&sch_type=3&sc_type=2&locid="]];
    }
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"deconslot"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        NSLog(@"sucess 1 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                slotArr = [[NSMutableArray alloc]init];
                slotArr = [response objectForKey:@"slots"];
                if ([slotArr count])
                {
                    for (int i=0; i<[slotArr count]; i++)
                    {
                        if ([self.timeLbl.text isEqualToString:[slotArr objectAtIndex:i]])
                            timeIndex = i;
                    }
                    if([self.timeLbl.text isEqualToString: @"No time slots available"]){
                        self.timeLbl.text = [[response objectForKey:@"slots"] objectAtIndex:0];
                    timeIndex = 0;
                    }
                    self.timeLbl.textColor = [UIColor blackColor];
                }
                else
                {
                    self.timeLbl.text = @"No time slots available";
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"No time slots available please select another date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            });
        }
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error loading dates please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}


- (void)makeRequestToModify
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText;
    NSDate *tempDate = [self.dateFormatter dateFromString:self.dateLbl.text];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if (statusIndex+1 == 4)
        bodyText = [NSString stringWithFormat:@"%@=%@&type=%d&econ_date=%@&econ_doctor=%@&patid=%@&econ_id=%@&econ_status=%d&econ_specialty=%@&econ_time=%@&econ_method=%d&econ_cancel_reason=%@",@"sessionid",sectionId, 2, [self.dateFormatter stringFromDate:tempDate],[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"], [self.dictResponse objectForKey:@"patientid"], [self.dictResponse objectForKey:@"conid"], statusIndex+1, [self.dictResponse objectForKey:@"specality"], self.timeLbl.text, methodIndex+1, self.reasonTxtView.text];
    else
        bodyText = [NSString stringWithFormat:@"%@=%@&type=%d&econ_date=%@&econ_doctor=%@&patid=%@&econ_id=%@&econ_status=%d&econ_specialty=%@&econ_time=%@&econ_method=%d&econ_cancel_reason=%@",@"sessionid",sectionId, 2, [self.dateFormatter stringFromDate:tempDate],[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"], [self.dictResponse objectForKey:@"patientid"], [self.dictResponse objectForKey:@"conid"], statusIndex+1, [self.dictResponse objectForKey:@"specality"], self.timeLbl.text, methodIndex+1, @""];
    
    if (self.scheduleType != nil) {
        NSString *econMethod = nil;
        NSLog(@"methodIndex.....:%ld",(long)methodIndex);
        if (methodIndex == 0) {
            econMethod = @"1";
        
        }else if (methodIndex == 1) {
            econMethod = @"2";

        }
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&econ_type=%@",econMethod]];
    }
    
    
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"daddecon"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        NSLog(@"sucess 1 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"fromModify"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [HUD hide:YES];
                [HUD removeFromSuperview];
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[response objectForKey:@"response_msg"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.tag = 987;
                alert.delegate = self;
                [alert show];
            });
        }
    } failureHandler:^(id response) {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error loading dates please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}

#pragma mark - Text field Delegates
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView == self.reasonTxtView)
    {
        self.reasonTxtView.text = @"";
        self.reasonTxtView.textColor = [UIColor blackColor];
    }
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.reasonPlaceHolder.hidden = YES;

    [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.frame=CGRectMake(self.scrollView.frame.origin.x,self.scrollView.frame.origin.y-2*self.reasonTxtView.frame.size.height, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        }];
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.frame=CGRectMake(self.scrollView.frame.origin.x,self.scrollView.frame.origin.y+2*self.reasonTxtView.frame.size.height, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        }];
        if ([self.reasonTxtView.text length])
            self.reasonPlaceHolder.hidden = YES;
        else
            self.reasonPlaceHolder.hidden = NO;
            
}

#pragma mark border & Initialization Methods
- (void)createBorderForAllBoxes
{
    self.dateButton.layer.cornerRadius=0.0f;
    self.dateButton.layer.masksToBounds = YES;
    self.dateButton.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.dateButton.layer.borderWidth= 1.0f;
    
    self.timeButton.layer.cornerRadius=0.0f;
    self.timeButton.layer.masksToBounds = YES;
    self.timeButton.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.timeButton.layer.borderWidth= 1.0f;
    
    
    self.eConsultMethodBtn.layer.cornerRadius=0.0f;
    self.eConsultMethodBtn.layer.masksToBounds = YES;
    self.eConsultMethodBtn.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.eConsultMethodBtn.layer.borderWidth= 1.0f;
 
    self.statusBtn.layer.cornerRadius=0.0f;
    self.statusBtn.layer.masksToBounds = YES;
    self.statusBtn.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.statusBtn.layer.borderWidth= 1.0f;

    self.reasonTxtView.layer.cornerRadius=0.0f;
    self.reasonTxtView.layer.masksToBounds = YES;
    self.reasonTxtView.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.reasonTxtView.layer.borderWidth= 1.0f;
    
}

- (void)initializePickers
{
    self.timePicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.timePicker.delegate = self;
    self.timePicker.dataSource = self;
    self.timePicker.backgroundColor = [UIColor whiteColor];
    
    self.eConsultMethodPicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.eConsultMethodPicker.delegate = self;
    self.eConsultMethodPicker.dataSource = self;
    self.eConsultMethodPicker.backgroundColor = [UIColor whiteColor];
    
    self.eConsultStatusPicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.eConsultStatusPicker.delegate = self;
    self.eConsultStatusPicker.dataSource = self;
    self.eConsultStatusPicker.backgroundColor = [UIColor whiteColor];
    
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if (self.currentButton == self.timeButton)
    {
        NSLog(@"slot arr count %d", [slotArr count]);
        return [slotArr count];
    }
    else if (self.currentButton == self.eConsultMethodBtn)
    {
        NSLog(@"method arr count %d", [methodArr count]);
        return [methodArr count];
    }
    else if (self.currentButton==self.statusBtn)
    {
        return [statusArr count];
    }
    
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (self.currentButton==self.timeButton)
    {
        timeIndex = row;
        return [slotArr objectAtIndex:row];
    }
    else if (self.currentButton==self.eConsultMethodBtn)
    {
        methodIndex = row;
        return [methodArr objectAtIndex:row];
    }
    else if (self.currentButton==self.statusBtn)
    {
        statusIndex = row;
        return [statusArr objectAtIndex:row];
    }
    return [NSString stringWithFormat:@"Hey Row %ld", (long)self.currentButton.tag];
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
