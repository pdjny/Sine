//
//  View.m
//  Sine
//
//  Created by PHILIP JACOBS on 7/14/13.
//  Copyright (c) 2013 PHILIP JACOBS. All rights reserved.
//

#import "View.h"

/*
 Each cell of the graph paper has two lines at a right angle:
 
 |
 |
 |
 +-------------
 */

//Dimensions of each cell.  The cell will be scaled (magnified) by the
//same factor as the main drawing, so we have to make the lines very thin.

const CGFloat hSize = M_PI / 2; //horizontal: 1/2 the length of 1 hump of sine curve
const CGFloat vSize = 1;        //vertical: height of hump

static void drawCell(void *p, CGContextRef c)
{
	CGFloat scale = *(CGFloat *)p;
	CGContextSetLineWidth(c, 1 / scale);
	CGContextBeginPath(c);
	
	CGContextMoveToPoint(c, 0, vSize);	//top of L
	CGContextAddLineToPoint(c, 0, 0);	//vertical line
	CGContextAddLineToPoint(c, hSize, 0);	//horizontal line
	
	CGContextStrokePath(c);
}

@implementation View

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor whiteColor];
		slide = 0;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	// Drawing code
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	//Place the origin at the center of view.
	CGSize size = self.bounds.size;
	CGAffineTransform translate = CGAffineTransformMakeTranslation(
		size.width / 2,
		size.height / 2);

	//Graph sine as x goes from -2pi to +2pi,
	//drawing 2 complete sine waves.
	CGFloat width = 4 * M_PI;
	CGFloat scale = size.width / width;
	
	//********************************************************
	//********************************************************
	//********************************************************
	
	//Pattern cell origin in lower left corner, Y axis points up.
	CGAffineTransform patternScale = CGAffineTransformMakeScale(scale,  scale);
	
	CGAffineTransform patternTransform =
	CGAffineTransformConcat(patternScale, translate);
	
	//Graph paper, faint blue in background.
	
	//Tell it that our colors are RGB, not CYMK or grayscale.
	CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
	CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(baseSpace);
	CGContextSetFillColorSpace(c, patternSpace);
	CGColorSpaceRelease(patternSpace);
	CGColorSpaceRelease(baseSpace);
	
	static const CGPatternCallbacks callbacks = {0, drawCell, NULL};
	
	CGPatternRef pattern = CGPatternCreate(
										   &scale,		//argument passed to drawCell
										   CGRectMake(0, 0, hSize, vSize),
										   patternTransform,
										   hSize, vSize,	//distance between cells: none at all
										   kCGPatternTilingConstantSpacing,
										   false,	//Graph paper is monochromatic (a "stencil" pattern).
										   &callbacks
										   );
	
	static const CGFloat color[] = {0, 0, 1, 0.25};	//rgb alpha
	CGContextSetFillPattern(c, pattern, color);
	CGPatternRelease(pattern);
	CGContextFillRect(c, self.bounds);
	
	//********************************************************
	//********************************************************
	//********************************************************

	//Make Y axis point up.
	CGAffineTransform sineScale = CGAffineTransformMakeScale(scale, -scale);
	
	UIFont *font = [UIFont systemFontOfSize: 24];
	[@" y = sin(x)" drawAtPoint: CGPointZero withFont: font];
	
	//Axes
	CGContextConcatCTM(c, translate);
	CGContextBeginPath(c);
	
	//X axis
	CGContextMoveToPoint(c, -size.width / 2, 0);
	CGContextAddLineToPoint(c, size.width / 2, 0);
	
	//Y axis
	CGContextMoveToPoint(c, 0, size.height / 2);
	CGContextAddLineToPoint(c, 0, -size.height / 2);
	
	CGContextSetRGBStrokeColor(c, 0, 0, 1, .5);
	CGContextStrokePath(c);
	
	//Graph of sine function.
	CGContextConcatCTM(c, sineScale);
	CGContextBeginPath(c);
	
	BOOL first = YES;
	for (CGFloat x = -2 * M_PI; x <= 2 * M_PI; x += 1 / scale) {
		CGFloat xAlt = x + slide;
		CGFloat y = sinf(xAlt);				//Punchline.
		//CGFloat y = x * x / 4;
		//CGFloat y = floorf(x);
		//CGFloat y = floorf(5 * sinf(xAlt));	//Mayan ruins.
		//CGFloat y = x * sinf(3 * x);
		//CGFloat y = 3 * sinf(80 / x);	//The Outer Limits.
		if (first) {
			first = NO;
			CGContextMoveToPoint(c, x, y);	//first iteration of loop
		} else {
			CGContextAddLineToPoint(c, x, y);
		}
	}
	slide += .3;
	
	assert(scale != 0);	//Don't risk division by 0.
	//CGContextSetLineWidth(c, 10);
	CGContextSetLineWidth(c, 10 / scale);
	CGContextSetRGBStrokeColor(c, 0.0, 0.0, 0.0, 1.0);
	CGContextStrokePath(c);

[self performSelector: @selector(setNeedsDisplay) withObject: nil afterDelay: .1];

}
@end
