//
//  ConversationViewController.m
//  SphChatNew
//
//  Created by SmartRx-iOS on 06/02/18.
//  Copyright © 2018 SmartRx-iOS. All rights reserved.
//

#import "ConversationViewController.h"
#import "JSQMessagesViewAccessoryButtonDelegate.h"
#import "UIKit+AFNetworking.h"
#import "AFNetworking.h"
#import "smartRxDashboardVC.h"
#import "MediaVC.h"
#import <QuickLook/QuickLook.h>
#import "CustomPreViewItem.h"

@interface ConversationViewController ()<JSQMessagesViewAccessoryButtonDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate>
{
    SocketManager* manager;
    SocketIOClient* socket;
    UILabel *noApsLbl;
    NSMutableArray *avatharArr;
    UIImage *selectedImage;
    NSString *selectedImageUrl;
    NSString *imageName;
    NSData *documentData;
    UITapGestureRecognizer *tap;
    BOOL isPdfSelected;
    BOOL isAdded;
    BOOL isImage;
    BOOL pdfSuccess;
    BOOL isMoving;
    BOOL isDefaultMessage;
    BOOL isSetTitle;
}
@end

@implementation ConversationViewController
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
-(void)navigationRightButton{
    
    UIButton *btnFaq = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFaq.tag=1;
    [btnFaq setTitle:@"Close" forState:UIControlStateNormal];
    [btnFaq setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //    UIImage *faqBtnImag = [UIImage imageNamed:@"icn_add_report.png"];
    //    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    
    [btnFaq addTarget:self action:@selector(closeChat:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    NSString *title = [NSString stringWithFormat:@"Chat with %@",self.patientName];
    if (self.doctorName != nil) {
        isSetTitle = YES;
        title = [NSString stringWithFormat:@"Chat With %@",self.doctorName];
    }
    self.title = title;
    self.doctorName = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"];
    self.doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
    NSLog(@"data from local.....:%@",self.doctorId);
    self.userType = [[NSUserDefaults standardUserDefaults]objectForKey:@"usertype"];
    self.doctorPic = [[NSUserDefaults standardUserDefaults]objectForKey:@"profilePicLink"];
    self.inputToolbar.contentView.textView.jsqPasteDelegate = self;
    self.chatData = [[ChatModel alloc] init];
    self.collectionView.accessoryDelegate = self;
    self.automaticallyScrollsToMostRecentMessage = YES;
    avatharArr = [[NSMutableArray alloc]init];
    
    NSString *doctorProfile;
    
    self.inputToolbar.hidden = NO;
    if (![self.doctorPic isEqualToString:@""]) {
        
        doctorProfile = [NSString stringWithFormat:@"%@%@",IMAGE_URL_TEST,self.doctorPic];
         //doctorProfile = [doctorProfile stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }else {
        doctorProfile = NO_IMAGE;
    }
    self.doctorPic = doctorProfile;
    NSDictionary *dict = @{@"avtharUrl":doctorProfile,@"senderId":self.doctorId};
    [avatharArr addObject:dict];
    if (![NSUserDefaults incomingAvatarSetting]) {
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    }
    
    if (![NSUserDefaults outgoingAvatarSetting]) {
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    }
    
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(customAction:)];
    
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];
    
    
   
    
    if ([self.selectedChat.status integerValue] == 2 || self.isNewChat) {
        [self navigationRightButton];
        [self socketConnetion];
    }
    [self navigationBackButton];
    if (self.patientId != nil && self.isNewChat == NO) {
        [self makeRequestForChatHistory];
        
    }else{
        isDefaultMessage = YES;
    }
    
}
-(void)removeDefaultMessage{
    isDefaultMessage = NO;
}
-(void)dismissKeyboard
{
    NSLog(@"dismissKeyboard");
    [self.view endEditing:YES];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = [NSUserDefaults springinessSetting];
    tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.collectionView addGestureRecognizer:tap];
    if (!isAdded) {
        NSString *errorMsg = self.chatMessage;
        if (self.selectedChat != nil) {
            errorMsg = @"No chat history found";
        }
    CGSize size = [UIScreen mainScreen].bounds.size;
    noApsLbl =[[UILabel alloc]init];
    noApsLbl.frame = CGRectMake(16, self.view.frame.size.height/2-40, size.width-32, 80);

    noApsLbl.text = errorMsg;
    noApsLbl.textColor = [UIColor darkGrayColor];
    //noApsLbl.backgroundColor= [UIColor redColor];
    noApsLbl.textAlignment = NSTextAlignmentCenter;
    noApsLbl.numberOfLines = 4;
    //[self.view addSubview:noApsLbl];
        
    if (self.chatData.messages.count) {
            noApsLbl.hidden = YES;
        }
        isAdded = YES;
    }
    

    
}
-(void)clickOnEmptyPage{
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:@"Please wait, until doctor accept the request" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:okAction];
    [self presentViewController:controller animated:YES completion:nil];
    controller.view.tintColor = [UIColor blueColor];

}

-(void)socketConnetion{
    
    NSLog(@"socketConnetion");
    NSURL* url = [[NSURL alloc] initWithString:CHAT_URL];
    NSLog(@"chat url......:%@",CHAT_URL);
    manager = [[SocketManager alloc] initWithSocketURL:url config:@{@"log": @YES,@"compress":@YES,@"reconnects":@YES,@"forceWebsockets":@YES,@"security":@YES}];
    socket = manager.defaultSocket;
    
    [socket once:@"connect" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@"connection established");
       
        [self addUserToChat];
    }];
    
    [socket connect];
    
}

-(void)addUserToChat{
    
    NSLog(@"doctor name......:%@",self.doctorName);
    NSLog(@"doctor roomId......:%@",self.selectedChat.roomId);
    NSLog(@"doctorPic ......:%@",self.doctorPic);
    NSLog(@"userType ......:%@",self.userType);
    NSLog(@"doctorId ......:%@",self.doctorId);

    [socket emit:@"adduser" with:@[self.doctorName,self.selectedChat.roomId,self.doctorPic,self.userType,self.doctorId]];
    
    [socket on:@"updatechat" callback:^(NSArray *textData, SocketAckEmitter * ack)
     {
         
         noApsLbl.hidden = YES;
         self.inputToolbar.hidden = NO;
         NSLog(@"updatechat method");
         [self addingMessageData:textData];
     }];
    [socket on:@"updatechat_image" callback:^(NSArray *textData, SocketAckEmitter * ack) {
        
        noApsLbl.hidden = YES;
        NSLog(@"media data:%@",textData);
        [self addingMessageData:textData];
        
        //[self addingMessageData:textData];
    }];
    [socket on:@"updatechat_PDF" callback:^(NSArray *textData, SocketAckEmitter * ack) {
        
        noApsLbl.hidden = YES;
        NSLog(@"pdf data:%@",textData);
        [self addingMessageData:textData];
        
        //[self addingMessageData:textData];
    }];
    if (self.isNewChat) {
        NSString *defaultMessage = [NSString stringWithFormat:@"Hi %@, This is Dr %@, How can i help you today? How are you? Note: This chat facility cannot be used in case if emergency, in case of emergency please visit nearest hospital",self.patientName,self.doctorName];
        NSDictionary *request = @{@"msg":defaultMessage,@"username":self.doctorName,@"userAvatar":self.doctorPic,@"hasMsg":@YES,@"hasFile":@NO,@"msgTime":@"",@"from_id":self.doctorId,@"room_name":self.roomName,@"to_id":self.patientId};
        [socket emit:@"sendchat" with:@[request]];
        
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.doctorId
                                                 senderDisplayName:self.doctorName
                                                              date:[NSDate date]
                                                              text:defaultMessage];
        
        [self.chatData.messages addObject:message];
        
        [self finishSendingMessageAnimated:YES];
    }
    
    
}
-(void)addingMessageData:(NSArray *)messages{
    
//    if (!isSetTitle) {
//        isSetTitle = YES;
//        self.title = [NSString stringWithFormat:@"Chat With %@",messages[0][@"username"]];
//    }
    self.showTypingIndicator = !self.showTypingIndicator;
   
    [self scrollToBottomAnimated:YES];
    
    for (NSDictionary *dict in messages) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            
           // [self makeRequestForSendingMessage:dict];
        });
        
        if ([dict[@"isclose"] integerValue] == 1) {
            [self closeSocketConnection];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
            self.uniqueId = dict[@"uniqueID"];

        
        if (dict[@"istype"] != nil) {
            [self addMediaMessage:dict];
        }else{
            
            self.patientProfilePic = dict[@"userAvatar"];
            
                if (self.chatData.avatars == nil) {
                    NSString *patientPic =self.selectedChat.patientProfilePic;
                    if ([self.selectedChat.patientProfilePic isEqualToString:@""]) {
                        patientPic = NO_IMAGE;
                    };
                    NSDictionary *avatharDict = @{@"avtharUrl":patientPic,@"senderId":self.patientId};
                    [avatharArr addObject:avatharDict];
                    self.chatData.avatars = [self.chatData addingAvathars:avatharArr];
                }
            JSQMessage *message = [[JSQMessage alloc] initWithSenderId:dict[@"from_id"] senderDisplayName:dict[@"username"] date:[NSDate date] text:dict[@"msg"]];
                
            if ([dict[@"from_id"] isEqualToString:self.doctorId]) {
                
                [self.chatData.messages removeLastObject];
                [self.chatData.messages addObject:message];

            }else {
                [self.chatData.messages addObject:message];

            }
           // //[self makeRequestForSendingMessage:dict];

        
        }
    }
    [self.collectionView reloadData];
    [self finishReceivingMessageAnimated:YES];

}
-(void)addMediaMessage:(NSDictionary *)mediaDict{
    
    NSString *filePath = @"doc";
    UIImage *image = [UIImage imageNamed:@"file"];
    NSString *mediaString= @"";
    if ([mediaDict[@"istype"] isEqualToString:@"image"]) {
        filePath= @"images";
         mediaString = [NSString stringWithFormat:@"%@%@/%@/%@",BaseUrl,mediaDict[@"dwid"],filePath,mediaDict[@"serverfilename"]];
        NSURL *mediaUrl = [NSURL URLWithString:mediaString];
        mediaString = [mediaString stringByAppendingString:[NSString stringWithFormat:@",image,%@",mediaDict[@"filename"]]];
        
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:mediaUrl]];
        
    }else {
         mediaString = [NSString stringWithFormat:@"%@%@/%@/%@",BaseUrl,mediaDict[@"username"],filePath,mediaDict[@"serverfilename"]];
 mediaString = [mediaString stringByAppendingString:[NSString stringWithFormat:@",pdf,%@",mediaDict[@"filename"]]];
    }
  
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
        photoItem.appliesMediaViewMaskAsOutgoing = NO;
       JSQMessage *message = [[JSQMessage alloc]initWithSenderId:mediaDict[@"from_id"] senderDisplayName:mediaDict[@"username"] mediaPath:mediaString date:[NSDate date] media:photoItem];
    
    [self.chatData.messages addObject:message];
    [self finishReceivingMessageAnimated:YES];
  // // [self makeRequestForSendingMessage:mediaDict];
//    if ([mediaDict[@"uid"] isEqualToString:self.patientId]) {
//        [self.chatData.messages removeLastObject];
//        [self.chatData.messages addObject:message];
//
//    }else {
//        [self.chatData.messages addObject:message];
//
//    }
    
        //[self.chatData.messages addObject:message];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Request Methods
-(void)makeRequestForClosingChat{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *bodyText = [NSString stringWithFormat:@"sessionid=%@&patid=%@&room_name=%@",sectionId,self.patientId,self.roomName];
    NSLog(@"body text......:%@",bodyText);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@dchat_close",WB_BASEURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    NSString *cokie = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
    if (cokie) {
        [request addValue:cokie forHTTPHeaderField:@"Cookie"];
    }
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];//multipart/form-data
    [request setHTTPBody:[[NSString stringWithFormat:@"%@",bodyText ] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        
        if (!error) {
            id temp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSLog(@"chat close......:%@",temp);
            
            dispatch_async(dispatch_get_main_queue(),^{
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                if ([temp[@"data"] integerValue] == 1) {
                    
                NSString *closeMsg = [NSString stringWithFormat:@"%@ has closed the chat now. If you want to chat again, re-initiate the chat once again.",self.doctorName];
                NSDictionary *request = @{@"msg":closeMsg,@"username":self.doctorName,@"userAvatar":self.doctorPic,@"hasMsg":@YES,@"hasFile":@NO,@"msgTime":@"",@"from_id":self.doctorId,@"room_name":self.roomName,@"to_id":self.patientId,@"isclose":@YES};
                [socket emit:@"sendchat" with:@[request]];
                
                JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.doctorId
                                                         senderDisplayName:self.doctorName
                                                                      date:[NSDate date]
                                                                      text:closeMsg];
                
                [self.chatData.messages addObject:message];
                }else {
                    NSString *some = [NSString stringWithFormat:@"%@ ,%@",temp[@"result"],temp[@"authorized"]];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"failure" message:some delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [alert show];
                }
                
            });
            
        }else {
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            [self showToast:@"Network not available"];
        }
    }];
    [dataTask resume];
}
-(void)makeRequestForChatHistory{
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];

    NSString *bodyText = [NSString stringWithFormat:@"sessionid=%@&patid=%@&room_name=%@",sectionId,self.selectedChat.patientId,self.roomName];
    NSLog(@"request body.......:%@",bodyText);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/dchat_history_details",WB_BASEURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    NSString *cokie = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
    if (cokie) {
        [request addValue:cokie forHTTPHeaderField:@"Cookie"];
    }

    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];//multipart/form-data
    [request setHTTPBody:[[NSString stringWithFormat:@"%@",bodyText ] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        

        if (!error) {
            
           dispatch_async(dispatch_get_main_queue(),^{
               
            id temp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
           
              NSLog(@"chat history details........:%@",temp);
        
            NSArray *dataArr = temp[0][@"data"];
            
            for (NSDictionary *dict in dataArr) {
                
               NSDate *date = [self dateConversion:dict[@"created"]];
                NSString *senderId = self.doctorId;
                NSString *patinetId = nil;
                NSString *senderName = self.doctorName;
                if (![dict[@"from_id"] isEqualToString:self.doctorId]) {
                   senderName = dict[@"patname"];
                    patinetId = dict[@"from_id"];
                    senderId = dict[@"from_id"];
                }else {
                    patinetId = dict[@"to_id"];

                }
                if ([dict[@"file_type"] isKindOfClass:[NSString class]]) {
                    [self addingMediaMessage:dict];
                }else {
                 JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:date text:dict[@"reply"]];
                
                if (self.chatData.avatars == nil) {
                    NSLog(@"avathars not found");
                    [avatharArr removeAllObjects];
                    
                    self.patientProfilePic = dict[@"patpic"];
                    self.doctorPic = dict[@"docpic"];
                    NSDictionary *avatharDict = @{@"avtharUrl":dict[@"patpic"],@"senderId":patinetId};
                    NSDictionary *avatharDict1 = @{@"avtharUrl":dict[@"docpic"],@"senderId":self.doctorId};
               
                    [avatharArr addObject:avatharDict];
                    [avatharArr addObject:avatharDict1];
                    NSLog(@"avathar arr.....:%@",avatharArr);
                    self.chatData.avatars = [self.chatData addingAvathars:avatharArr];

                }
                [self.chatData.messages addObject:message];
                }
                
            }
    
               NSLog(@"selected chat.....:%@",self.selectedChat.status);
                if ([self.selectedChat.status integerValue] == 2) {
                    self.inputToolbar.hidden = NO;
                }else {
                    self.inputToolbar.hidden = YES;

                }
                
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                [self.collectionView reloadData];
                if (self.chatData.messages.count) {
                    noApsLbl.hidden = YES;

                    [self scrollBottomToCollectionView];

                }else {
                    noApsLbl.hidden = NO;
                }
            });
        }else {
            dispatch_async(dispatch_get_main_queue(),^{

            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];

            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error" message:@"Network not available" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [controller addAction:okAction];
            [self presentViewController:controller animated:YES completion:nil];
            });
        }
    }];
    [dataTask resume];
}
-(void)makeRequestForSendingMessage:(NSDictionary *)messageDict{
    
    NSString *filePath = @"";
    NSString *filetype = @"";
    NSString *messageType = @"text";
    NSString *message = @"";
    NSString *isClose = @"";
    if ([messageDict[@"isclose"] integerValue] == 1 ) {
        isClose = @"1";
    }
    if (messageDict[@"istype"] !=nil) {
        
        filePath = messageDict[@"serverfilename"];
        
        messageType = @"file_upload";
        
        if ([messageDict[@"istype"] isEqualToString:@"image"]) {
            filetype = @"images";
        }else {
            filetype = @"doc";
        }

    }else {
        message = messageDict[@"msg"];
    }
    
    NSString *fromId = self.doctorId;
    NSString *toId = @"";
    if ([messageDict[@"from_id"] isEqualToString:self.doctorId]) {
        toId = messageDict[@"to_id"];
    }else {
        fromId = messageDict[@"from_id"];
        toId =self.doctorId;

    }
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *bodyText = [NSString stringWithFormat:@"sessionid=%@&to_id=%@&room_name=%@&from_id=%@&msg=%@&filepath=%@&filetype=%@&msg_type=%@&uniqueID=%@&isclose=%@",sectionId,toId,self.roomName,fromId,message,filePath,filetype,messageType,self.uniqueId,isClose];
    NSLog(@"request body.......:%@",bodyText);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@dadd_chat_history",WB_BASEURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    NSString *cokie = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
    if (cokie) {
        [request addValue:cokie forHTTPHeaderField:@"Cookie"];
    }
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];//multipart/form-data
    [request setHTTPBody:[[NSString stringWithFormat:@"%@",bodyText ] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(),^{
                
                id temp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                NSLog(@"sending message........:%@",temp);
            });
        }else {
            dispatch_async(dispatch_get_main_queue(),^{
                
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                
                UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error" message:@"Network not available" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [controller addAction:okAction];
                [self presentViewController:controller animated:YES completion:nil];
            });
        }
    }];
    [dataTask resume];
}
-(void)addingMediaMessage:(NSDictionary *)mediaDict{
    
    NSString *senderId = self.doctorId;
    NSString *senderName = self.doctorName;
    if ([mediaDict[@"from_id"] isEqualToString:self.doctorId]) {
        senderName = mediaDict[@"patname"];
        senderId = mediaDict[@"from_id"];
    }
    NSString *filePath = @"doc";
   
    UIImage *image = [UIImage imageNamed:@"file"];
    NSString *mediaString = @"";
    if (![mediaDict[@"file_type"] isEqualToString:@"doc"]) {
        filePath = @"images";
        mediaString = [NSString stringWithFormat:@"%@%@/%@/%@",BaseUrl,mediaDict[@"patname"],filePath,mediaDict[@"filepath"]];
        NSURL *mediaUrl = [NSURL URLWithString:mediaString];
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:mediaUrl]];
        mediaString = [mediaString stringByAppendingString:[NSString stringWithFormat:@",image,%@",mediaDict[@"filepath"]]];
    }else {
        mediaString = [NSString stringWithFormat:@"%@%@/%@/%@",BaseUrl,self.patientName,filePath,mediaDict[@"filepath"]];
        mediaString = [mediaString stringByAppendingString:[NSString stringWithFormat:@",pdf,%@",mediaDict[@"filepath"]]];

    }
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
    photoItem.appliesMediaViewMaskAsOutgoing = NO;
    JSQMessage *message = [[JSQMessage alloc]initWithSenderId:senderId senderDisplayName:senderName mediaPath:mediaString date:[NSDate date] media:photoItem];
    [self.chatData.messages addObject:message];

}
-(NSDate *)dateConversion:(NSString *)dateStr{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd MMM yy h:mm a"];
    NSDate *date = [formatter dateFromString:dateStr];
   
    
    if (date == nil) {
        
        NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"];
        
        [formatter setDateFormat:@"dd MMM yy hh:mm a"];
        
        [formatter setLocale:locale];
        date = [formatter dateFromString:dateStr];
        
        
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *datee = [formatter stringFromDate:date];
        
        date = [formatter dateFromString:datee];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
        [formatter setLocale:locale];
        datee = [formatter stringFromDate:date];

        return [formatter dateFromString:datee];
        

    }
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm a"];

    formatter.formatterBehavior = NSDateFormatterBehaviorDefault;
    NSString *datee = [formatter stringFromDate:date];
    NSDate *converted = [formatter dateFromString:datee];

    return converted;
}
-(void)scrollBottomToCollectionView
{
    NSInteger item = [self collectionView:self.collectionView numberOfItemsInSection:0] - 1;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:0];
    //NSLog(@"last indexpath.......:%ld",(long)lastIndexPath.row);
    [self.collectionView
         scrollToItemAtIndexPath:lastIndexPath
         atScrollPosition:UICollectionViewScrollPositionBottom
         animated:NO];
    [self scrollToBottomAnimated:NO];

    
}

#pragma mark - Action Methods

-(void)closeSocketConnection{
    
    [socket disconnect];
    socket = nil;
    manager = nil;
    
}
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)closeChat:(id)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:@"Do you want to close the chat." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self makeRequestForClosingChat];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:nil];
    
    [controller addAction:okAction];
    [controller addAction:cancelAction];
    controller.preferredAction = okAction;
    [self presentViewController:controller animated:YES completion:nil];
    controller.view.tintColor = [UIColor blueColor];

}
#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
   
    
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if (![networkAvailabilityCheck reachable])
    {
        [self showToast:@"Cannot reach server, please check your internet connection"];
        return;
    }
    
    
    
    if (self.chatData.messages.count) {
        
  //uid= from_id
        //patid = to_id
    //NSDictionary *request = @{@"msg":text,@"username":self.doctorName,@"userAvatar":self.doctorPic,@"hasMsg":@YES,@"hasFile":@NO,@"msgTime":@"",@"uid":self.doctorId,@"room_name":self.roomName,@"patid":self.patientId};
        NSDictionary *request = @{@"msg":text,@"username":self.doctorName,@"userAvatar":self.doctorPic,@"hasMsg":@YES,@"hasFile":@NO,@"msgTime":@"",@"from_id":self.doctorId,@"room_name":self.roomName,@"to_id":self.patientId};

        
    [socket emit:@"sendchat" with:@[request]];

     JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];

    [self.chatData.messages addObject:message];

    [self finishSendingMessageAnimated:YES];
    }else {
        [self clickOnEmptyPage];
    }
    
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Media messages", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Camera", nil), NSLocalizedString(@"Gallery",  nil),NSLocalizedString(@"Documents", nil), nil];
    [sheet showFromToolbar:self.inputToolbar];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            [self takePhoto];
            break;
            
        case 1:
        {
            [self checkPhotoLibraryPermissions];
        }
            break;
            
        case 2:
            [self openDocument];
            break;
            
        case 3:
            [self.chatData addVideoMediaMessageWithThumbnail];
            break;
            
        case 4:
            [self.chatData addAudioMediaMessage];
            break;
    }
    isMoving = YES;
    // [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated:YES];
}
- (void)takePhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    dispatch_async(dispatch_get_main_queue(),^{
        [self presentViewController:picker animated:YES completion:NULL];

    });
}
-(void)openGallary{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    dispatch_async(dispatch_get_main_queue(),^{
        [self presentViewController:picker animated:YES completion:NULL];
     });
}
-(void)checkPhotoLibraryPermissions{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        [self openGallary];
        
    }
    
    else if (status == PHAuthorizationStatusDenied) {
        [self requestingPhotoPermissions];
        
    }
   else  if (status == PHAuthorizationStatusNotDetermined) {
       [self requestingPhotoPermissions];
       
    }else {
        [self openGallary];
            
      
    }
    
}
-(void)requestingPhotoPermissions{
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
        if (status == PHAuthorizationStatusAuthorized) {
            
            [self openGallary];
            
        }
        else {
            return ;
        }
    }];
}
#pragma mark - JSQMessages CollectionView DataSource

- (NSString *)senderId {
    return self.doctorId;
}

- (NSString *)senderDisplayName {
    return self.doctorName;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.chatData.messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.chatData.messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.chatData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.chatData.outgoingBubbleImageData;
    }
    
    return self.chatData.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.chatData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        if (![NSUserDefaults outgoingAvatarSetting]) {
            return nil;
        }
    }
    else {
        if (![NSUserDefaults incomingAvatarSetting]) {
            return nil;
        }
    }
    
    
    return [self.chatData.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.chatData.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.chatData.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.chatData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.chatData.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    cell.accessoryButton.hidden = ![self shouldShowAccessoryButtonForMessage:msg];
    
    return cell;
}

- (BOOL)shouldShowAccessoryButtonForMessage:(id<JSQMessageData>)message
{
    return ([message isMediaMessage] && [NSUserDefaults accessoryButtonForMediaMessages]);
}


#pragma mark - UICollectionView Delegate

#pragma mark - Custom menu items

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        return YES;
    }
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        [self customAction:sender];
        return;
    }
    
    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)customAction:(id)sender
{
    NSLog(@"Custom action received! Sender: %@", sender);
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Custom Action", nil)
                                message:nil
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil]
     show];
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.chatData.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
    
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
    dispatch_async(dispatch_get_main_queue(),^{
        [self.inputToolbar.contentView.textView resignFirstResponder];
        
    });
    JSQMessage *message = self.chatData.messages[indexPath.row];
    NSLog(@"avathar url:%@",message.mediaPath);

    if ([message.mediaPath isEqualToString:@""]) {
        return;
    }
    NSArray *urlArr = [message.mediaPath componentsSeparatedByString:@","];
    NSLog(@"avathar url:%@",urlArr);
   
    if ([urlArr[1] isEqualToString:@"image"]) {
        isImage = YES;
        isMoving = YES;
        [self performSegueWithIdentifier:@"imageShowVc" sender:urlArr[0]];
    }else if ([urlArr[1] isEqualToString:@"pdf"]){
        [self saveFilesInLocalDirectory:urlArr];
        //[self openFile:urlArr[0]];
    }

}
-(void)saveFilesInLocalDirectory:(NSArray *)urlArr
{
    
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[@"file." stringByAppendingString:urlArr[2]]];
   // BOOL okYEs = [[NSFileManager defaultManager] removeItemAtPath:dataPath error:nil];
//    if (okYEs) {
//        NSLog(@"deletetion success");
//
//        return;
//    }else {
//        NSLog(@"deletetion failure");
//       // return;
//    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
        NSLog(@"folder not avaible");

        //[[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
        [self openDocumentFromLocalPath:dataPath fileUrl:urlArr[0]];
        
    }else {
        
       // [self openDocumentFromLocalPath:dataPath fileUrl:urlArr[0]];
        NSLog(@"folder  avaible");

        
        _pdfPath = dataPath;
        
        BOOL success = [QLPreviewController canPreviewItem:[NSURL URLWithString:_pdfPath]];
        if (success) {
            [self openDocumentUsingQlPreview];

        } else {
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            
            pdfSuccess = NO;
            [self imageZooming:urlArr[0]];
            
        }
        
        }
       // NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlArr[0]]];
        //[urlData writeToFile:filePath atomically:YES];
        
    
}
-(void)openDocumentFromLocalPath:(NSString *)filePath fileUrl:(NSString *)urlStr{
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSString *escapedString = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"url......:%@",urlStr);
    NSLog(@"filepath......:%@",filePath);

    NSURL *url = [NSURL URLWithString:escapedString];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(),^{
                
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];

                _pdfPath = filePath;

                [data writeToFile:_pdfPath atomically:YES];
        
                BOOL success = [QLPreviewController canPreviewItem:[NSURL URLWithString:_pdfPath]];
                if (success) {
                    [self openDocumentUsingQlPreview];
                } else {
                    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                    
                    pdfSuccess = NO;
                    [self imageZooming:urlStr];
                    
                }
                
            });
        }
    }] ;
    [task resume];
   

}
-(void)openDocumentUsingQlPreview{
    QLPreviewController *previewer = [[QLPreviewController alloc] init];
    [previewer setDataSource:self];
    previewer.title = @"";
    [previewer setCurrentPreviewItemIndex:0];
    previewer.view.tintColor = [UIColor blueColor];
    isMoving = YES;
    [[self navigationController] presentViewController:previewer animated:YES completion:^{
        pdfSuccess = NO;
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
    }];
}
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    [self.inputToolbar.contentView.textView resignFirstResponder];

    //[self closeKeyBoard];
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
    
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods

- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                         mediaPath:@""
                                                              date:[NSDate date]
                                                             media:item];
        [self.chatData.messages addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}

#pragma mark - JSQMessagesViewAccessoryDelegate methods

- (void)messageView:(JSQMessagesCollectionView *)view didTapAccessoryButtonAtIndexPath:(NSIndexPath *)path
{
    NSLog(@"Tapped accessory button!");
}
#pragma mark - ImagePicker Delegate Methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    selectedImageUrl = info[@"UIImagePickerControllerReferenceURL"];
    isPdfSelected = NO;
    NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    [self compression:info[UIImagePickerControllerOriginalImage]];

    if (@available(iOS 11.0, *)) {
        PHAsset *phDict = [info valueForKey:UIImagePickerControllerPHAsset];
        
        if (phDict != nil) {
            NSArray *resources = [PHAssetResource assetResourcesForAsset:phDict];
            imageName = ((PHAssetResource*)resources[0]).originalFilename;
            [self uploadImage];

        }else {
        
            [self getImageNameFromCamera:info];
       }
    }else {
           
        if(refURL != nil){
            [self getImageNameFromGallery:refURL];
        }else {
            [self getImageNameFromCamera:info];

        }
    
    }
    
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
-(void)getImageNameFromGallery:(NSURL *)refURL{
    PHFetchResult *asset = [PHAsset fetchAssetsWithALAssetURLs:@[refURL] options:nil];
    
    PHAsset *dict = asset.firstObject;
    
    NSArray *resources = [PHAssetResource assetResourcesForAsset:dict];
 
    imageName = ((PHAssetResource*)resources[0]).originalFilename;
    [self uploadImage];

    
}
-(void)getImageNameFromCamera:(NSDictionary *)info{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSData *imageData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage],0.9);
    
    UIImage *image = [UIImage imageWithData:imageData];
    
    
    __block NSString* localId;
    
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        localId = [[assetChangeRequest placeholderForCreatedAsset] localIdentifier];
        
        
        
    } completionHandler:^(BOOL success, NSError *error) {
        
        if (!success) {
            
            NSLog(@"Error creating asset: %@", error);
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(),^{
                
                
                PHFetchResult* assetResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil];
                
                PHAsset *asset = [assetResult firstObject];
                
                NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
                
                imageName = ((PHAssetResource*)resources[0]).originalFilename;
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];

                [self uploadImage];
                
                
            });
            
            
        }
        
    }];
    
    
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)uploadImage{
    
    NSString *isType = @"image";
    if (isPdfSelected) {
        isType = @"PDF";
    }
    
    NSString *imagePathDwig = [NSString stringWithFormat:@"%@/%@",CHAT_URL,selectedImageUrl];
    NSDate *date = [NSDate date];
    NSTimeInterval ti = [date timeIntervalSince1970];
    NSString *dwid = [NSString stringWithFormat:@"%@dwid%f",self.patientName,ti];
    NSLog(@"image name.....:%@",imageName);
    NSLog(@"image name.....:%@",self.patientName);
    NSLog(@"image name.....:%@",self.patientProfilePic);

    NSDictionary *uploadDict = @{
                                 @"username":self.doctorName,
                                 @"userAvatar":self.doctorPic,
                                 @"hasFile":@YES,
                                 @"isImageFile":@YES,
                                 @"istype":isType,
                                 @"showme":@YES,
                                 @"dwimgsrc":imagePathDwig,
                                 @"dwid":dwid,
                                 @"msgTime":[NSDate date],
                                 @"filename":imageName,
                                 @"room_name":self.roomName,
                                 @"to_id":self.patientId,
                                 @"from_id":self.doctorId
                                 };
    NSLog(@"upload dictionary......:%@",uploadDict);
    [self uploadingImageToServer:uploadDict];
    
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
    
    
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:imageData]];
    photoItem.appliesMediaViewMaskAsOutgoing = NO;
    JSQMessage *message = [[JSQMessage alloc]initWithSenderId:self.patientId senderDisplayName:self.patientName mediaPath:@"" date:[NSDate date] media:photoItem];
    //[self.chatData.messages addObject:message];
    //[self finishSendingMessageAnimated:YES];

    //display image
    UIImage *img = [UIImage imageWithData:imageData];
    selectedImage =[UIImage imageWithData:imageData];
}
-(void)uploadingImageToServer:(NSDictionary *)info{
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSLog(@"image dict .........:%@",info);
    isMoving = NO;
 
    NSString *boundary = @"----WebKitFormBoundary7MA4YWxkTrZu0gW";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    
    
    CGSize newSize = CGSizeMake(320.0f, 480.0f);
    UIGraphicsBeginImageContext(newSize);
    [selectedImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage;
    if (selectedImage != nil)
    {
        NSLog(@"image is selected");
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    
    UIGraphicsEndImageContext();
    
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:CHAT_URL]];

    UIImage *image =newImage;
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSString *strUrl=[NSString stringWithFormat:@"%@/v1/uploadImage",CHAT_URL];
    if (isPdfSelected) {
         strUrl = [NSString stringWithFormat:@"%@/v1/uploadPDF",CHAT_URL];
    }
    
    AFHTTPRequestOperation * op = [manager POST:strUrl parameters:info constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        if (isPdfSelected) {
            [formData appendPartWithFileData:documentData name:@"file" fileName:imageName mimeType:@"application/pdf"];
        }else{
        if ([imageData length] > 0)
        {
            int r = arc4random_uniform(999999999);
            [formData appendPartWithFileData:imageData name:@"file" fileName:imageName mimeType:@"image"];
        }
        }
        [manager.requestSerializer setTimeoutInterval:30.0];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
       
            dispatch_async(dispatch_get_main_queue(), ^{
                //NSLog(@"response.......:%@",responseObject);
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];

                self.view.userInteractionEnabled = YES;
                documentData = nil;
                imageName = nil;
                selectedImage = nil;
                selectedImageUrl = nil;
                isPdfSelected = NO;
                [socket emit:@"sendchat" with:@[responseObject]];
            });
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{

        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];

       // NSLog(@"Error uploading image: %@ ***** %@", operation.responseString, error);
        [self showToast:@"Cannot reach server, please check your internet connection"];
        });


    }];
    
   
    [op start];
}
#pragma mark - Document Delegate Methods
-(void)openDocument{
    UIDocumentPickerViewController *pickerController = [[UIDocumentPickerViewController alloc]initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
    //    UIDocumentMenuViewController *contrller = [[UIDocumentMenuViewController alloc]initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
}
//- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker{
//    documentPicker.delegate = self;
//}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    selectedImageUrl = [url absoluteString];
    imageName = [url lastPathComponent];
    isPdfSelected = YES;
    documentData = [[NSData alloc]initWithContentsOfURL:url];
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageNamed:@"file"]];
    photoItem.appliesMediaViewMaskAsOutgoing = NO;
    JSQMessage *message = [[JSQMessage alloc]initWithSenderId:self.patientId senderDisplayName:self.patientName mediaPath:@"" date:[NSDate date] media:photoItem];
    //[self.chatData.messages addObject:message];
    //[self finishSendingMessageAnimated:YES];
    [self uploadImage];
    
}
-(void)imageZooming:(NSString *)filePath{
    isImage = NO;
    isMoving = YES;
    [self performSegueWithIdentifier:@"imageShowVc" sender:filePath];

}
#pragma mark - Qlpreview
-(void)openFile:(NSString *)strFilePath{
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSURL *url = [NSURL URLWithString:strFilePath];
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
            isMoving = YES;
            [[self navigationController] presentViewController:previewer animated:YES completion:^{
                pdfSuccess = NO;
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];

            }];
        } else {
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];

            pdfSuccess = NO;
            [self imageZooming:strFilePath];
            
        }
    }];
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    
    CustomPreViewItem *item =
    [[CustomPreViewItem alloc] initPreviewURL:[NSURL fileURLWithPath:_pdfPath]
                              WithTitle:@""];
    return item;
}

-(void)previewControllerWillDismiss:(QLPreviewController *)controller{
    
    NSError *error;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL success = [fileManager removeItemAtPath:_pdfPath error:&error];
//    if (success) {
//        NSLog(@"deleted file");
//    }
//    else
//    {
//        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
//    }
}
#pragma mark - Toast

-(void)showToast:(NSString *)message{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:okAction];
    [self presentViewController:controller animated:YES completion:nil];
    controller.view.tintColor = [UIColor blueColor];
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//    hud.mode = MBProgressHUDModeText;
//    hud.labelText = message;
//    hud.labelFont = [UIFont systemFontOfSize:10];
//    hud.margin = 10.f;
//   // hud.yOffset = 150.f;
//    hud.minShowTime = 2.0;
//    hud.removeFromSuperViewOnHide = YES;
//    hud.animationType = MBProgressHUDAnimationFade;
//    [hud hide:YES afterDelay:5.0];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"imageShowVc"]) {

        MediaVC *controller = segue.destinationViewController;
        if (isImage) {
            controller.strImage = sender;
        }else{
            controller.webUrl = sender;
        }
    }
}


@end
