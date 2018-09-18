//
//  smartRxPatientLookUp.m
//  smartRxDoctor
//
//  Created by Manju Basha on 09/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "smartRxPatientLookUp.h"
#import "smartRxPatientDetails.h"

@interface smartRxPatientLookUp ()
{
    MBProgressHUD *HUD;
    NSMutableArray *searchArray;
    
}
@end

@implementation smartRxPatientLookUp

- (void)viewDidLoad
{
    self.searchField.frame = CGRectMake(self.searchField.frame.origin.x, self.searchField.frame.origin.y-7, self.searchField.frame.size.width, self.searchField.frame.size.height+7);
    searchArray = [[NSMutableArray alloc] init];
    [super viewDidLoad];
    [self navigationBackButton];
    [self.patientTableView setTableFooterView:[UIView new]];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Action Methods

-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)doneButton:(id)sender {
    [self.searchField resignFirstResponder];
}
#pragma mark - Custom AlertView
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
#pragma mark - Tableview Delegate/Datasource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [searchArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    //Cell text attributes
    NSString *data = [NSString stringWithFormat:@"%@ - %@",[[searchArray objectAtIndex:indexPath.row] objectForKey:@"username"],[[searchArray objectAtIndex:indexPath.row] objectForKey:@"primaryphone"]];
    cell.textLabel.text = data;
    cell.tag = [[[searchArray objectAtIndex:indexPath.row] objectForKey:@"value"] integerValue];
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    
    // To bring the arrow mark on right end of each cell.
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.noMatchLabel.hidden = YES;
    self.searchField.text = [[searchArray objectAtIndex:indexPath.row] objectForKey:@"carename"];
    self.searchField.tag  = [[[searchArray objectAtIndex:indexPath.row] objectForKey:@"recno"] integerValue];
    [self performSegueWithIdentifier:@"patientDetails" sender:[searchArray objectAtIndex:indexPath.row]];
}
#pragma mark - Request Methods
-(void)makeRequestToGetPatientDetails:(NSString *)str
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&term=%@",@"sessionid",sectionId,str];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dpsearch"];
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
            if ([[response objectForKey:@"search"] count])
            {
                searchArray = [response objectForKey:@"search"];
                self.noMatchLabel.hidden = YES;
                self.patientTableView.hidden = NO;
                [self.patientTableView reloadData];
                if ([searchArray count] > 7)
                {
                   // [self.patientTableView setContentSize:CGSizeMake(self.patientTableView.contentSize.width, self.patientTableView.contentSize.height + (([searchArray count]-7)*44))];
                }
            }
            else
            {
                self.noMatchLabel.hidden = NO;
                self.patientTableView.hidden = YES;
            }
            self.view.userInteractionEnabled = YES;

        }
    } failureHandler:^(id response) {
        NSLog(@"Error ; %@", response);
        
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"The request timed out" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//        [self customAlertView:@"Error" Message:@"Loading profile failed due to network issues" tag:0];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}

#pragma mark - Text filed Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    textField.inputAccessoryView = doneToolbar;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([str length] >= 3)
        [self makeRequestToGetPatientDetails:str];
    else if ([str length] < 3 && [str length] > 0)
    {
        self.noMatchLabel.hidden = NO;
        self.patientTableView.hidden = YES;
    }
    return YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self doneButton:nil];
    if ([segue.identifier isEqualToString:@"patientDetails"])
    {
        ((smartRxPatientDetails *)segue.destinationViewController).userDetailsDict = [[NSMutableDictionary alloc] initWithDictionary:sender];
    }
}


@end
