//
//  PSViewController.h
//  BroBoard
//
//  Created by Peter Shih on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PSCollectionView.h"
#import "EGORefreshTableHeaderView.h"

@interface PSViewController : UIViewController <PSCollectionViewDelegate, PSCollectionViewDataSource, EGORefreshTableHeaderDelegate, UISearchBarDelegate>
{
   BOOL           _connectedSuccess;
   NSMutableData* _galleryData;
}

@end
