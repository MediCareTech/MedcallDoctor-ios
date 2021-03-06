//
//  SmartRxReportImageVC.m
//  SmartRx
//
//  Created by PaceWisdom on 25/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxReportImageVC.h"
#import "UIImageView+WebCache.h"

@interface SmartRxReportImageVC ()
{
    MBProgressHUD *HUD;
    CGFloat lastScale;
}

@end

@implementation SmartRxReportImageVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    self.webView.scalesPageToFit=YES;
    if (self.webUrl !=nil) {
        self.scrollView.hidden = YES;
        [self.scrollView removeFromSuperview];
        self.webView.scalesPageToFit=YES;
        self.webView.delegate = self;
        //NSString *urlStr = [NSString stringWithFormat:@"%s/%@",kBaseUrlQAImg,self.webUrl];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGE_URL,self.webUrl]]]];
    } else {
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            //bg_contact
        });

    if ([self.strImage rangeOfString:@"patient"].location != NSNotFound) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGE_URL,self.strImage]];
        [self.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            dispatch_async(dispatch_get_main_queue(),^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            });
            if (error) {
                [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Unsupported Format" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }else
                self.imageView .image = image;
            
        }];
    }
    else{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGE_URL,self.strImage]];
        [self.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"bg_contact"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            dispatch_async(dispatch_get_main_queue(),^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            });
            if (error) {
                [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Unsupported Format!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            else
                self.imageView.image = image;
        }];
    }
    [HUD hide:YES];
    [HUD removeFromSuperview];
    }

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	[HUD show:YES];
}

#pragma mark - Webview Delegate
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
}

- (IBAction)dismissBtnClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint
{
    CGRect vf = view.frame;
    CGPoint co = self.scrollView.contentOffset;
    
    CGFloat x = centerPoint.x - vf.size.width / 2.0;
    CGFloat y = centerPoint.y - vf.size.height / 2.0;
    
    if(x < 0)
    {
        co.x = -x;
        vf.origin.x = 0.0;
    }
    else
    {
        vf.origin.x = x;
    }
    if(y < 0)
    {
        co.y = -y;
        vf.origin.y = 0.0;
    }
    else
    {
        vf.origin.y = y;
    }
    
    view.frame = vf;
    self.scrollView.contentOffset = co;
}

// MARK: - UIScrollViewDelegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return  self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)sv
{
    UIView* zoomView = [sv.delegate viewForZoomingInScrollView:sv];
    CGRect zvf = zoomView.frame;
    if(zvf.size.width < sv.bounds.size.width)
    {
        zvf.origin.x = (sv.bounds.size.width - zvf.size.width) / 2.0;
    }
    else
    {
        zvf.origin.x = 0.0;
    }
    if(zvf.size.height < sv.bounds.size.height)
    {
        zvf.origin.y = (sv.bounds.size.height - zvf.size.height) / 2.0;
    }
    else
    {
        zvf.origin.y = 0.0;
    }
    zoomView.frame = zvf;
}

@end
