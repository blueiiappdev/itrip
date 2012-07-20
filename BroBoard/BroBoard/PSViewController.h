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

//#define kHostUrl  "http://192.168.1.103:3000"
#define kHostUrl  "http://ramonblog.cloudfoundry.com"

@interface PSViewController : UIViewController <PSCollectionViewDelegate, PSCollectionViewDataSource, EGORefreshTableHeaderDelegate, UISearchBarDelegate>
{
   BOOL           _connectedSuccess;
   NSMutableData* _galleryData;
}

@end
