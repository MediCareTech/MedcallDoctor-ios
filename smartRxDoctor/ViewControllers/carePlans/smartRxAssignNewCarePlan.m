//
//  smartRxAssignNewCarePlan.m
//  smartRxDoctor
//
//  Created by Manju Basha on 11/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "smartRxAssignNewCarePlan.h"
#import "smartRxDashboardVC.h"
@interface smartRxAssignNewCarePlan ()
{
    CGSize viewSize;
    NSArray *serviceArr, *consultPackArr, *specArray, *carePlanArr, *selectedCareArray;
    NSMutableArray *arSelectedRows;
    NSString *serviceTypeId, *careid, *packId;
    MBProgressHUD *HUD;
    UIView *tblSecFrame;
}
@end

@implementation smartRxAssignNewCarePlan

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDate *date=[NSDate date];
    tblSecFrame = [[UIView alloc] init];
    [self.carePlanTable setTableFooterView:[UIView new]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *strDate = [dateFormat stringFromDate:date];
    self.txtDate.text = strDate;
    serviceTypeId = @"0";
    careid = @"0";
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"custSettings"] integerValue] == 1)
    {
        self.serviceTypeView.hidden = NO;
    }
    else
    {
        self.serviceTypeView.hidden = YES;
        self.otherTxtContainer.frame = CGRectMake(self.otherTxtContainer.frame.origin.x, self.serviceTypeView.frame.origin.y, self.otherTxtContainer.frame.size.width, self.otherTxtContainer.frame.size.height + self.serviceTypeView.frame.size.height);
    }
    [self makeRequestForService];
    [self navigationBackButton];
    arSelectedRows = [[NSMutableArray alloc] init];
    self.multiSelectTableContainer.hidden = YES;
    [self makeRequestForConsultationPackages];
    [self makeRequestForSpeciality];
    self.navigationItem.title = [NSString stringWithFormat:@"Assign to %@",self.patName];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];
    viewSize=[[UIScreen mainScreen]bounds].size;
    [self initializePickers];
    _actionSheet = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    _actionSheet.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = _actionSheet.bounds;
    [_actionSheet addSubview:backgroundView];
    self.txtConsultPack.text = @"None";
    packId = @"0";
    // Do any additional setup after loading the view.
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (void)initializePickers
{
    self.serviceTypePicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.serviceTypePicker.delegate = self;
    self.serviceTypePicker.dataSource = self;
    self.serviceTypePicker.backgroundColor = [UIColor whiteColor];
    
    self.consultPackPicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.consultPackPicker.delegate = self;
    self.consultPackPicker.dataSource = self;
    self.consultPackPicker.backgroundColor = [UIColor whiteColor];
    
    self.specPicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.specPicker.delegate = self;
    self.specPicker.dataSource = self;
    self.specPicker.backgroundColor = [UIColor whiteColor];
    
    self.carePlanPicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.carePlanPicker.delegate = self;
    self.carePlanPicker.dataSource = self;
    self.carePlanPicker.backgroundColor = [UIColor whiteColor];

    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    
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
    
    if (self.currentButton==self.serviceTypeBtn)
    {
        [_actionSheet addSubview:self.serviceTypePicker];
        [self.serviceTypePicker reloadAllComponents];
    }
    else if (self.currentButton==self.consultPackBtn)
    {
        [_actionSheet addSubview:self.consultPackPicker];
        [self.consultPackPicker reloadAllComponents];
    }
    else if (self.currentButton == self.specBtn)
    {
        [_actionSheet addSubview:self.specPicker];
        [self.specPicker reloadAllComponents];
    }
    else if (self.currentButton == self.carePlanBtn)
    {
        [_actionSheet addSubview:self.carePlanPicker];
        [self.carePlanPicker reloadAllComponents];
    }
    else if (self.currentButton == self.dateBtn)
    {
        [_actionSheet addSubview:self.datePicker];
//        [self.datePicker reloadAllComponents];
    }
    
    [self.view addSubview:_actionSheet];
    [self.view bringSubviewToFront:_actionSheet];
    _actionSheet.hidden = NO;
    
    
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.currentButton == self.serviceTypeBtn)
    {
        return [serviceArr count];
    }
    else if (self.currentButton == self.consultPackBtn)
    {
        return [consultPackArr count];
    }
    else if (self.currentButton == self.specBtn)
    {
        return [specArray count];
    }
    else if (self.currentButton == self.carePlanBtn)
    {
        return [carePlanArr count];
    }
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (self.currentButton == self.serviceTypeBtn)
    {
        return [[serviceArr objectAtIndex:row] objectForKey:@"service_type_name"];
    }
    else if (self.currentButton == self.consultPackBtn)
    {
        if (row == 0)
            return @"None";
        else
            return [[consultPackArr objectAtIndex:row] objectForKey:@"name"];
    }
    else if (self.currentButton==self.specBtn)
    {
        return [[specArray objectAtIndex:row] objectForKey:@"deptname"];
    }
    else if (self.currentButton==self.carePlanBtn)
    {
        return [[carePlanArr objectAtIndex:row] objectForKey:@"carename"];
    }
    return [NSString stringWithFormat:@"Hey Row %ld", (long)self.currentButton.tag];
}

#pragma mark - Tableview Delegate/Datasource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [carePlanArr count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.textLabel.text = [[carePlanArr objectAtIndex:indexPath.row] objectForKey:@"carename"];
    if([arSelectedRows containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [arSelectedRows addObject:indexPath];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [arSelectedRows removeObject:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Select one or more Care Plan(s)";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = [UIColor colorWithRed:192.0/255.0 green:192.0/255.0 blue:192.0/255.0 alpha:1];
}

#pragma mark - Action Methods
-(void)cancelButtonPressed:(id)sender
{
    _actionSheet.hidden = YES;
}
-(void)doneButtonPressed:(id)sender
{
    if (self.currentButton==self.serviceTypeBtn)
    {
        int row = [self.serviceTypePicker selectedRowInComponent:0];
        self.txtServiceType.text = [[serviceArr objectAtIndex:row] objectForKey:@"service_type_name"];
        serviceTypeId = [[serviceArr objectAtIndex:row] objectForKey:@"recno"];
    }
    else if (self.currentButton==self.consultPackBtn)
    {
        int row =[self.consultPackPicker selectedRowInComponent:0];
        if (row == 0)
        {
            self.txtConsultPack.text = @"None";
            packId = @"0";
        }
        else
        {
            self.txtConsultPack.text = [[consultPackArr objectAtIndex:row] objectForKey:@"name"];
            packId = [[consultPackArr objectAtIndex:row] objectForKey:@"recno"];
        }
    }
    else if (self.currentButton == self.specBtn)
    {
        int row = [self.specPicker selectedRowInComponent:0];
        self.txtSpec.text = [[specArray objectAtIndex:row] objectForKey:@"deptname"];
        self.txtCarePlan.text = nil;
        [self makeRequestForCarePlans:[[specArray objectAtIndex:row] objectForKey:@"recno"]];
    }
    else if (self.currentButton == self.carePlanBtn)
    {
        int row = [self.carePlanPicker selectedRowInComponent:0];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"custSettings"] integerValue] == 1)
        {
            self.txtCarePlan.text = [[carePlanArr objectAtIndex:row] objectForKey:@"carename"];
            careid = [[carePlanArr objectAtIndex:row] objectForKey:@"recno"];
        }
//        [self makeRequestForCarePlans:[[specArray objectAtIndex:row] objectForKey:@"recno"]];
    }
    else if (self.currentButton == self.dateBtn)
    {
        NSDate *date=self.datePicker.date;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd-MM-yyyy"];
        NSString *strDate = [dateFormat stringFromDate:date];
        NSLog(@"date ==== %@",strDate);
        self.txtDate.text=strDate;
    }
    _actionSheet.hidden = YES;
    
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

- (IBAction)serviceTypeBtnClicked:(id)sender
{
    self.currentButton = self.serviceTypeBtn;
    self.currentButton.tag = 1;
    [self showPicker];
}

- (IBAction)consultPackBtnClicked:(id)sender
{
    self.currentButton = self.consultPackBtn;
    self.currentButton.tag = 2;
    [self showPicker];
}

- (IBAction)specBtnClicked:(id)sender
{
    self.currentButton = self.specBtn;
    self.currentButton.tag = 3;
    [self showPicker];
}

- (IBAction)carePlanBtnClicked:(id)sender
{
    if ([carePlanArr count])
    {
        self.currentButton = self.carePlanBtn;
        self.currentButton.tag = 4;
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"custSettings"] integerValue] == 1)
            [self showPicker];
        else
        {
            self.multiSelectTableContainer.hidden = NO;
            [self.carePlanTable reloadData];
            [self loadMultiSelectTable];
        }
    }
    else
    {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:nil message:@"No CarePlan(s) Available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [view show];
        
    }
}

- (IBAction)dateBtnClicked:(id)sender
{
    self.currentButton = self.dateBtn;
    self.currentButton.tag = 5;
    [self showPicker];
}

- (IBAction)doneTableBtnClicked:(id)sender
{
    self.currentButton = self.doneTableBtn;
    self.currentButton.tag = 6;
    selectedCareArray = [self getSelections];
    [self hideMultiSelectTable];
}

-(NSArray *)getSelections {
    NSMutableArray *selections = [[NSMutableArray alloc] init];
    self.txtCarePlan.text = nil;
    careid = nil;
    for(NSIndexPath *indexPath in arSelectedRows) {
        [selections addObject:[carePlanArr objectAtIndex:indexPath.row]];
        if ([self.txtCarePlan.text length] > 0 && self.txtCarePlan.text != nil)
            self.txtCarePlan.text = [NSString stringWithFormat:@"%@, %@", self.txtCarePlan.text, [[carePlanArr objectAtIndex:indexPath.row] objectForKey:@"carename"]];
        else
            self.txtCarePlan.text = [[carePlanArr objectAtIndex:indexPath.row] objectForKey:@"carename"];
        if ([careid length] && careid != nil)
            careid = [NSString stringWithFormat:@"%@*%@", careid, [[carePlanArr objectAtIndex:indexPath.row] objectForKey:@"recno"]];
        else
            careid = [[carePlanArr objectAtIndex:indexPath.row] objectForKey:@"recno"];
    }
    
    return selections;
}
-(void)hideMultiSelectTable
{
    [UIView animateWithDuration:0.2 animations:^{
        _multiSelectTableContainer.frame=CGRectMake(viewSize.width+100,  _multiSelectTableContainer.frame.origin.y,  _multiSelectTableContainer.frame.size.width,  _multiSelectTableContainer.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}
-(void)loadMultiSelectTable
{
    [UIView animateWithDuration:0.2 animations:^{
        _multiSelectTableContainer.frame=CGRectMake(0,  _multiSelectTableContainer.frame.origin.y,  _multiSelectTableContainer.frame.size.width,  _multiSelectTableContainer.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}


- (IBAction)assignBtnClicked:(id)sender
{
    if (self.txtCarePlan.text == nil || ![self.txtCarePlan.text length] || [self.txtCarePlan.text isEqualToString:@"No CarePlan(s) available"])
    {
        [self customAlertView:@"" Message:@"Please choose a care plan to be assigned" tag:1];
        return;
    }
    else
    {
        [self makeRequestToAssignCarePlan];
    }
}

- (IBAction)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
}
-(void)errorSectionId:(id)sender
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
}
#pragma mark Request Methods
- (void)makeRequestForService
{
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dservice"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"Service type sucess %@",response);
        if ([response isKindOfClass:[NSArray class]])
        {
            if ([response count])
            {
                if ([self.serviceTypeView isHidden])
                {
                    self.serviceTypeView.hidden = NO;
                    self.otherTxtContainer.frame = CGRectMake(self.otherTxtContainer.frame.origin.x, self.serviceTypeView.frame.origin.y + self.serviceTypeView.frame.size.height, self.otherTxtContainer.frame.size.width, self.otherTxtContainer.frame.size.height + self.serviceTypeView.frame.size.height);
                }
                serviceArr = response;
                self.txtServiceType.text = [[response objectAtIndex:0] objectForKey:@"service_type_name"];
                serviceTypeId = [[response objectAtIndex:0] objectForKey:@"recno"];
            }
        }
        else
        {
            serviceTypeId = @"0";
            if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
            {
                self.serviceTypeView.hidden = YES;
                self.otherTxtContainer.frame = CGRectMake(self.otherTxtContainer.frame.origin.x, self.serviceTypeView.frame.origin.y, self.otherTxtContainer.frame.size.width, self.otherTxtContainer.frame.size.height + self.serviceTypeView.frame.size.height);
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"custSettings"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
    }];
}
- (void)makeRequestForConsultationPackages
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dpack"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"Consultation package sucess %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                if ([[response objectForKey:@"packages"] count])
                {
                    consultPackArr = [response objectForKey:@"packages"];
                }
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
}

- (void)makeRequestForSpeciality
{
    //    if (![HUD isHidden]) {
    //        [HUD hide:YES];
    //    }
    //    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dspec"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"Speciality sucess %@",response);
        self.view.userInteractionEnabled = YES;
        if ([response count])
        {
            specArray = response;
            self.txtSpec.text = [[specArray objectAtIndex:0] objectForKey:@"deptname"];
            [self makeRequestForCarePlans:[[specArray objectAtIndex:0] objectForKey:@"recno"]];
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
    }];
}
- (void)makeRequestForCarePlans:(NSString *)specId
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&patid=%@&specid=%@",@"sessionid",sectionId, self.patientID, specId];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dcare"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"Consultation package sucess %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                if ([[response objectForKey:@"template"] count])
                {
                    carePlanArr = [response objectForKey:@"template"];
                    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"custSettings"] integerValue] == 1)
                    {
                        self.txtCarePlan.text = [[carePlanArr objectAtIndex:0] objectForKey:@"carename"];
                        careid = [[consultPackArr objectAtIndex:0] objectForKey:@"recno"];
                    }
                }
                else
                {
                    carePlanArr = nil;
                    self.txtCarePlan.text = @"No CarePlan(s) available";
                }
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        //        [self customAlertView:@"" Message:@"Fetching care plans failed due to network issues. Please try again." tag:0];
    }];
}

- (void)makeRequestToAssignCarePlan
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"sessionid=%@&service_type=%@&patid=%@&doa=%@&careid=%@&packid=%@",sectionId, serviceTypeId, self.patientID,self.txtDate.text,careid, packId];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dcareassign"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"Consultation package sucess %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else
        {
            [HUD hide:YES];
            [HUD removeFromSuperview];
            if ([response objectForKey:@"carecredit"])
            {
                if ([[response objectForKey:@"carecredit"] integerValue] == 0)
                {
                    [self customAlertView:@"" Message:@"Patient doesn’t have credit to assign care plan." tag:0];
                }
            }
            else if ([response objectForKey:@"tempadded"] == [NSNull null] || [response objectForKey:@"tempadded"] == nil || [[response objectForKey:@"tempadded"] integerValue] <= 0)
            {
                [self customAlertView:@"" Message:@"Could not Assign Care Plan. Please try again later" tag:0];
            }
            else if ([[response objectForKey:@"tempadded"] integerValue] == 1)
            {
                [self customAlertView:@"" Message:@"Care Plan has been Assigned Successfully." tag:0]; //pop
            }
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
}

#pragma mark - Aletview Delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
