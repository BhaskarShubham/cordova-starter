//
//  LocationCoder.m
//
//
//  Created by Daniele Pecora on 28.08.12.
//  Copyright (c) 2012 Daniele Pecora. All rights reserved.
//

#import "LocationCoder.h"

@interface LocationCoder ()
{
}
//reassign for internal write attribute
@property (copy,readwrite) CLLocation *location;
@property (copy,readwrite) CLPlacemark *placemark;
@end

@implementation LocationCoder
@synthesize location;
@synthesize placemark;
@synthesize delegate;

-(id) init
{
    self=[super init];
    if(self){
        //inititalize members and properties here
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate=self;
        geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

/* When ARC is ON:it is now done by ARC (Automated Reference Counting, requires Gabage Collection beeing disabled)*/
 - (void) dealloc
 {
 [locationManager release];
 [geocoder release];
 [super dealloc];
 }

//Location implementation
+(BOOL) enabled
{
    return [CLLocationManager locationServicesEnabled];
}
//Obtain Location GPS coordinates
- (void)start
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    //    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500;
    [locationManager startUpdatingLocation];
    if(nil == geocoder)
        geocoder = [[CLGeocoder alloc] init];
}

//CLLocationManager delegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    //stop location service
    [locationManager stopUpdatingLocation];
    self.location=newLocation;
    NSLog(@"didUpdateToLocation - Latitude  : %f",self.location.coordinate.latitude );
    NSLog(@"didUpdateToLocation - Longitude : %f",self.location.coordinate.longitude);
    [self callDelegateWithLocation:self.location];
}

-(void)callDelegateWithLocation:(CLLocation *)loc
{
    NSLog(@"callDelegateWithLocation - Location: %f, %f",location.coordinate.latitude,location.coordinate.latitude );
    LocationCoder *this=self;
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        this.placemark=[placemarks objectAtIndex:0];
        if(nil!=delegate){
            if([delegate locationReceived:self])
            {NSLog(@"callDelegateWithLocation RETURN YES");
            }else{NSLog(@"callDelegateWithLocation RETURN NO");}
        }else{
            NSLog(@"callDelegateWithLocation - No delegate is set.");
        }
        
        NSString *completeString=[LocationCoder getCompleteString:placemark];
        NSLog(@"%@",completeString);
    }];
}
/**
 * Get Part from {@link CLPlacemark}
 *
 * @param placemark
 *            Address <br>
 *            May not be {@code null}, otherwise {@code null} will be
 *            returned
 * @param addressPart
 *            AddressPart<br>
 *            May not be {@code null}, otherwise {@code null} will be
 *            returned
 * @return NSString, the requested part of the given address or {@code null}
 */+(NSString*) getPart:(AddressPart)addressPart fromAddress:(CLPlacemark*)placemark
{
    NSString *part=nil;
    switch(addressPart){
        case COUNTRY:
            part=placemark.country;
            break;
        case STATE:
            part=placemark.administrativeArea;
            break;
        case POSTALCODE:
            part=placemark.postalCode;
            break;
        case CITY:
            part=placemark.locality;
            break;
        case DESTRICT:
            part=placemark.subLocality;
            break;
        case STREET:
            part=placemark.thoroughfare;
            if(nil==part){
                part=placemark.name;
            }
            break;
        case HOUSENUMBER:
            part=placemark.subThoroughfare;
            break;
    }
    return part;
}
//for debug use only
+(NSString*) getAddressString:(CLPlacemark *) placemark
{
    NSString *country=[LocationCoder getPart:COUNTRY fromAddress:placemark];
    NSString *state=[LocationCoder getPart:STATE fromAddress:placemark];
    NSString *postalcode=[LocationCoder getPart:POSTALCODE fromAddress:placemark];
    NSString *city=[LocationCoder getPart:CITY fromAddress:placemark];
    NSString *destrict=[LocationCoder getPart:DESTRICT fromAddress:placemark];
    NSString *street=[LocationCoder getPart:STREET fromAddress:placemark];
    NSString *housenumber=[LocationCoder getPart:HOUSENUMBER fromAddress:placemark];
    NSString *formatted=[NSString stringWithFormat:@"%@ \n%@ \n%@ %@ %@ \n%@ %@",country,state,postalcode,city,destrict,street,housenumber];
    return formatted;
}
//for debug use only
+(NSString*) getCompleteString:(CLPlacemark*)placemark
{
    NSString *name=placemark.name; // eg. Apple Inc.
    NSString *thoroughfare=placemark.thoroughfare; // street address, eg. 1 Infinite Loop
    NSString *subThoroughfare=placemark.subThoroughfare; // eg. 1
    NSString *locality=placemark.locality; // city, eg. Cupertino
    NSString *subLocality=placemark.subLocality; // neighborhood, common name, eg. Mission District
    NSString *administrativeArea=placemark.administrativeArea; // state, eg. CA
    NSString *subAdministrativeArea=placemark.subAdministrativeArea; // county, eg. Santa Clara
    NSString *postalCode=placemark.postalCode; // zip code, eg. 95014
    NSString *ISOcountryCode=placemark.ISOcountryCode; // eg. US
    NSString *country=placemark.country; // eg. United States
    NSString *inlandWater=placemark.inlandWater; // eg. Lake Tahoe
    NSString *ocean=placemark.ocean; // eg. Pacific Ocean
    NSArray *areasOfInterest=placemark.areasOfInterest; // eg. Golden Gate Park
    
    NSString *completeString=[NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@",name,thoroughfare,subThoroughfare,locality,subLocality,administrativeArea,subAdministrativeArea,postalCode,ISOcountryCode,country,inlandWater,ocean,areasOfInterest];
    return completeString;
}

@end
