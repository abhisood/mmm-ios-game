//
//  ShareViewController.m
//  moneky
//
//  Created by Sood, Abhishek on 1/5/13.
//
//

#import "ShareViewController.h"
#import <Social/Social.h>
#import "MonkeyClientData.h"
#import "Flurry.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

@synthesize imageView, image, text;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
        self.title = @"Share your Score!";
    }
    return self;
}

-(void)done{
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    NSAssert(self.imageView != nil, @"imageview is nil");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.imageView.image = self.image;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    Class shareClass = (NSClassFromString(@"SLComposeViewController"));
    if (shareClass) {
        if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook] &&
            ![SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo] &&
            ![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            
            SLComposeViewController* slvc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            slvc.completionHandler = ^(SLComposeViewControllerResult result){
                if (result == SLComposeViewControllerResultDone) {
                    [self sendFluryShareCompletionEvent:UIActivityTypePostToFacebook];
                }
            };
            NSString* shareText = [NSString stringWithFormat:@"%@\n%@",self.text,MonkeyGameURL];
            [slvc setInitialText:shareText];
            [slvc addImage:self.image];
            [self presentModalViewController:slvc animated:YES];
        }
    }
    
    NSDictionary* dict = @{@"text" : self.text};
    [Flurry logEvent:@"Share screen shown" withParameters:dict];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)shareContent:(id)sender{
    NSString* shareText = [NSString stringWithFormat:@"%@\n%@",self.text,MonkeyGameURL];
    NSArray* items = [NSArray arrayWithObjects:shareText,self.image , nil];
    UIActivityViewController* vc = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    vc.excludedActivityTypes = [NSArray arrayWithObjects:UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeMessage, nil];
    
    vc.completionHandler = ^(NSString *activityType, BOOL completed){
        if (completed) {
            [self sendFluryShareCompletionEvent:activityType];
            if (activityType == UIActivityTypePostToFacebook) {
                [self showAlert:@"Facebook"];
            }else if (activityType == UIActivityTypePostToTwitter){
                [self showAlert:@"Twitter"];
            }
            else if (activityType == UIActivityTypePostToWeibo){
                [self showAlert:@"Sina Weibo"];
            }
        }
    };
    
    [self presentModalViewController:vc animated:YES];
    [vc release];
}

-(void)sendFluryShareCompletionEvent:(NSString*)activityType{
    NSDictionary* dict = @{@"text" : self.text,@"ShareType":activityType};
    [Flurry logEvent:@"Share Completed" withParameters:dict];
}

-(void)showAlert:(NSString*)service{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    alert.message = [NSString stringWithFormat:@"Posted successfully to %@",service];
    [alert show];
    [alert release];
}

-(void)dealloc{
    self.imageView = nil;
    self.image = nil;
    self.text = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark scrollview delegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

@end
