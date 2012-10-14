//
//  RotatingNavigationController.m
//  ios_cordova_starter
//
//  Created by Daniele Pecora on 13.08.12.
//
//

#import "RotatingNavigationController.h"

@interface RotatingNavigationController ()

@end

@implementation RotatingNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    //return YES when supporting all orientations
    return YES;
}

@end
