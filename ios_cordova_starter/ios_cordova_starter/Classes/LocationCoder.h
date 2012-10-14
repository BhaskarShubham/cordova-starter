//
//  LocationCoder.h
//  
//
//  Created by Daniele Pecora on 28.08.12.
//  Copyright (c) 2012 Daniele Pecora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class LocationCoder;
typedef enum{
    COUNTRY, STATE, POSTALCODE, CITY, DESTRICT, STREET, HOUSENUMBER,    
} AddressPart;
@protocol LocationCoderDelegate<NSObject>
-(BOOL) locationReceived:(LocationCoder *)sender;
@end

@interface LocationCoder : NSObject
<CLLocationManagerDelegate, CLLocationManagerDelegate>
{
    CLLocationManager  *locationManager;
    CLGeocoder *geocoder;
    CLLocation *location;
    CLPlacemark *placemark;
}
@property (copy,readonly) CLLocation *location;
@property (copy,readonly) CLPlacemark *placemark;
@property (retain,nonatomic) id<LocationCoderDelegate> delegate;

- (void) start;
+(NSString*) getPart:(AddressPart)part fromAddress:(CLPlacemark*)placemark;
+(BOOL) enabled;
//debug use only
+(NSString*) getAddressString:(CLPlacemark*)placemark;
+(NSString*) getCompleteString:(CLPlacemark*)placemark;
@end
