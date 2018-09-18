//
//  SmartRxChatListVC.m
//  SmartRx
//
//  Created by SmartRx-iOS on 21/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxChatListVC.h"
#import "ConversationViewController.h"
#import "smartRxDashboardVC.h"
#import "ChatHistoryResponseModel.h"
#import "ChatListCell.h"

@interface SmartRxChatListVC ()
@property(nonatomic,strong) NSArray *chatListArray;
@property(nonatomic,strong) NSString *patientId;
@property(nonatomic,strong) NSString *roomName;
@property(nonatomic,strong) NSString *chatMessage;
@property(nonatomic,strong) NSString *patientName;
@property(nonatomic,strong) NSString *patientPic;
@property(nonatomic,strong) ChatHistoryResponseModel *selectedChat;
@property(nonatomic,assign) BOOL isNewChat;
@end

@implementation SmartRxChatListVC
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
    btnFaq.tag=1;
    UIImage *faqBtnImag = [UIImage imageNamed:@"icn_add_report.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    
    [btnFaq addTarget:self action:@selector(addEhr:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
   // self.navigationItem.rightBarButtonItem = rightbutton;
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Chats";
  
    
    [self.tableView setTableFooterView:[UIView new]];
    self.noAppsLbl.hidden = YES;
    self.isNewChat = NO;
    [self navigationBackButton];
    
    if (self.patientDict != nil) {
        self.isNewChat = YES;
        ChatHistoryResponseModel *model= [[ChatHistoryResponseModel alloc]init];
        model.patientName = self.patientDict[@"patienttName"];
        model.patientId = self.patientDict[@"patientId"];
        model.patientProfilePic = self.patientDict[@"profilepic"];
        model.roomId = self.patientDict[@"roomname"];
        self.selectedChat = model;
        self.patientId = self.selectedChat.patientId;
        self.roomName = self.selectedChat.roomId;
        self.patientName = self.selectedChat.patientName;
        self.patientPic = self.selectedChat.patientProfilePic;
        //NSString *cokie = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];

//        NSString *some = [NSString stringWithFormat:@"%@,%@,%@",model.patientId,model.patientName,model.roomId];
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:cokie delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
        
        [self moveToChatHistoryController];
    }
   
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

    [self makeRequestForChatList];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    self.selectedChat = nil;
    self.patientPic = nil;
    self.patientName = nil;
    self.patientId = nil;
    self.chatMessage = nil;
    self.roomName = nil;
    self.patientDict = nil;
    self.isNewChat = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
#pragma mark - Request Methods

-(void)makeRequestForChatList{
    NSString *doctorId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    NSLog(@"doctorID........:%@",doctorId);
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"sessionid=%@",sectionId];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dget_chat_history"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO successHandler:^(id response) {
        if ([[response[0] objectForKey:@"authorized"]integerValue] == 0 && [[response[0] objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }else {
            dispatch_async(dispatch_get_main_queue(),^{
                
                NSLog(@"chat history........:%@",response);

            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            NSDictionary *tempDict = response[0];
            NSArray *dataArray = tempDict[@"data"];
            NSMutableArray *tempArr = [[NSMutableArray alloc]init];
            for (NSDictionary *dict in dataArray) {
                ChatHistoryResponseModel *model= [[ChatHistoryResponseModel alloc]init];
                model.patientName = dict[@"name"];
                model.patientId = dict[@"to_id"];
                model.patientProfilePic = dict[@"profile_pic"];
                model.roomId = dict[@"room_id"];
                model.lastMessageTime = dict[@"last_msg_senton"];
                model.status = dict[@"status"];
                [tempArr addObject:model];
            }
            self.chatListArray = [tempArr copy];
            if (self.chatListArray.count) {
                self.tableView.hidden = NO;
                self.noAppsLbl.hidden = YES;
                [self.tableView reloadData];
            }else {
                self.tableView.hidden = YES;
                self.noAppsLbl.hidden = NO;
            }
                
        });
        }

    } failureHandler:^(id response) {
        dispatch_async(dispatch_get_main_queue(),^{

        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        [self showAlert];
        });

    }];
    
}


-(void)showAlert{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error" message:@"Network not available" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:okAction];
    [self presentViewController:controller animated:YES completion:nil];
    controller.view.tintColor = [UIColor blueColor];

}

#pragma mark -Tableview methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 70.0;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatListArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    ChatHistoryResponseModel *model = self.chatListArray[indexPath.row];
    [cell setCellData:model];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedChat = self.chatListArray[indexPath.row];
    //self.selectedChat.roomId = @"LlSqxYOnr_";
    //NSLog(@"room id...:%@",self.selectedChat.roomId);
    self.patientId = self.selectedChat.patientId;
    self.roomName = self.selectedChat.roomId;
    self.patientName = self.selectedChat.patientName;
    self.patientPic = self.selectedChat.patientProfilePic;
    [self moveToChatHistoryController];
}
#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];

    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForChatList];
    }
    else{
        [self showAlert];
    }
}

-(void)errorSectionId:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.view.userInteractionEnabled = YES;
}

#pragma mark - Navigation
-(void)moveToChatHistoryController{
    
    [self performSegueWithIdentifier:@"chatConversationVC" sender:nil];
    
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"chatConversationVC"]) {
        ConversationViewController *controller = segue.destinationViewController;
        controller.patientId = self.patientId;
        controller.roomName = self.roomName;
        controller.chatMessage = self.chatMessage;
        controller.patientName = self.patientName;
        controller.patientProfilePic = self.patientPic;
        controller.selectedChat = self.selectedChat;
        controller.isNewChat = _isNewChat;
        
    }
}



@end
