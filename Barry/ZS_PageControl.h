//
//  PageControl.h
//  PageControlDemo
//


#import <UIKit/UIKit.h>

typedef enum
{
    PageControlStyleDefault = 0,
    PageControlStyleStrokedCircle = 1,
    PageControlStylePressed1 = 2,
    PageControlStylePressed2 = 3,
    PageControlStyleWithPageNumber = 4,
    PageControlStyleThumb = 5
} PageControlStyle;

@interface ZS_PageControl : UIControl {
    int _currentPage, _numberOfPages;
    BOOL hidesForSinglePage;
    UIColor *coreNormalColor, *coreSelectedColor;
    UIColor *strokeNormalColor, *strokeSelectedColor;
    PageControlStyle _pageControlStyle;
    int _strokeWidth, diameter, gapWidth;
}

@property (nonatomic, retain) UIColor *coreNormalColor, *coreSelectedColor;
@property (nonatomic, retain) UIColor *strokeNormalColor, *strokeSelectedColor;
@property (nonatomic, assign) int _currentPage, _numberOfPages;
@property (nonatomic, assign) BOOL hidesForSinglePage;
@property (nonatomic, assign) PageControlStyle _pageControlStyle;
@property (nonatomic, assign) int _strokeWidth, diameter, gapWidth;
@property (nonatomic, retain) UIImage *thumbImage, *selectedThumbImage;

- (void)setCurrentPage:(int)page;
- (int)currentPage;
- (void)setNumberOfPages:(int)numOfPages;
- (int)numberOfPages;
- (PageControlStyle)pageControlStyle;
- (void)setPageControlStyle:(PageControlStyle)style;

@end
