//
//  AddScheduleVC.m
//  smartRxDoctor
//
//  Created by Gowtham on 10/01/18.
//  Copyright © 2018 Anil Kumar. All rights reserved.
//

#import "AddScheduleVC.h"
#import "smartRxDashboardVC.h"
#import "ScheduleDatesResponseModel.h"
#import "LocationsModel.h"
#import "ResponseParser.h"
#import "SmartRxAddLocationsVC.h"

@interface AddScheduleVC ()
{
    MBProgressHUD *HUD;
    CGSize viewSize;
    NSInteger selectedIndex;
    LocationsModel *selectedLocation;
    ScheduleDatesResponseModel *selectedSchedule;
    NSString *locationId;
    NSDate *dateFromUnixStamp;
    NSDate *currentDate;
    NSDateComponents *currentComponent;
    NSDateComponents *componentsOfDate;
    NSMutableArray *componentsArray;
    NSInteger practiceIndex;
    NSString *status;
    NSString *selectedDate;
    BOOL isMoved;
    BOOL isScheduledDate;
}
@property(nonatomic,strong) NSArray *locationsArr;
@property(nonatomic,strong) NSArray *scheduledDates;
@property(nonatomic,strong) NSArray *blockedDates;
@end

@implementation AddScheduleVC
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


- (void)viewDidLoad {
    [super viewDidLoad];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"My Schedule" controler:self];
    self.addPracticeView.hidden = YES;
    selectedIndex =0;
    [self navigationBackButton];
    self.detailSubView.hidden = YES;
    //[self initCalendar];
    //[self showOrHideCalendar:nil];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT+05:30"];
    //[self.dateFormatter setTimeZone:gmt];

    //GMT+05:30
    [self.dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    viewSize=[[UIScreen mainScreen]bounds].size;
    [self initializePickers];
    
    [self initCalendar];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self makeRequestForLocations];

}
-(void)viewDidLayoutSubviews{
    self.scrollView.contentSize = CGSizeMake(0, self.detailSubView.frame.size.height+self.detailSubView.frame.origin.y+200);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)initializePickers
{
    _actionSheet = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    _actionSheet.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = _actionSheet.bounds;
    [_actionSheet addSubview:backgroundView];
    
    self.locationPicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.locationPicker.delegate = self;
    self.locationPicker.dataSource = self;
    self.locationPicker.backgroundColor = [UIColor whiteColor];
    
    
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
    // self.calendarContainer.hidden = YES;
    // self.calendar.hidden = YES;
    
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
    
    [componentsArray addObject:componentsOfDate];
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
    
    [_actionSheet addSubview:self.locationPicker];
    [self.locationPicker reloadAllComponents];
    [self.locationPicker selectRow:selectedIndex inComponent:0 animated:NO];  //TO-DO
    
    [self.view addSubview:_actionSheet];
    [self.view bringSubviewToFront:_actionSheet];
    _actionSheet.hidden = NO;
    
    
}

#pragma mark Action Methods
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
-(IBAction)clickOnAddLocationBtn:(id)sender{
    [self performSegueWithIdentifier:@"addLocationController" sender:nil];
    
}
-(void)cancelButtonPressed:(id)sender
{
    _actionSheet.hidden = YES;
}
-(void)doneButtonPressed:(id)sender
{
    selectedLocation = [self.locationsArr objectAtIndex:[self.locationPicker selectedRowInComponent:0]];
    selectedIndex = [self.locationPicker selectedRowInComponent:0];
    self.practiceLbl.text = selectedLocation.type;
    locationId = selectedLocation.locationId;
    self.scheduledDates = nil;
    self.blockedDates = nil;
    self.detailSubView.hidden = YES;
    
    [self makeRequestForDates];
    _actionSheet.hidden = YES;
    
}

-(IBAction)clickOnPracticeBtn:(id)sender{
    if (self.locationsArr.count ) {
        [self showPicker];
    }
}
-(IBAction)clickOnAvailableBtn:(id)sender{
    status = @"1";
    self.availableImageVw.image = [UIImage imageNamed:@"form-radio-checked"];
    self.notAvailableImageVw.image = [UIImage imageNamed:@"form-radio-unchecked"];
    
}
-(IBAction)clickOnNotAvailableBtn:(id)sender{
    status = @"0";
    
    self.availableImageVw.image = [UIImage imageNamed:@"form-radio-unchecked"];
    self.notAvailableImageVw.image = [UIImage imageNamed:@"form-radio-checked"];
}
-(IBAction)clickOnOkBtn:(id)sender{
    if (isScheduledDate) {
        if ([status isEqualToString:@"0"]) {
            self.detailSubView.hidden = YES;
            
            [self makerequestForBlockSchedule];
            
        } else {
            [self customAlertView:@"" Message:@"Please change the availability and then click ok." tag:1];
        }
    }else {
        if ([status isEqualToString:@"1"]) {
            self.detailSubView.hidden = YES;
            
            [self makerequestForBlockSchedule];
            
        }else {
            [self customAlertView:@"" Message:@"Please change the availability and then click ok." tag:1];
        }
    }
}
-(IBAction)clickOnCancelBtn:(id)sender{
    self.detailSubView.hidden = YES;
    
    // [self backBtnClicked:nil];
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
    //    if ([self.selectedDates count])
    //    {
    //        for (NSDate *enableDate in self.selectedDates) {
    //            if ([enableDate isEqualToDate:date]) {
    //                return YES;
    //            }
    //        }
    //    }
    
    if (self.scheduledDates.count) {
        for (ScheduleDatesResponseModel *model in self.scheduledDates) {
            if ([model.date isEqualToDate:date]) {
                selectedSchedule = model;
                return YES;
            }
        }
    }
    return NO;
    
}
-(BOOL)dateIsBlock:(NSDate *)date{
    if (self.blockedDates.count) {
        for (NSDate *blockedDate in self.blockedDates) {
            if ([blockedDate isEqualToDate:date]) {
                return YES;
            }
        }
    }
    return NO;
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
    if ([self dateIsBlock:date])
    {
        //        dateItem.backgroundColor = [UIColor blackColor];
        //        dateItem.textColor = [UIColor whiteColor];
        dateItem.backGroundImg = [UIImage imageNamed:@"red_dot"];
    }
}
- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    //self.dateLbl.text = [self.dateFormatter stringFromDate:date];
    //[econsultDetailsArr removeAllObjects];
    //[self.econsultDetails removeAllObjects];
    //[self makeRequestForSlots];
    if ([self dateIsApt:date] || [self dateIsBlock:date])
    {
        BOOL isSchedule = [self dateIsApt:date];
        if (isSchedule) {
            isScheduledDate = YES;
            
            if (isMoved) {
                [self movingTimingSubView:YES];
            }
            status = @"1";
            self.availableImageVw.image = [UIImage imageNamed:@"form-radio-checked"];
            self.notAvailableImageVw.image = [UIImage imageNamed:@"form-radio-unchecked"];
            
            if (![selectedSchedule.morningTime isEqualToString:@""]) {
                self.morningTimings.text = selectedSchedule.morningTime;
            }
            if (![selectedSchedule.afternoonTime isEqualToString:@""]) {
                self.afternoonTimings.text = selectedSchedule.afternoonTime;
            }
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            selectedDate = [formatter stringFromDate:selectedSchedule.date];
        }
        BOOL isBlocked = [self dateIsBlock:date];
        if (isBlocked) {
            isScheduledDate = NO;
            
            if (!isMoved) {
                [self movingTimingSubView:NO];
            }
            status = @"0";
            self.notAvailableImageVw.image = [UIImage imageNamed:@"form-radio-checked"];
            self.availableImageVw.image = [UIImage imageNamed:@"form-radio-unchecked"];
            self.morningTimings.text = @"";
            self.afternoonTimings.text = @"";
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            selectedDate = [formatter stringFromDate:date];
        }
        self.detailSubView.hidden = NO;
        NSCalendar *dateCalendar = [NSCalendar currentCalendar];
        NSInteger day = [dateCalendar component:NSCalendarUnitWeekday fromDate:date];
        NSString *dayStr = [ResponseParser getDayFromNumber:[NSString stringWithFormat:@"%d",day]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"MMM dd"];
        NSString *dateStr = [formatter stringFromDate:date];
        
        NSString *originalDate = [NSString stringWithFormat:@"%@(%@)",dateStr,dayStr];
        NSLog(@"hyigr:%@",originalDate);
        self.dateLbl.text = originalDate;
        
        // NSLog(@"%@",[self.appointmentDetails objectAtIndex:[self.selectedDates indexOfObject:date]]);
        //        [self.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        //         {
        //             if ([obj isEqualToDate:date])
        //             {
        //                 NSDictionary *tempDict = [self.appointmentDetails objectAtIndex:idx];
        //                 [econsultDetailsArr addObject:tempDict];
        //             }
        //         }];
        //        self.econsultDetails = econsultDetailsArr;
        // [self showOrHideCalendar:nil];
        //        [self performSegueWithIdentifier:@"econsultListVC" sender:econsultDetailsArr];
    } else {
        self.detailSubView.hidden = YES;
    }
    
}

- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    return [date laterDate:self.minimumDate] == date;
}
-(void)movingTimingSubView:(BOOL)upMoved{
    if (upMoved) {
        self.scheduleUpdateView.frame = CGRectMake(0, self.scheduleUpdateView.frame.origin.y+25, self.scheduleUpdateView.frame.size.width, self.scheduleUpdateView.frame.size.height);
        isMoved = NO;
    }else {
        self.scheduleUpdateView.frame = CGRectMake(0, self.scheduleUpdateView.frame.origin.y-25, self.scheduleUpdateView.frame.size.width, self.scheduleUpdateView.frame.size.height);
        isMoved = YES;
    }
    NSLog(@"frame :%@",self.scheduleUpdateView);
    NSLog(@"frame y axis:%f",self.scheduleUpdateView.frame.origin.y);
    
}
#pragma mark - Request Methods
-(void)makeRequestForLocations{
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
                 [self logOutId:nil];
                 
             }
             else{
                 dispatch_async(dispatch_get_main_queue(),^{
                     [HUD hide:YES];
                     [HUD removeFromSuperview];
                     NSLog(@"locations list :%@",response);
                     self.locationsArr = response[@"mylocations"];
                     NSArray *locations = [ResponseParser getLocation:response[@"mylocations"]];
                     self.locationsArr = locations;
                     if (locations.count) {
                         self.addPracticeView.hidden = YES;
                         selectedLocation = locations[0];
                         self.practiceLbl.text = selectedLocation.type;
                         locationId = selectedLocation.locationId;
                         
                         [self makeRequestForDates];
                     } else {
                         self.addPracticeView.hidden = NO;
                     }
                     //NSLog(@"booking list:%@",_bookingList);
                 });
                 
                 
             }}}failureHandler:^(id response) {
                 NSLog(@"failure %@",response);
                 [HUD hide:YES];
                 [HUD removeFromSuperview];
             }];
    
}
- (void)makeRequestForDates
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    //[self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *doctorId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText;
    bodyText = [NSString stringWithFormat:@"%@=%@&location=%@&isopen=1&cid=%@&sch_type=1&docid=%@&type=2&",@"sessionid",sectionId,locationId,strCid,doctorId];
    
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"mecondt"];
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
            //[smartLogin makeLoginRequest];
            [self logOutId:nil];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *type = NSStringFromClass([[response objectForKey:@"econdates"] class]);
                if(![type isEqualToString:@"__NSCFNumber"])
                {
                    NSMutableArray *sample = [[NSMutableArray alloc]initWithArray:[response objectForKey:@"econdates"]];
                    NSMutableArray *blockDates = [[NSMutableArray alloc]initWithArray:[response objectForKey:@"block_dates"]];
                    
                    self.calendarContainer.hidden = NO;
                    [self.view bringSubviewToFront:self.calendarContainer];
                    self.scheduledDates = [ResponseParser getScheduleDatesList:response[@"timings"]];
                    
                    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
                    for (int i=0;i<[blockDates count];i++)
                    {
                        double timeStamp = [blockDates[i] doubleValue];
                        NSTimeInterval timeInterval=timeStamp/1000;
                        NSDate * myDate = [NSDate dateWithTimeIntervalSince1970:[blockDates[i] doubleValue]];
                        NSDate *date = myDate;
                        NSDate *today = [NSDate date];
                        NSComparisonResult result = [today compare:myDate];
                        if (result == NSOrderedAscending || result == NSOrderedSame) {
                            [tempArr addObject:[self.dateFormatter dateFromString:[self.dateFormatter stringFromDate:date]]];
                            
                        }
                        
                    }
                    self.blockedDates = [tempArr copy];
                    for (int i=0;i<[sample count];i++)
                    {
                        for (int j=0; j<[[sample objectAtIndex:i] count];j++)
                        {
                            [self getDateValues:[[[sample objectAtIndex:i] objectAtIndex:j] doubleValue]];
                            [self.selectedDates addObject:[self.dateFormatter dateFromString:[self.dateFormatter stringFromDate:dateFromUnixStamp]]];
                        }
                    }
                }
                
                [self.calendar reloadData];
                
            });
        }
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error loading dates please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}
-(void)makerequestForBlockSchedule{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:selectedSchedule.date];
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *doctorId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&doa=%@&locid=%@&status=%@",@"sessionid",sectionId,selectedDate,locationId,status];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dblock"];
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
                 [self logOutId:nil];
                 
             }
             else{
                 dispatch_async(dispatch_get_main_queue(),^{
                     [HUD hide:YES];
                     [HUD removeFromSuperview];
                     
                     if ([response[@"status"] integerValue]) {
                         [self makeRequestForDates];
                         [self customAlertView:@"" Message:@"Schedule updated successfully" tag:222];
                     }                 //NSLog(@"booking list:%@",_bookingList);
                 });
                 
                 
             }}}failureHandler:^(id response) {
                 NSLog(@"failure %@",response);
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
-(void)logOutId:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Session expired. Please Re-login" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.delegate = self;
    alert.tag = 111;
    [alert show];
}
#pragma mark - Custom AlertView
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
#pragma mark - Alertview Delegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 987){
        [self backBtnClicked:nil];
    }else if (alertView.tag == 111){
        //[self moveToLogin];
    }
    
}
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    
    return self.locationsArr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    LocationsModel *model = self.locationsArr[row];
    return model.type;
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addLocationController"]) {
        SmartRxAddLocationsVC *controller = segue.destinationViewController;
        controller.fromControler = @"scheduleVc";
        controller.titleStr = @"Add Address";

    }
}


@end
