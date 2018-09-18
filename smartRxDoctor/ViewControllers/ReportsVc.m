//
//  ReportsVc.m
//  smartRxDoctor
//
//  Created by Gowtham on 19/01/18.
//  Copyright © 2018 Anil Kumar. All rights reserved.
//

#import "ReportsVc.h"
#import "smartRxDashboardVC.h"
#import "ReportsResponseModel.h"
#import <QuickLook/QuickLook.h>
#import "SmartRxReportImageVC.h"
@interface ReportsVc ()<QLPreviewControllerDataSource,QLPreviewControllerDelegate>
{
    MBProgressHUD *HUD;
    BOOL pdfSuccess;

}
@property(nonatomic,strong) NSArray *reportsArray;
@end

@implementation ReportsVc
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
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"Reports" controler:self];

    self.noApsLbl.hidden = YES;
    pdfSuccess = YES;
    [self.tableView setTableFooterView:[UIView new]];
    [self navigationBackButton];
    [self makeRequestForReports];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
-(void)imgaeZooming:(NSString *)sender
{
    [self performSegueWithIdentifier:@"zoomImageID" sender:sender];
}
#pragma mark - Request Methods
-(void)makeRequestForReports{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%@%@%@",WB_BASEURL,@"ehr/records/r_diagnostic/member/",_patientId];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"GET" setHeader:NO  successHandler:^(id response)
     {
         NSLog(@"success 999:%@",response);
         if (response == nil)
         {
             [HUD hide:YES];
             [HUD removeFromSuperview];
             [self customAlertView:@"" Message:@"Internal server error" tag:0];
         }
         else{
             
           
                 dispatch_async(dispatch_get_main_queue(),^{
                     [HUD hide:YES];
                     [HUD removeFromSuperview];
                     NSMutableArray *array = [[NSMutableArray alloc]init];

                     for (NSDictionary *dict in response) {
                         ReportsResponseModel *model = [[ReportsResponseModel alloc]init];
                         model.date = [self getDate:dict[@"created_date"]];
                         model.reportDescrption = dict[@"category"];
                         model.imagePath = dict[@"content_images"];
                         model.uploadedBy = [self getUserType:dict[@"uploaded_by"]];
                         [array addObject:model];
                     }
                     self.reportsArray = [array copy];
                     if (self.reportsArray.count) {
                         self.noApsLbl.hidden = YES;
                         self.tableView.hidden = NO;
                         [self.tableView reloadData];
                     }else {
                         self.tableView.hidden = YES;
                         self.noApsLbl.hidden = NO;
                     }
                 });
                 
                 
             }}failureHandler:^(id response) {
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
-(NSString *)getUserType:(NSString *)userType{
    NSString *typeStr = @"";
    if ([userType isEqualToString:self.patientId]) {
        typeStr = @"user";
    }else {
        typeStr = @"hospital";
    }
       return typeStr;
}
-(NSString *)getDate:(NSString *)dateStr{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    
    [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
    
    
    return [dateFormatter stringFromDate:date];
}
#pragma mark - TableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.reportsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ReportsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reportsCell"];
    cell.delegate = self;
    cell.cellId = indexPath;
    ReportsResponseModel *model = self.reportsArray[indexPath.row];
    cell.descriptionLbl.text = model.reportDescrption;
    cell.dateLbl.text = model.date;
    cell.thumbnailImageVw.image = [UIImage imageNamed:model.uploadedBy];
    return cell;
}
-(void)viewBtnClicked:(NSIndexPath *)indexPath{
    ReportsResponseModel *model = self.reportsArray[indexPath.row];
    NSString *splitString;
    //    [self.strImage rangeOfString:@"patient"].location != NSNotFound
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(containsString:)])
    {
        if ([model.imagePath containsString:@"patient/data/pat_uploaded_files/"])
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([model.imagePath containsString:@"admin/data/servicefiles/"])
            splitString = @"admin/data/servicefiles/";
    }
    else
    {
        if ([model.imagePath rangeOfString:@"patient/data/pat_uploaded_files/"].location != NSNotFound)
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([model.imagePath rangeOfString:@"admin/data/servicefiles/"].location != NSNotFound)
            splitString = @"admin/data/servicefiles/";
        
    }
    NSArray *arrImg = [model.imagePath componentsSeparatedByString:@","];
    
    NSArray *arrFileType = [NSArray arrayWithObjects:@"pdf", @"doc", @"docx", @"rtf", @"csv", @"text", @"xlsx",@"xlsm", @"xls", @"xlt", nil];
    // NSArray *arrExtensionType = [[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"content_images"] componentsSeparatedByString:@"."];
    
    NSArray *arrExtensionType = [[arrImg objectAtIndex:0] componentsSeparatedByString:@"."];
    if ([arrExtensionType count] && [arrFileType containsObject:arrExtensionType[([arrExtensionType count]-1)]]) {
        [self openFile:arrImg[0]];
    }else
        [self imgaeZooming:arrImg[0]];


}
-(void)downloadBtnClicked:(NSIndexPath *)indexPath{
    [self viewBtnClicked:indexPath];
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
#pragma mark - Qlpreview
-(void)openFile:(NSString *)strFilePath{
    [self addSpinnerView];
    [HUD show:YES];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGE_URL,strFilePath]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSArray *fileComponents = [strFilePath componentsSeparatedByString:@"."];
        _pdfPath = [documentsDirectory stringByAppendingPathComponent:[@"file." stringByAppendingString:fileComponents[1]]];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [data writeToFile:_pdfPath atomically:YES];
        BOOL success = [QLPreviewController canPreviewItem:[NSURL URLWithString:_pdfPath]];
        if (success) {
            QLPreviewController *previewer = [[QLPreviewController alloc] init];
            [previewer setDataSource:self];
            [previewer setCurrentPreviewItemIndex:0];
            [[self navigationController] presentViewController:previewer animated:YES completion:^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
            }];
        } else {
            [HUD hide:YES];
            [HUD removeFromSuperview];
            pdfSuccess = NO;
            [self imgaeZooming:strFilePath];
            
        }
    }];
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:_pdfPath];
}

-(void)previewControllerWillDismiss:(QLPreviewController *)controller{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtPath:_pdfPath error:&error];
    if (success) {
        NSLog(@"deleted file");
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"zoomImageID"])
    {
        if (pdfSuccess) {
            ((SmartRxReportImageVC *)segue.destinationViewController).strImage = sender;
        } else {
            ((SmartRxReportImageVC *)segue.destinationViewController).webUrl = sender;
        }
    }
}


@end
