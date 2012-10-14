//
//  AsyncCD.h
//  ios_cordova_starter
//
//  Created by Daniele Pecora on 10.08.12.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

@interface AsyncCD : CDVPlugin {
    NSMutableData* receivedData;
    NSString* callbackId;
}

@property (nonatomic, copy) NSString* callbackId;

- (void) getJSON:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void) setResultPositive:(NSString*) withContent;
- (void) setResultNegative:(NSString*) withMessage;
- (void) getWebResource:(NSString*) url;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
