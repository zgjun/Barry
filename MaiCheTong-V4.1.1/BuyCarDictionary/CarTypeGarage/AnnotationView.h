//
//  AnnotationView.h
//  06-MapKit04-自定义大头针01
//
//  Created by apple on 14-8-7.
//  Copyright (c) 2014年 zgjun. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface AnnotationView : MKAnnotationView
+ (instancetype)annotationViewWithMapView:(MKMapView *)mapView;
@end
