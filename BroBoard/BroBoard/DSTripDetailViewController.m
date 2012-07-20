//
//  DSTripDetailControllerViewController.m
//  BroBoard
//
//  Created by Ramon Liu on 7/4/12.
//  Copyright (c) 2012 Duck Duck Moose. All rights reserved.
//

#import "DSTripDetailViewController.h"

@interface DSTripDetailViewController ()

@end

@implementation DSTripDetailViewController
@synthesize authorImage;
@synthesize lblTripTitle;
@synthesize lblAuthor;
@synthesize lblTripDateAndDays;
@synthesize btnComment;
@synthesize btnFav;
@synthesize map;
@synthesize tripImage;
@synthesize tripIntro;
@synthesize tripItem = _tripItem;

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
   
   lblTripTitle.text = @"Shanghai";
   lblAuthor.text = @"Ramon Liu";
   lblTripDateAndDays.text = @"2012-12-31 9days";
   
   tripImage.image = [self.tripItem objectForKey:@"image"];
   authorImage.image = [self.tripItem objectForKey:@"image"]; 
}

- (void)viewDidUnload
{
   [self setAuthorImage:nil];
   [self setLblTripTitle:nil];
   [self setLblAuthor:nil];
   [self setLblTripDateAndDays:nil];
   [self setBtnComment:nil];
   [self setBtnFav:nil];
   [self setMap:nil];
   [self setTripImage:nil];
   [self setTripIntro:nil];
   [super viewDidUnload];
   // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
   [_tripItem release];
   [authorImage release];
   [lblTripTitle release];
   [lblAuthor release];
   [lblTripDateAndDays release];
   [btnComment release];
   [btnFav release];
   [map release];
   [tripImage release];
   [tripIntro release];
   [super dealloc];
}
@end
