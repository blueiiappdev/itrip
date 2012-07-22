//
//  DSURLHelper.m
//  iTrip
//
//  Created by Ramon Liu on 7/22/12.
//  Copyright (c) 2012 DreamStart. All rights reserved.
//

#import "DSURLHelper.h"

#define kDebugLocal  1

@interface DSURLHelper(PrivateAPI)

-(NSString*)tripBoardURL;

@end

@implementation DSURLHelper

+(DSURLHelper*) sharedURLHelper {
   static DSURLHelper* helper;
   
   @synchronized(self){
      if (helper == nil) {
         helper = [[DSURLHelper alloc] init];
      }
      return helper;
   }
}

-(id) init {
   if (self = [super init]) {
      
      if (kDebugLocal) {
         m_host = @"http://192.168.0.103:3000";
      } else {
         m_host = @"http://itrip.cloudfoundry.com";
      }
            
      m_tripBoard = @"tripBoard";
   }
   return self;
}

-(NSString*) absolutePath:(NSString *)relativePath
{
   return [NSString stringWithFormat:@"%@/%@", m_host, relativePath];
}

-(NSString*) tripBoardURL {
   return [NSString stringWithFormat:@"%@/%@", m_host, m_tripBoard];
}

-(NSString*) tripBoardGallery:(int)page {
   return [NSString stringWithFormat:@"%@/%@?page=%d", [self tripBoardURL], @"gallery", page];
}

-(NSString*) tripBoardSearchGallery:(NSString *)keyword {
  return [NSString stringWithFormat:@"%@/%@?query=%@", [self tripBoardURL], @"searchgallery", keyword];
}

-(NSString*) tripBoardTripRecord:(NSString *)tid {
   return [NSString stringWithFormat:@"%@/%@?id=%@", [self tripBoardURL], @"triprecord", tid];
}

@end
