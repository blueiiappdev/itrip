//
//  DSTripDetailControllerViewController.h
//  BroBoard
//
//  Created by Ramon Liu on 7/4/12.
//  Copyright (c) 2012 Duck Duck Moose. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DSTripDetailViewController : UIViewController
{
}

@property (retain, nonatomic) IBOutlet UIImageView *authorImage;
@property (retain, nonatomic) IBOutlet UILabel *lblTripTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblAuthor;
@property (retain, nonatomic) IBOutlet UILabel *lblTripDateAndDays;
@property (retain, nonatomic) IBOutlet UIButton *btnComment;
@property (retain, nonatomic) IBOutlet UIButton *btnFav;

@property (retain, nonatomic) IBOutlet MKMapView *map;
@property (retain, nonatomic) IBOutlet UIImageView *tripImage;
@property (retain, nonatomic) IBOutlet UITextView *tripIntro;
@property (retain, nonatomic) NSDictionary* tripItem;

@end
