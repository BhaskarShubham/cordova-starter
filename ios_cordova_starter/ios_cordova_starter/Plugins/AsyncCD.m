//
//  AsyncCD.m
//  ios_cordova_starter
//
//  Created by Daniele Pecora on 10.08.12.
//
//

#import "AsyncCD.h"

@implementation AsyncCD

@synthesize callbackId;

- (void) getJSON:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    
    //get the callback id
    @try{
        self.callbackId=(NSString*) [arguments pop];
        if(nil!=callbackId){
            NSLog(@"callbackId: %@",self.callbackId);
        }
        
        NSString *url = (NSString*)[options objectForKey:@"url"];
        NSLog(@"getJSON: %@",url);
        [self getWebResource:url];
    }
    @catch(NSException* e){
        [self setResultNegative: [e description]];
    }
}

- (void) setResultPositive:(NSString*) withContent{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: withContent];
    NSLog(@"setResultPositive ----------- callbackId: '%@' ----------",self.callbackId);
    NSLog(@"setResultPositive ----------- result: '%@' ----------",withContent );
    [self writeJavascript:[result toSuccessCallbackString:self.callbackId]];
}

- (void) setResultNegative:(NSString*) withMessage{
    NSLog(@"setResultNegative ----------- callbackId: '%@' result: '%@' ----------",self.callbackId,withMessage );
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: withMessage];
    [self writeJavascript:[result toErrorCallbackString:self.callbackId]];
}

- (void) getWebResource:(NSString*) url {
    // Create the request.
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (nil!=theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData = [[NSMutableData data] retain];
        //dont release here, it gets released on delegate methods 'didFailWithError' and 'connectionDidFinishLoading'
        //[theConnection release];
    } else {
        // Inform the user that the connection failed.
        [self setResultNegative: @"Error: Connection failed"];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString* errMessage=[NSString stringWithFormat:@"Error: %@",[error localizedDescription]];
    [self setResultNegative: errMessage];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    
    NSString* content = [[[NSString alloc] initWithData:receivedData
                                               encoding:NSUTF8StringEncoding] autorelease];
    
    // release the connection, and the data object
    [connection release];
    [receivedData release];
    
    [self setResultPositive: content];
}

@end