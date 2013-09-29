//
//  CPRViewController.m
//  Composer
//
//  Created by chat on 29.09.13.
//  Copyright (c) 2013 Chat Wacharamanotham. All rights reserved.
//
#import <MessageUI/MessageUI.h>
#import "ALAlertBanner.h"

#import "CPRViewController.h"

@interface CPRViewController () <
    MFMailComposeViewControllerDelegate,
    UINavigationControllerDelegate>

@property (copy) NSString *composingResult;
@property (assign) MFMailComposeResult mailResult;
@property (assign) BOOL pendingResult;
@end

@implementation CPRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pendingResult = NO;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
        if ([MFMailComposeViewController canSendMail])
        {
            [self displayMailComposerSheet];
        }
    }];
}

- (void)displayMailComposerSheet
{
    // create the compose view controller
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
    
    // get string from the pasteboard
    NSString *messageBody;
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        if ([pasteboard containsPasteboardTypes: [NSArray arrayWithObject:@"public.utf8-plain-text"]])
        {
            messageBody = pasteboard.string;
        }
    }
    
    // set message body
    [picker setMessageBody:messageBody isHTML:NO];
	
    // present the compose sheet
	[self presentViewController:picker animated:YES completion:^()
     {
         [self showResultBannerOnView:picker.view];
     }];
    
    
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    self.pendingResult = YES;
    self.mailResult = result;
    
    // hide the sending sheet
    [self dismissViewControllerAnimated:YES completion:^()
     {
         [self displayMailComposerSheet];
   
     }];
}

- (void)showResultBannerOnView:(UIView *)theView;
{
    if (self.pendingResult == NO)
    {
        return;
    }
    
    NSString *composingResult = @"Mail sending failed. :(";
    ALAlertBannerStyle bannerStyle = ALAlertBannerStyleFailure;
    NSTimeInterval secondsToShow = 3.0;
    switch (self.mailResult)
    {
        case MFMailComposeResultSaved:
            composingResult = @"Draft saved!";
            bannerStyle = ALAlertBannerStyleNotify;
            secondsToShow = 1.0;
            break;
        case MFMailComposeResultSent:
            composingResult = @"Mail sent!";
            bannerStyle = ALAlertBannerStyleSuccess;
            secondsToShow = 1.0;
            break;
        case MFMailComposeResultCancelled:
            composingResult = @"Draft deleted!";
            bannerStyle = ALAlertBannerStyleNotify;
            secondsToShow = 1.0;
            break;
        case MFMailComposeResultFailed:
        default:
            break;
    }
    
    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:theView
                                                        style:bannerStyle
                                                     position:ALAlertBannerPositionBottom
                                                        title:composingResult
                                                     subtitle:nil];
    banner.secondsToShow = secondsToShow;
    [banner show];
    self.pendingResult = NO;
}

@end
