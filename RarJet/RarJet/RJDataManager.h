//
//  RJDataManager.h
//  RarJet
//
//  Created by Mert Buran on 22/03/15.
//  Copyright (c) 2015 Mert Buran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJDataManager : NSObject
@property (nonatomic, strong) NSString *currentLocaleString;

- (void)cancelNetworkOperations;
- (void)fetchResultsWithSearchString:(NSString *)searchString
                             success:(void (^)(NSDictionary *responseDictionary))success
                             failure:(void (^)(NSError *error))failure;
@end
