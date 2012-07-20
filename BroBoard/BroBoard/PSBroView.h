//
//  PSBroView.h
//  BroBoard
//
//  Created by Peter Shih on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSCollectionViewCell.h"
#import "PSViewController.h"

@interface PSBroView : PSCollectionViewCell
{
   BOOL           m_connectionSuccess;
   NSMutableData* m_imageData;
   BOOL           m_showLabel;
}

@property(atomic) BOOL showCaptionLabel;
@property (nonatomic, retain) UIImageView *imageView;

@end
