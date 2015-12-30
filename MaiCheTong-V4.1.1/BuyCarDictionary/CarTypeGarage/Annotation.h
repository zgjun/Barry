//
//  HMAnnotation.h
//  05-MapKit03-添加大头针
//
//  Created by apple on 14-8-7.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Annotation : NSObject <MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
/**
 *  图片名
 */
@property (nonatomic, copy) NSString *icon;
@end
