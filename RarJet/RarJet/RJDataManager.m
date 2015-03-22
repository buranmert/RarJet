//
//  RJDataManager.m
//  RarJet
//
//  Created by Mert Buran on 22/03/15.
//  Copyright (c) 2015 Mert Buran. All rights reserved.
//

#import "RJDataManager.h"
#import "AFHTTPRequestOperationManager.h"

static NSString * const RJBaseURL = @"http://api.goeuro.com/api/v2/position/suggest/";
static const NSInteger RJMinQueryLength = 2;

@interface RJDataManager()
@property (nonatomic, strong) AFHTTPRequestOperationManager *networkManager;
@property (nonatomic, strong) AFHTTPRequestOperation *currentNetworkOperation;
@end

@implementation RJDataManager

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.currentLocaleString = @"en";
        NSURL *baseURL = [NSURL URLWithString:RJBaseURL];
        self.networkManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    }
    return self;
}

- (void)cancelNetworkOperations {
    [self.networkManager.operationQueue cancelAllOperations];
}

- (void)fetchResultsWithSearchString:(NSString *)searchString
                             success:(void (^)(NSDictionary *responseDictionary))success
                             failure:(void (^)(NSError *error))failure {
    //we don't want to send multiple requests at the same time
    if (self.currentNetworkOperation != nil) {
        [self.networkManager.operationQueue cancelAllOperations];
    }
    //to handle , . " " and so
    searchString = [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //by the design of API, if we query with a too short string it always returns with empty array. no need to send a request
    if (searchString.length < RJMinQueryLength) {
        self.currentNetworkOperation = nil;
        success(nil);
    }
    else {
        NSString *fullQueryString = [NSString stringWithFormat:@"%@/%@", self.currentLocaleString, searchString];
        self.currentNetworkOperation = [self.networkManager GET:fullQueryString
                                                     parameters:nil
                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                            NSDictionary *responseDict = responseObject;
                                                            success(responseDict);
                                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                            failure(error);
                                                        }];
    }
}

@end
