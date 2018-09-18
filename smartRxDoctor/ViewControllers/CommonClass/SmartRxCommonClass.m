//
//  SmartRxCommonClass.m
//  SmartRx
//
//  Created by Manju Basha on 04/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "SmartRxCommonClass.h"
#import "NSString+MD5.h"
#define kLogoutAlertTag 80


@implementation SmartRxCommonClass


+ (id)sharedManager {
    static SmartRxCommonClass *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(void)openGallary:(UIViewController *)controller{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = (id)self;
    self.imageDelegate = (id)controller;
    [controller presentViewController:picker animated:YES completion:nil];
}


#pragma mark - ImagePicker Delegate Methods

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.imageDelegate imageSelected:[info objectForKey:UIImagePickerControllerOriginalImage]];
    [picker dismissViewControllerAnimated:YES completion:nil];
    //getting image name when selected
    /*NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
     ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
     {
     ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
     NSLog(@"[imageRep filename] : %@", [imageRep filename]);
     };
     ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
     [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
     */
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Make Request to server

-(void)postOrGetData:(NSString *)UrlString postPar:(id )postParaDict method:(NSString *)methodType setHeader:(BOOL)header  successHandler:(void(^)(id response))successHandler failureHandler:(void(^)(id response))failureHandler{
    NSURL *url = [NSURL URLWithString:UrlString];

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:methodType];
    if (header) {
        [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"session_id"] forHTTPHeaderField:@"session_id"];
    }
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];//multipart/form-data
    
    if ([methodType isEqualToString:@"POST"])
    {
      
        [request setHTTPBody:[[NSString stringWithFormat:@"%@",postParaDict ] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    NSString *cokie = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
    if (cokie) {
        [request addValue:cokie forHTTPHeaderField:@"Cookie"];
    }
    

    request.timeoutInterval=30;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        NSDictionary *fields = [HTTPResponse allHeaderFields];
        
        NSString *cookie = [fields valueForKey:@"Set-Cookie"];
        if (cookie) {
            [[NSUserDefaults standardUserDefaults] setObject:cookie forKey:@"cookie"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if (!connectionError) {
            
            id responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([responseData isKindOfClass:[NSDictionary class]] && [responseData objectForKey:@"error"]) {
                failureHandler(responseData);
                return;
            }
            successHandler(responseData);
        }else{
            failureHandler(connectionError);
        }
    }];
}

-(NSString *)urlenc:(NSString *)val
{
    CFStringRef safeString =
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef)val,
                                            NULL,
                                            CFSTR("/%&=?$#+-~@<>|\*,.()[]{}^!"),
                                            kCFStringEncodingUTF8);
    return [NSString stringWithFormat:@"%@", safeString];
}

-(void)makeLoginRequest
{
    NSString *strPasword=[[NSUserDefaults standardUserDefaults]objectForKey:@"Password"];
     NSString *strMobileNum=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobileNumber"];
    NSString *cid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    
    if ([strPasword length] > 0)
    {
        //strPasword=[NSString md5:strPasword];
    }
    if (strPasword && [strMobileNum length] > 0)
    {
        
        NSData *data = [[NSUserDefaults standardUserDefaults] valueForKey:@"PushToken"];
        NSString *strPushToken = [[[data description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        
        NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"mobile",strMobileNum];
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"cid",cid]];
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"pass",strPasword]];
         bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"regId",strPushToken]];
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"mode",@"2"]];
        NSString *url=[NSString stringWithFormat:@"%@/%@",WB_BASEURL,@"dlogin"];
        [self postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
            NSLog(@"sucess 11 %@",response);
            //[[response objectForKey:@"authorized"]integerValue] == 0 || [[response objectForKey:@"result"] integerValue] == 0 || ([[response objectForKey:@"sessionid"] integerValue] == 0)
            
            if ([response isKindOfClass:[NSArray class]])
            {
                [self.loginDelegate performSelectorOnMainThread:@selector(logOutId:) withObject:nil waitUntilDone:YES];
            }
            else{
                NSLog(@"section idd ==== %@",[response objectForKey:@"sessionid"]);
                [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"sessionid"] forKey:@"sessionid"];
                [[NSUserDefaults standardUserDefaults]setObject:cid forKey:@"cid"];
//                [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"hosname"] forKey:@"HosName"];
                [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"dispname"] forKey:@"UserName"];
                [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"session_name"] forKey:@"SessionName"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [self.loginDelegate performSelectorOnMainThread:@selector(sectionIdGenerated:) withObject:nil waitUntilDone:YES];
            }
        } failureHandler:^(id response) {
           [self.loginDelegate performSelectorOnMainThread:@selector(sectionIdGenerated:) withObject:nil waitUntilDone:YES];
        }];
    }
}

//Dummy code for testing


-(void)postingImageWithText:(NSString *)urlString postData:(id)postParaDict camImg:(UIImage *)img successHandler:(void(^)(id response))successHandler failureHandler:(void(^)(id response))failureHandler
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];

     NSString *boundary =@"0x0hHai1CanHazB0undar135";
    NSString *BoundaryConstant =@"----------V2ymHFg03ehbqgZCaKO6jy";
    
    NSString *contentType = [NSString stringWithFormat:@"application/x-www-form-urlencoded; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in postParaDict) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [postParaDict objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(img, 1.0);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", @"patientfile[]"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            id responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([responseData isKindOfClass:[NSDictionary class]] && [responseData objectForKey:@"error"]) {
                failureHandler(responseData);
                return;
            }
            successHandler(responseData);
        }else{
            failureHandler(connectionError);
        }
    }];
}

#pragma mark - Navigation Title adjestment
-(void)setNavigationTitle:(NSString *)title controler:(UIViewController *)controller
{
    if ([title length] <= 20)
    {
        controller.title = title;
        UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 250, 40)];
        tlabel.text=controller.navigationItem.title;
        tlabel.textColor=[UIColor blackColor];
        tlabel.textAlignment=NSTextAlignmentCenter;
        tlabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 14.0];
        tlabel.numberOfLines = 10;
        tlabel.backgroundColor =[UIColor clearColor];
        tlabel.adjustsFontSizeToFitWidth=YES;
        controller.navigationItem.titleView=tlabel;
    }
    else
    {
        controller.title = title;
        UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 250, 40)];
        tlabel.text=controller.navigationItem.title;
        tlabel.textColor=[UIColor blackColor];
        tlabel.textAlignment=NSTextAlignmentCenter;
        tlabel.numberOfLines = 10;
        tlabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
        tlabel.backgroundColor =[UIColor clearColor];
//        tlabel.adjustsFontSizeToFitWidth=YES;
        controller.navigationItem.titleView=tlabel;
        
    }
}

@end
