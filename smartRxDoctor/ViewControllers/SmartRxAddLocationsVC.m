//
//  SmartRxAddLocationsVC.m
//  SmartRx
//
//  Created by Gowtham on 14/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "SmartRxAddLocationsVC.h"
#import "CitiesResponseModel.h"
#import "SmartRxCommonClass.h"
#import "LocaltyResponseModel.h"
#import "smartRxDashBoardVC.h"


@interface SmartRxAddLocationsVC ()
{
    MBProgressHUD *HUD;
    CGSize viewSize;
    CitiesResponseModel *selectedCity;
    LocaltyResponseModel *selectedLocality;
    NSString *zipcodeStr;
    BOOL isZipcodeTrue;

}

@end

@implementation SmartRxAddLocationsVC
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
#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=self.titleStr;;
    viewSize=[[UIScreen mainScreen]bounds].size;

    self.addressTypeTF.text = @"Clinic Location";
    self.menuView.hidden = YES;
    selectedLocality = [[LocaltyResponseModel alloc]init];
    if (self.selectedLocationModel) {
        self.addressTypeTF.text = self.selectedLocationModel.addressType;
        self.zipcodeTF.text = self.selectedLocationModel.zipcode;
        self.cityTF.text = self.selectedLocationModel.cityName;
        self.addressTF.text = self.selectedLocationModel.address;
        if ([self.selectedLocationModel.localityName isKindOfClass:[NSString class]]) {
            self.localityTF.text = self.selectedLocationModel.localityName;
            self.zoneTF.text = self.selectedLocationModel.zoneName;

        }
        selectedLocality.localityId = self.selectedLocationModel.localityId;
    }
    _actionSheet = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    _actionSheet.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = _actionSheet.bounds;
    [_actionSheet addSubview:backgroundView];
    
    [self navigationBackButton];
    [self initializePickers];
    [self makeRequestForCities];
    
}
- (void)initializePickers
{
    self.citiesPicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.citiesPicker.delegate = self;
    self.citiesPicker.dataSource = self;
    self.citiesPicker.backgroundColor = [UIColor whiteColor];
    
    self.localityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.localityPicker.delegate = self;
    self.localityPicker.dataSource = self;
    self.localityPicker.backgroundColor = [UIColor whiteColor];
    
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
    
    
    if (self.currentButton == self.citiesBtn)
    {
        [_actionSheet addSubview:self.citiesPicker];
        [self.citiesPicker reloadAllComponents];
        //[self.citiesPicker selectRow:selectedTimeRow inComponent:0 animated:NO];  //TO-DO
    }
    else if (self.currentButton==self.localityBtn)
    {
        [_actionSheet addSubview:self.localityPicker];
        [self.localityPicker reloadAllComponents];
        //[self.eConsultStatusPicker selectRow:statusIndex inComponent:0 animated:NO];  //TO-DO
    } else if (self.currentButton==self.zoneBtn)
    {
        [_actionSheet addSubview:self.zonePicker];
        [self.zonePicker reloadAllComponents];
        //[self.eConsultStatusPicker selectRow:statusIndex inComponent:0 animated:NO];  //TO-DO
    }
    

     //TO-DO
    
    [self.view addSubview:_actionSheet];
    [self.view bringSubviewToFront:_actionSheet];
    _actionSheet.hidden = NO;
    
    
}


#pragma mark - Request methods

-(void)makeRequestForCityByZipcode
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    selectedLocality =nil;
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&zipcode=%@",@"sessionid",sectionId,zipcodeStr];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"isopen",@"1"];
    }
    
    
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"citybyzip"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 7 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            NSLog(@"failure");
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                
                if (response == nil)
                {
                    
                    [self customAlertView:@"" Message:@"Locations Not available" tag:0];
                }
                else{
                    
                    self.citiesArray = nil;
                    self.localityArray = nil;
                    
                    NSDictionary *dict = response[@"city"];
                    
                    NSString *checkStr = dict[@"name"];
                    if ([checkStr isKindOfClass:[NSString class]]) {
    
                    
                    selectedCity = [[CitiesResponseModel alloc]init];
                    
                    selectedCity.cityName = dict[@"name"];
                    selectedCity.cityId = dict[@"id"];

                    self.cityTF.text = selectedCity.cityName;
                    isZipcodeTrue = YES;
                    self.localityTF.text = @"Select Locality";
                    self.zoneTF.text = @"Select Zone";
                       [self makeRequestForLocality];
                    } else {
                        self.zipcodeTF.text = nil;
                        self.localityTF.text = @"Select Locality";
                        self.zoneTF.text = @"Select Zone";
                        self.cityTF.text = @"--Select City--";
                        self.citiesArray = self.citiesMainArray;
                        [self customAlertView:@"" Message:@"No Locations Available for this Zip Code" tag:0];
                    }
                }
                
            });
            
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}


-(void)makeRequestForCities
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"isopen",@"1"];
    }
    
    
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"cities/index"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 7 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            NSLog(@"failure");
        }
        else{
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    self.view.userInteractionEnabled = YES;
                    
                    if (response == nil)
                    {
                        [self customAlertView:@"" Message:@"No locations available" tag:0];
                    }
                    else{
                        
                        NSMutableArray *tempAaray = [[NSMutableArray alloc]init];
                        
                        for (NSDictionary *dict in response) {
                            CitiesResponseModel *model = [[CitiesResponseModel alloc]init];
                            
                            model.cityName = dict[@"name"];
                            model.cityId = dict[@"id"];
                            
                            [tempAaray addObject:model];
                            
                        }
                        
                        self.citiesArray = [tempAaray copy];
                        self.citiesMainArray =[tempAaray copy];
                        if (self.citiesArray.count) {
                            if (self.selectedLocationModel ==nil) {
                                selectedCity= self.citiesArray[0];
                                //self.cityTF.text = selectedCity.cityName;
                            }
                            else {
                                selectedCity = [[CitiesResponseModel alloc]init];
                                selectedCity.cityName = self.selectedLocationModel.cityName;
                                selectedCity.cityId = self.selectedLocationModel.cityId;
                            }
                            //self.tblDoctorsList.hidden=NO;
                            
                            
                        }
                        
                        [self makeRequestForLocality];
                        
                    }
                    
                });
            
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}
-(void)makeRequestForLocality
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&city_id=%@",@"sessionid",sectionId,selectedCity.cityId];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"isopen",@"1"];
    }
    
    
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"localitybycityzip"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 7 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            NSLog(@"failure");
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                
                if (response == nil)
                {
                    [self customAlertView:@"" Message:@"Locations Not available" tag:0];
                }
                else{
                    
                    NSMutableArray *tempAaray = [[NSMutableArray alloc]init];
                    
                    NSArray *array = response[@"localities"];
                    
                    for (NSDictionary *dict in array) {
                        LocaltyResponseModel *model = [[LocaltyResponseModel alloc]init];
                        
                        model.localityName = dict[@"name"];
                        model.localityId = dict[@"id"];
                        model.zoneName = dict[@"zone"][@"name"];
                        model.zoneId = dict[@"zone_id"];
                        [tempAaray addObject:model];
                        
                    }
                    
                    self.localityArray = [tempAaray copy];
                    self.localityMainArray = [tempAaray copy];

                    if (self.localityArray.count) {
                        if (self.selectedLocationModel == nil) {
                            
                       selectedLocality= self.localityArray[0];
                       // self.localityTF.text = selectedLocality.localityName;
                        //self.tblDoctorsList.hidden=NO;
                        }else {
                            selectedLocality = [[LocaltyResponseModel alloc]init];
                            selectedLocality.localityName = self.selectedLocationModel.localityName;
                            selectedLocality.localityId = self.selectedLocationModel.localityId;
                            selectedLocality.zoneName = self.selectedLocationModel.zoneName;
                            selectedLocality.zoneId = self.selectedLocationModel.zoneId;

                            //self.localityTF.text = @"Select Locality";

                        }
              
                    } else {
                        self.localityTF.text = @"No locality available";
                    }
                    
                }
                
            });
            
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}
-(void)makeRequestForSaveLocation{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
    NSString *localtyId = @"";
    if (selectedLocality.localityId) {
        localtyId = selectedLocality.localityId;
    }
    NSString *bodyText=nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&city_id=%@&lname=%@&address=%@&latitude=%@&longitude=%@&locality_id=%@&zipcode=%@&cid=%@&uid=%@&isopen=1&zone_id=%@",@"sessionid",sectionId,selectedCity.cityId,self.addressTypeTF.text,self.addressTF.text,@"",@"",localtyId,self.zipcodeTF.text,strCid,userId,selectedLocality.zoneId];
    }
    if (self.selectedLocationModel) {
        NSString *updateStr = [NSString stringWithFormat:@"&mode=edit&mylocid=%@",self.selectedLocationModel.locationId];
        bodyText = [bodyText stringByAppendingString:updateStr];
    }
    
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"savelocations"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        
        NSLog(@"sucess 67 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            NSLog(@"failure");
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                
                if ([response[@"authorized"] integerValue] == 1 && [response[@"result"] integerValue] == 1) {
                    
                    if (![response[@"in_status"] isEqual:[NSNull null]]) {
                        
                if (!([response[@"in_status"] integerValue] == -4)) {
                        
                    
                    if (self.selectedLocationModel) {
                        [self customAlertView:@"Upadted Succesfully" Message:@"" tag:1];
                    }
                    else {
                         [self customAlertView:@"Saved Succesfully" Message:@"" tag:1];
                    }
                    } else {
                        [self customAlertView:@"Sorry! Unable to update!!" Message:@"" tag:0];
                    }
                    }else{
                         [self customAlertView:@"Updated Successfully" Message:@"" tag:1];
                    }
                    
                } else {
                    [self customAlertView:@"Some error occured" Message:@"Try again" tag:0];
                }
                
            });
            
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];


    
}

-(void)addSpinnerView{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
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


-(IBAction)clickOnSelectCitybutton:(id)sender{
    
    if (!isZipcodeTrue) {
        if (self.citiesArray.count) {
            self.currentButton = self.citiesBtn;
            [self showPicker];
        }else {
            [self customAlertView:@"" Message:@"No locations available" tag:0];
        }
       
        
//        self.tableViewType = CitiestableView;
//        [self.tableView reloadData];
//        
//        self.menuView.hidden = NO;
//        
//        self.menuView.frame = CGRectMake(8, self.cityTF.frame.origin.y+10, self.view.frame.size.width-16, 184);
    }
    
 
}
-(IBAction)clickOnSelectLocalitybutton:(id)sender{
    
    if (self.localityArray.count) {
        self.currentButton = self.localityBtn;
        [self showPicker];

        
//        self.tableViewType = LocalityTableView;
//        [self.tableView reloadData];
//        
//        self.menuView.hidden = NO;
//        
//        self.menuView.frame = CGRectMake(8, 64, self.view.frame.size.width-16, 184);
    }
    
    
}
-(IBAction)clickOnSelectZonebutton:(id)sender{
    
    if (self.zoneArray.count) {
        self.currentButton = self.zoneBtn;
        [self showPicker];
        
        //        self.tableViewType = LocalityTableView;
        //        [self.tableView reloadData];
        //
        //        self.menuView.hidden = NO;
        //
        //        self.menuView.frame = CGRectMake(8, 64, self.view.frame.size.width-16, 184);
    }
    
    
}
-(void)cancelButtonPressed:(id)sender
{
    _actionSheet.hidden = YES;
}
-(void)doneButtonPressed:(id)sender
{
    
    if (self.currentButton == self.citiesBtn)
    {
        selectedCity =[self.citiesArray objectAtIndex:[self.citiesPicker selectedRowInComponent:0]];
        self.cityTF.text = selectedCity.cityName;
        self.zipcodeTF.text = nil;
        self.localityTF.text = @"Select Locality";
        self.zoneTF.text = @"Select Zone";
        [self makeRequestForLocality];

        //selectedTimeRow = [self.timePicker selectedRowInComponent:0];
        //self.timeLbl.textColor = [UIColor blackColor];
    }else if (self.currentButton == self.localityBtn)
    {
       selectedLocality =[self.localityArray objectAtIndex:[self.localityPicker selectedRowInComponent:0]];
        self.localityTF.text = selectedLocality.localityName;
        self.zoneTF.text = selectedLocality.zoneName;
        //selectedTimeRow = [self.timePicker selectedRowInComponent:0];
        //self.timeLbl.textColor = [UIColor blackColor];
    }else if (self.currentButton == self.zoneBtn)
    {
        LocaltyResponseModel *model =[self.localityArray objectAtIndex:[self.localityPicker selectedRowInComponent:0]];
        self.cityTF.text = model.localityName;
        //selectedTimeRow = [self.timePicker selectedRowInComponent:0];
        //self.timeLbl.textColor = [UIColor blackColor];
    }
    _actionSheet.hidden = YES;

}
-(IBAction)clickOnCancelBtn:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)clickOnDoneBtn:(id)sender{
    
    [self.view endEditing:YES];
    
    if (self.addressTypeTF.text.length == 0) {
        [self customAlertView:@"Error" Message:@"Address nick name should not be empty" tag:0];
    }
   else if (self.zipcodeTF.text.length != 6) {
        [self customAlertView:@"Error" Message:@"Zipcode should not be empty." tag:0];
    } else if (self.cityTF.text.length == 0 || [self.cityTF.text isEqualToString:@"No Cities Available"]){
        [self customAlertView:@"Error" Message:@"City should not be empty." tag:0];
    } else if (self.localityTF.text.length == 0 || [self.localityTF.text isEqualToString:@"No localities available"] || [self.localityTF.text isEqualToString:@"Select Locality"]){
        [self customAlertView:@"Error" Message:@"Locality should not be empty." tag:0];
    }
    //else if (self.localityTF.text.length == 0){
//        [self customAlertView:@"Error" Message:@"Please select locality" tag:0];
    //}
else {
        [self makeRequestForSaveLocation];
    }
    
    
    
}
#pragma mark - TableView Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count;
    if (self.tableViewType == CitiestableView) {
        count = self.citiesArray.count;
    } else {
        count = self.localityArray.count;
    }
    
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (self.tableViewType == CitiestableView) {
        CitiesResponseModel *model = self.citiesArray[indexPath.row];
        cell.textLabel.text = model.cityName;
    } else {
        LocaltyResponseModel *model = self.localityArray[indexPath.row];
        cell.textLabel.text = model.localityName;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableViewType == CitiestableView) {
      selectedCity = self.citiesArray[indexPath.row];
        self.zipcodeTF.text = nil;
        self.cityTF.text = selectedCity.cityName;
        [self makeRequestForLocality];
        
    } else {
        selectedLocality = self.localityArray[indexPath.row];
        self.localityTF.text = selectedLocality.localityName;
    }
    
    self.menuView.hidden = YES;
}
#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
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
    if (self.currentButton == self.citiesBtn)
    {
        return [self.citiesArray count];
    }
    
    else if (self.currentButton==self.localityBtn)
    {
        return [self.localityArray count];
    }
    
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (self.currentButton==self.citiesBtn)
    {
        CitiesResponseModel *model = self.citiesArray[row];
        return model.cityName;
    }
    
    else if (self.currentButton==self.localityBtn)
    {
        //statusIndex = row;
        LocaltyResponseModel *model = self.localityArray[row];
        return model.localityName;
    }
    return [NSString stringWithFormat:@"Hey Row %ld", (long)self.currentButton.tag];
}




#pragma mark - UITextField Delegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField == self.zipcodeTF) {
        self.cityTF.text = @"No Cities Available";
        self.localityTF.text = @"No localities available";
        if (self.zipcodeTF.text.length == 5 && ![string isEqualToString:@""]) {
            
            zipcodeStr = textField.text;
            zipcodeStr = [zipcodeStr stringByAppendingString:string];
            self.zipcodeTF.text = zipcodeStr;
            [self.zipcodeTF resignFirstResponder];
              [self makeRequestForCityByZipcode];

        }else if(self.zipcodeTF.text.length >= 6){
            if (![string isEqualToString:@""]) {
                return NO;

            }
        }
    }
    
    return YES;
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField == self.zipcodeTF){
      
    }
   
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
