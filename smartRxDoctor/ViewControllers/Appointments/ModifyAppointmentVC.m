//
//  ModifyAppointmentVC.m
//  smartRxDoctor
//
//  Created by Gowtham on 05/01/18.
//  Copyright © 2018 Anil Kumar. All rights reserved.
//

#import "ModifyAppointmentVC.h"
#import "smartRxDashboardVC.h"
#import "ResponseParser.h"
#import "SmartRxAddLocationsVC.h"

@interface ModifyAppointmentVC ()
{
    MBProgressHUD *HUD;
    CGSize viewSize;
    NSMutableArray *slotArr, *methodArr, *statusArr;
    NSInteger statusIndex, timeIndex, methodIndex;
    NSString *locationStr;
    NSDate *dateFromUnixStamp;
    NSDateComponents *currentComponent;
    NSDateComponents *componentsOfDate;
    NSMutableArray *componentsArray;
    NSMutableArray *econsultDetailsArr;
    NSInteger selectedTimeRow;

}
@property(nonatomic,strong)NSArray *locationsArr;
@property(nonatomic,strong) NSArray *blockedDates;

@end

@implementation ModifyAppointmentVC
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
    self.locationeBtn.hidden = YES;
    self.reasonView.hidden = YES;
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [format dateFromString:self.dictResponse[@"appdate"]];
    [format setDateFormat:@"dd-MM-yyyy"];
    self.dateLbl.text = [format stringFromDate:date];
    
    self.locationView.backgroundColor=[UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:0.5];
    [self.locationView.layer setCornerRadius:5.0f];
    [self.locationView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.locationView.layer setBorderWidth:0.2f];
    [self.locationView.layer setShadowColor:[UIColor colorWithRed:225.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0].CGColor];
    [self.locationView.layer setShadowOpacity:1.0];
    [self.locationView.layer setShadowRadius:5.0];
    [self.locationView.layer setShadowOffset:CGSizeMake(5.0f, 5.0f)];
    
    //self.dateLbl.text = self.dictResponse[@"appdate"];
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    selectedTimeRow = 0;
    //    self.reasonTxtView.text = @"Reason for cancellation";
    //    self.reasonTxtView.textColor = [UIColor lightGrayColor];
    self.reasonTxtView.inputAccessoryView = doneToolbar;
    self.locationView.hidden = YES;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.selectedDates = [[NSMutableArray alloc] init];
    viewSize=[[UIScreen mainScreen]bounds].size;
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *tempDate = [self.dateFormatter dateFromString:[self.dictResponse objectForKey:@"appdate"]];
    [self.dateFormatter setDateFormat:@"dd-MM-yyyy"];
    //self.dateLbl.text = [self.dateFormatter stringFromDate:tempDate];
    NSString *strDatTime=[NSString stringWithFormat:@"%@ %@",[self.dictResponse objectForKey:@"appdate"],[self.dictResponse objectForKey:@"apptime"]];
    //self.timeLbl.text=[NSString timeFormating:strDatTime funcName:@"appointment"];
    
    NSDateFormatter *dateFormat =  [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    NSDate *timeDate =[dateFormat dateFromString:self.dictResponse[@"apptime"]];
    [dateFormat setDateFormat:@"hh:mm a"];
    self.timeLbl.text = [dateFormat stringFromDate:timeDate];
    
    if (self.selectedLocation !=nil){
        self.locationTF.text = [NSString stringWithFormat: @"%@-%@",self.selectedLocation.type,self.selectedLocation.cityName];
        locationStr = self.selectedLocation.locationId;
    }
    statusArr = [[NSMutableArray alloc] initWithArray:@[@"Pending", @"Confirmed", @"Completed", @"Cancel"]];
    _actionSheet = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    _actionSheet.hidden = YES;
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
    // [self createBorderForAllBoxes];
    [self initializePickers];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"Modify Appointment" controler:self];
    

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self makeeRequestForLocations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (void)initializePickers
{
    self.timePicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.timePicker.delegate = self;
    self.timePicker.dataSource = self;
    self.timePicker.backgroundColor = [UIColor whiteColor];
    
    self.eConsultStatusPicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.eConsultStatusPicker.delegate = self;
    self.eConsultStatusPicker.dataSource = self;
    self.eConsultStatusPicker.backgroundColor = [UIColor whiteColor];
    
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
-(IBAction)clickOnLocationBtn:(id)sender{
    if (self.locationsArr.count) {
        self.locationView.hidden = NO;
        
    }else {
        [self performSegueWithIdentifier:@"addLocationView" sender:nil];
    }
    
}
-(IBAction)clickOnDateBtn:(id)sender{
    [self showOrHideCalendar:nil];
    
}
-(IBAction)clickOnTimeBtn:(id)sender{
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
-(IBAction)clickOnStatusBtn:(id)sender{
    self.currentButton = self.statusBtn;
    self.currentButton.tag = 3;
    [self showPicker];
}
-(void)cancelButtonPressed:(id)sender
{
    _actionSheet.hidden = YES;
}
-(void)doneButtonPressed:(id)sender
{
    
    if (self.currentButton == self.timeButton)
    {
        self.timeLbl.text = [slotArr objectAtIndex:[self.timePicker selectedRowInComponent:0]];
        timeIndex = [self.timePicker selectedRowInComponent:0];
        self.timeLbl.textColor = [UIColor blackColor];
    }
    else if (self.currentButton == self.statusBtn)
    {
        self.statusLbl.text = [statusArr objectAtIndex:[self.eConsultStatusPicker selectedRowInComponent:0]];
        statusIndex = [self.eConsultStatusPicker selectedRowInComponent:0];
        self.statusLbl.textColor = [UIColor blackColor];
        if ([[statusArr objectAtIndex:[self.eConsultStatusPicker selectedRowInComponent:0]] isEqualToString:@"Cancel"])
        {
            self.reasonView.hidden = NO;
            self.reasonTxtView.hidden = NO;
            self.reasonPlaceHolder.hidden = NO;
            self.updateButton.frame = CGRectMake(self.updateButton.frame.origin.x, self.reasonTxtView.frame.origin.y+self.reasonTxtView.frame.size.height+15, self.updateButton.frame.size.width, self.updateButton.frame.size.height);
            self.backButton.frame = CGRectMake(self.backButton.frame.origin.x, self.reasonTxtView.frame.origin.y+self.reasonTxtView.frame.size.height+15, self.backButton.frame.size.width, self.backButton.frame.size.height);
        }
        else
        {
            self.reasonView.hidden = YES;
            self.reasonTxtView.hidden = YES;
            self.reasonPlaceHolder.hidden = YES;
            self.updateButton.frame = CGRectMake(self.updateButton.frame.origin.x, self.statusBtn.frame.origin.y+self.statusBtn.frame.size.height+20, self.updateButton.frame.size.width, self.updateButton.frame.size.height);
            self.backButton.frame = CGRectMake(self.backButton.frame.origin.x, self.statusBtn.frame.origin.y+self.statusBtn.frame.size.height+20, self.backButton.frame.size.width, self.backButton.frame.size.height);
        }
    }
    _actionSheet.hidden = YES;
    
}
- (void)doneButton:(id)sender
{
    [self.reasonTxtView resignFirstResponder];
}
-(IBAction)clickOnAddLocationBtn:(id)sender{
    [self performSegueWithIdentifier:@"addLocationView" sender:nil];
}
-(IBAction)clickOnUpdateButton:(id)sender{
    
    if ([self.dateLbl.text isEqualToString:@"Selecte date"]) {
        [self customAlertView:@"Request you to enter date" Message:@"" tag:0];
    } else {
        [self makeRequestForUpadteAppointment];
        
    }
}
-(IBAction)clickOnBackButton:(id)sender{
    [self backBtnClicked:nil];
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
    
    [componentsArray addObject:componentsOfDate];
}
#pragma mark - CKCalendarDelegate
- (void)calendar:(CKCalendarView *)calendar configureDateItem:(CKDateItem *)dateItem forDate:(NSDate *)date {
    // TODO: play with the coloring if we want to...
    if ([self dateIsApt:date] && ![self dateIsBlock:date])
    {
        //        dateItem.backgroundColor = [UIColor blackColor];
        //        dateItem.textColor = [UIColor whiteColor];
        dateItem.backGroundImg = [UIImage imageNamed:@"dayMarked.png"];
    }
}
- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    self.dateLbl.text = [self.dateFormatter stringFromDate:date];
    self.dateLbl.textColor = [UIColor blackColor];
    [econsultDetailsArr removeAllObjects];
    [self.econsultDetails removeAllObjects];
    if ([self dateIsApt:date] && ![self dateIsBlock:date])
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
        self.timeLbl.text = @"No time slots available";
        [self makeRequestForSlots];
        
        //        [self performSegueWithIdentifier:@"econsultListVC" sender:econsultDetailsArr];
    }
    
}

- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    return [date laterDate:self.minimumDate] == date;
}


#pragma mark - Request Methods

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
                 [smartLogin makeLoginRequest];
                 
             }
             else{
                 dispatch_async(dispatch_get_main_queue(),^{
                     [HUD hide:YES];
                     [HUD removeFromSuperview];
                     NSLog(@"locations list :%@",response);
                    self.locationsArr  = [ResponseParser getLocation:response[@"mylocations"]];
                     if (self.locationsArr.count) {
                         self.locationeBtn.hidden = YES;
                         
                         if (self.selectedLocation ==nil){
                             
                             self.selectedLocation = self.locationsArr[0];
                             self.locationTF.text = self.selectedLocation.cityName;
                             locationStr= self.selectedLocation.locationId;
                         }
                     }else {
                         self.locationeBtn.hidden = NO;
                     }
                     [self.tableView reloadData];
                     [self makeRequestForSlots];
                     [self makeRequestForDates];
                     //self.locationsArr = locations;
                    
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
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *doctorId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    
    NSString *bodyText;
    NSString *schType = @"1";
    if (self.scheduleType != nil) {
        schType = @"3";
    }

    bodyText = [NSString stringWithFormat:@"%@=%@&sch_type=%@&docid=%@&type=2&isopen=1&cid=%@&location=%@",@"sessionid",sectionId,schType,doctorId,strCid,locationStr];
   
    if (self.scheduleType != nil) {
        NSLog(@"scheduleType");
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&sc_type=1&locid=%@",locationStr]];
    }
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
            //[self logOutId:nil];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *type = NSStringFromClass([[response objectForKey:@"econdates"] class]);
                if(![type isEqualToString:@"__NSCFNumber"])
                {
                    NSMutableArray *sample = [[NSMutableArray alloc]initWithArray:[response objectForKey:@"econdates"]];
                    self.calendarContainer.hidden = NO;
                    [self.view bringSubviewToFront:self.calendarContainer];
                    NSMutableArray *blockDates = [[NSMutableArray alloc]initWithArray:[response objectForKey:@"block_dates"]];
                    
                    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
                    for (int i=0;i<[blockDates count];i++)
                    {
                        
                        NSDate * myDate = [NSDate dateWithTimeIntervalSince1970:[blockDates[i] doubleValue]];
                        NSDate *date = myDate;
                        
                        [tempArr addObject:[self.dateFormatter dateFromString:[self.dateFormatter stringFromDate:date]]];
                        
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
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    
    NSString *bodyText;
    NSString *schType = @"1";
    if (self.scheduleType != nil) {
        schType = @"3";
    }

    bodyText = [NSString stringWithFormat:@"%@=%@&type=%d&doa=%@&docid=%@&cid=%@&location=%@&sch_type=%@&isopen=1",@"sessionid",sectionId, 2, self.dateLbl.text,[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"],strCid,locationStr,schType];
    if (self.scheduleType != nil) {
        NSLog(@"scheduleType");
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&sc_type=1&locid=%@",locationStr]];
    }
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"meconslot"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        NSLog(@"sucess 1 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            //[smartLogin makeLoginRequest];
            //[self logOutId:nil];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                slotArr = [[NSMutableArray alloc]init];
                if ([response[@"slots"] isKindOfClass:[NSArray class]]) {
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
                }else {
                   NSDictionary *slotsdict = [response objectForKey:@"slots"];
                    if ([slotsdict count])
                    {
                        
                        if ([slotArr count])
                        {
                            [slotArr removeAllObjects];
                        }
                        NSMutableArray *arrToSort = [[NSMutableArray alloc] initWithArray:[slotsdict allKeys]];
                        
                        
                        NSArray *sortedArray = [arrToSort sortedArrayUsingComparator:^(id obj1, id obj2) {
                            NSNumber *num1 = [NSNumber numberWithInt:[obj1 intValue]];
                            NSNumber *num2 = [NSNumber numberWithInt:[obj2 intValue]];
                            return (NSComparisonResult)[num1 compare:num2];
                            NSLog(@"(NSComparisonResult)[num1 compare:num2] %ld",(long)[num1 compare:num2]);
                            
                        }];
                        
                        for (int i=0; i<[sortedArray count]; i++)
                        {
                            
                            
                            if ([slotsdict objectForKey:[NSString stringWithFormat:@"%@",[sortedArray objectAtIndex:i]]])
                            {
                                [slotArr addObject:[slotsdict objectForKey:[NSString stringWithFormat:@"%@",[sortedArray objectAtIndex:i]]]];
                            }
                            
                        }
                        self.timeLbl.text=[slotArr objectAtIndex:0];


                    }else {
                        {
                            self.timeLbl.text = @"No time slots available";
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"No time slots available please select another date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        }
                    }
                    
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
-(void)makeRequestForUpadteAppointment{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSDate *tempDate = [self.dateFormatter dateFromString:self.dateLbl.text];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [self.dateFormatter stringFromDate:tempDate];
    NSString *bodyText;
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dupappt"];
    if (self.scheduleType != nil) {
        NSLog(@"scheduleType");
        url = [NSString stringWithFormat:@"%@%@",WB_BASEURL,@"daddecon"];
        bodyText = [NSString stringWithFormat:@"%@=%@&type=%d&econ_date=%@&econ_doctor=%@&patid=%@&econ_id=%@&econ_specialty=%@&econ_time=%@&econ_method=0&econ_cancel_reason=%@&econ_type=3&econ_status=%d",@"sessionid",sectionId, 2, [self.dateFormatter stringFromDate:tempDate],[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"], [self.dictResponse objectForKey:@"patientid"], [self.dictResponse objectForKey:@"conid"], [self.dictResponse objectForKey:@"specality"], self.timeLbl.text, self.reasonTxtView.text,statusIndex+1];

    }else{
    bodyText = [NSString stringWithFormat:@"%@=%@&appid=%@&patid=%@&member_location_id=%@&apt_date=%@&apt_time=%@&status=%d&apt_cancel_reason=%@",@"sessionid",sectionId,[self.dictResponse objectForKey:@"conid"],[self.dictResponse objectForKey:@"patientid"],locationStr,dateStr,self.timeLbl.text,statusIndex+1,self.reasonTxtView.text];
    }
    NSLog(@"body text.....:%@",bodyText);
    NSLog(@"url.....:%@",url);

    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        NSLog(@"sucess 1 %@",response);
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSArray *arr = [NSArray arrayWithObjects:response, nil];
            response = arr;
        }
        if ([[response[0] objectForKey:@"authorized"]integerValue] == 0 && [[response[0] objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            //[smartLogin makeLoginRequest];
            
        } else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([response[0][@"response_msg"] isKindOfClass:[NSString class]]) {
                    
                    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"fromModify"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[response[0] objectForKey:@"response_msg"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.tag = 987;
                    alert.delegate = self;
                    [alert show];
                }else {
                    [self customAlertView:@"" Message:@"Could not modify appointment status.Please try again later" tag:0];
                }
            });
        }
        
        
        
    }failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error loading dates please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
#pragma mark - TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.locationsArr.count+1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell;
    
    if (indexPath.row < self.locationsArr.count) {
        cell= [tableView dequeueReusableCellWithIdentifier:@"cell"];
        LocationsModel *model = self.locationsArr[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@-%@",model.type,model.cityName];
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell"];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.locationView.hidden = YES;
    if (indexPath.row < self.locationsArr.count) {
        self.selectedLocation = self.locationsArr[indexPath.row];
        self.locationTF.text = [NSString stringWithFormat:@"%@-%@", self.selectedLocation.type, self.selectedLocation.cityName];
        locationStr =self.selectedLocation.locationId;
        [self makeRequestForDates];
        [self makeRequestForSlots];
        
    } else {
        [self performSegueWithIdentifier:@"addLocationView" sender:nil];
    }
    
}

#pragma mark - Custom AlertView
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    alertView.delegate = self;
    [alertView show];
    alertView=nil;
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
    if (self.currentButton == self.timeButton)
    {
        NSLog(@"slot arr count %d", [slotArr count]);
        return [slotArr count];
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
    
    else if (self.currentButton==self.statusBtn)
    {
        //statusIndex = row;
        return [statusArr objectAtIndex:row];
    }
    return [NSString stringWithFormat:@"Hey Row %ld", (long)self.currentButton.tag];
}





#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addLocationView"]) {
        SmartRxAddLocationsVC *controller = segue.destinationViewController;
        controller.fromControler = @"scheduleVc";
        controller.titleStr = @"Add Address";
        
    }
}


@end
