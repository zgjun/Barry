//
//  AnnotationView.m
//  06-MapKit04-自定义大头针01
//
//  Created by apple on 14-8-7.
//  Copyright (c) 2014年 zgjun. All rights reserved.
//

#import "AnnotationView.h"
#import "Annotation.h"
#import "UIView+Extension.h"

@interface AnnotationView()
@property (nonatomic, weak) UIButton *redView;
@property (nonatomic, weak) UIButton *greenView;
@end

@implementation AnnotationView

+ (instancetype)annotationViewWithMapView:(MKMapView *)mapView
{
    static NSString *ID = @"anno";
    AnnotationView *annotationView = (AnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ID];
    if (annotationView == nil) {
        // 传入循环利用标识来创建大头针控件
        annotationView = [[AnnotationView alloc] initWithAnnotation:nil reuseIdentifier:ID];
    }
    return annotationView;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

- (void)setAnnotation:(Annotation *)annotation
{
    [super setAnnotation:annotation];
    
    self.image = [UIImage imageNamed:annotation.icon];
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UIButton *redView = [[UIButton alloc] init];
//    [redView addTarget:self action:@selector(redClick) forControlEvents:UIControlEventTouchUpInside];
//    redView.backgroundColor = [UIColor redColor];
//    redView.width = 20;
//    redView.height = 20;
//    redView.y = - redView.height;
//    redView.x = (self.width - redView.width) * 0.5;
//    [self addSubview:redView];
//    self.redView = redView;
//    
//    UIButton *greenView = [[UIButton alloc] init];
//    [greenView addTarget:self action:@selector(greenClick) forControlEvents:UIControlEventTouchUpInside];
//    greenView.backgroundColor = [UIColor greenColor];
//    greenView.width = 20;
//    greenView.height = 20;
//    greenView.y = 20;
//    greenView.x = 20;
//    [self addSubview:greenView];
//    self.greenView = greenView;
//}
//
//- (void)redClick
//{
//    NSLog(@"redClick------");
//}
//
//- (void)greenClick
//{
//    NSLog(@"greenClick------");
//}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    if (CGRectContainsPoint(self.redView.frame, point)) {
//        return self.redView;
//    }
//    return [super hitTest:point withEvent:event];
//}
@end
