/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  MainViewController.h
//  hello
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

//macro to trim strings left and right
#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]

#import "MainViewController.h"

@implementation MainViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self customInitialization];
    }
    return self;
}

-(void) customInitialization
{
    
    //Navigation
    self.title = @"";
    [self.navigationController.navigationBar setTranslucent:NO];
    //[self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [[self navigationController] popViewControllerAnimated:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    //we create the navigationbar here, because you have anyway to recreate the navigationbar
    //if you want to change items icons or selectors
    [self createNavigationBarAndToggleRefreshAndStopButton:YES];
    
}
- (void) didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
/*
 *disable copying text from webview
 */
BOOL _copyCutAndPasteEnabled =NO;
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:) ||
        action == @selector(paste:)||
        action == @selector(cut:))
    {
        return _copyCutAndPasteEnabled;
    }
    return [super canPerformAction:action withSender:sender];
}
//show startpage
-(IBAction)homePage:(id)sender{
    
    NSLog(@"Home pressed");
    [self dismissModalViewControllerAnimated:YES];
    NSString* startFilePath = [self pathForResource:self.startPage];
    NSURL* appURL = [NSURL fileURLWithPath:startFilePath];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:appURL];
    [self.webView loadRequest:requestObj];
    
}
//reload current page
-(IBAction)refreshPage:(id)sender {
    
    //obtaining webviews current url in many different ways
    //
    //1) clean javascript return value, clearly usable and works well, even on local paths
    NSString *currentURL=[self.webView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    //2) this prepends (only) on index.html a load of unrecognizable characters and makes the return value unusable
    //NSString *currentURL=self.webView.request.URL.absoluteString;
    //3) this habits as the method above, unusable on index.html
    //NSString *currentURL=self.webView.request.mainDocumentURL;
    //
    //Note: index.html has a local path, so I assume that's why resolving index.html path in webview results in such a mess
    
    NSLog(@"Refresh pressed at URL: %@", currentURL);
    [self dismissModalViewControllerAnimated:YES];
    [self.webView reload];
    
}
//stop loading current page
-(IBAction)stopPage:(id)sender{
    
    NSLog(@"Stop pressed");
    [self dismissModalViewControllerAnimated:YES];
    [self.webView stopLoading];
    
}
//goto menu
-(IBAction)menuPage:(id)sender{
    
    NSLog(@"Menu pressed");
    [self dismissModalViewControllerAnimated:YES];
    NSString *urlAddress=NSLocalizedString(@"MenuStartPage", @"");
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{

        return YES;
    // Return YES for supported orientations
//    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

/* Comment out the block below to over-ride */
/*
 - (CDVCordovaView*) newCordovaViewWithFrame:(CGRect)bounds
 {
 return[super newCordovaViewWithFrame:bounds];
 }
 */

/* Comment out the block below to over-ride */
/*
 #pragma CDVCommandDelegate implementation
 
 - (id) getCommandInstance:(NSString*)className
 {
 return [super getCommandInstance:className];
 }
 
 - (BOOL) execute:(CDVInvokedUrlCommand*)command
 {
 return [super execute:command];
 }
 
 - (NSString*) pathForResource:(NSString*)resourcepath;
 {
 return [super pathForResource:resourcepath];
 }
 
 - (void) registerPlugin:(CDVPlugin*)plugin withClassName:(NSString*)className
 {
 return [super registerPlugin:plugin withClassName:className];
 }
 */

-(void) addNavBarItem:(NSString*) title: (NSString*) iconSrcName: (SEL) selector: (NSMutableArray*) buttons
{
    UIBarButtonItem* bi = nil;
    UIImage *image =nil;
    UIButton *aButton = nil;
    
    // customicons
    image = [UIImage imageNamed:iconSrcName];
    
    UIImage *newImage =image;

    if([allTrim(iconSrcName) length] > 0){
        bi = [[UIBarButtonItem alloc]
                           initWithImage:newImage style:UIBarButtonItemStyleBordered target:self action:selector];
    }else if([allTrim(title) length] > 0){
        bi=[[UIBarButtonItem alloc]
        initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:selector];
    }else{
        bi=[[UIBarButtonItem alloc]init];
        [bi setAction:selector];
        [bi setTarget:self];
        [bi setStyle:UIBarButtonItemStyleBordered];
    }
    if([allTrim(title) length] > 0)
        bi.title=title;

    [buttons addObject:bi];
    [bi release];
    
}
-(void) createNavigationBarAndToggleRefreshAndStopButton:(BOOL) pageLoaded
{

    /*
     *NAVIGATION TOOL BAR
     */
    
    UIToolbar* toolbar =[[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];

    
    
    // create the array to hold the buttons, which then gets added to the toolbar
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
    
    UIBarButtonItem* bi = nil;
    
    // create a spacer
    bi = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [buttons addObject:bi];
    [bi release];
    
    // create a spacer
    bi = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [buttons addObject:bi];
    [bi release];
    
    // create "menu" button
    [self addNavBarItem:@"Menü":@"" :@selector(menuPage:) :buttons];
    
    // create a spacer
    bi = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [buttons addObject:bi];
    [bi release];
    
    if(pageLoaded){
        // create "refresh" button
        bi = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshPage:)];
        [buttons addObject:bi];
        [bi release];
    }else{
        // create "stop" button
        bi = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopPage:)];
        [buttons addObject:bi];
        [bi release];
    }

    // create a spacer
    bi = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [buttons addObject:bi];
    [bi release];

    // create a spacer
    bi = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [buttons addObject:bi];
    [bi release];

    // stick the buttons in the toolbar
    [toolbar setItems:buttons animated:YES];
    [toolbar sizeToFit];

    // and put the toolbar in the nav bar
    UIBarButtonItem* custombar=[[UIBarButtonItem alloc]initWithCustomView:toolbar];

    NSArray *array = [[NSArray alloc] initWithArray:buttons];
    self.navigationItem.rightBarButtonItems=array;


    bi=[[UIBarButtonItem alloc]
        initWithTitle:@"Start" style:UIBarButtonItemStyleBordered target:self action:@selector(homePage:)];
    self.navigationItem.leftBarButtonItem=bi;
    [bi release];

    [toolbar release];
    
    [self.navigationController.navigationBar sizeToFit];
    
    /*
     *END
     *NAVIGATION TOOL BAR
     */
    
}

#pragma UIWebDelegate implementation

- (void) webViewDidFinishLoad:(UIWebView*) theWebView
{
    // only valid if ___PROJECTNAME__-Info.plist specifies a protocol to handle
    if (self.invokeString)
    {
        // this is passed before the deviceready event is fired, so you can access it in js when you receive deviceready
		NSLog(@"DEPRECATED: window.invokeString - use the window.handleOpenURL(url) function instead, which is always called when the app is launched through a custom scheme url.");
        NSString* jsString = [NSString stringWithFormat:@"var invokeString = \"%@\";", self.invokeString];
        [theWebView stringByEvaluatingJavaScriptFromString:jsString];
    }
    
    // Black base color for background matches the native apps
    theWebView.backgroundColor = [UIColor blackColor];
    
    //set stop button to refresh
    [self createNavigationBarAndToggleRefreshAndStopButton:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	return [super webViewDidFinishLoad:theWebView];
}

/* Comment out the block below to over-ride */
/**/

- (void) webViewDidStartLoad:(UIWebView*)theWebView
{
    //set refresh button to stop mode
    [self createNavigationBarAndToggleRefreshAndStopButton:NO];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
	return [super webViewDidStartLoad:theWebView];
}

- (void) webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
{
    //set refresh button to refresh mode
    [self createNavigationBarAndToggleRefreshAndStopButton:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	return [super webView:theWebView didFailLoadWithError:error];
}

- (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    //set refresh button to stop mode
    [self createNavigationBarAndToggleRefreshAndStopButton:YES];
    
	return [super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
}
/**/

@end
