/*
 * CCLayerPanZoom Tests
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011 Alexey Lang
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

// Import the interfaces
#import "CCLayerPanZoomTestLayer.h"
#import "ExtensionTest.h"

SYNTHESIZE_EXTENSION_TEST(CCLayerPanZoomSimpleSheetTestLayer)

enum nodeTags
{
	kBackgroundTag,
	kLabelTag,
    kTestObject1,
    kTestObject2,
    kTestObject3,
};

Class nextTest(void);
Class backTest(void);

static int testId = 0;
static NSString *tests[] = {
    @"CCLayerPanZoomSimpleSheetTestLayer",
    @"CCLayerPanZoomAdvancedSheetTestLayer",
    @"CCLayerPanZoomFrameTestLayer",
    @"CCLayerPanZoomAdvancedSheetTestLayerConsume"
};

Class nextTest()
{
	testId++;
	testId = testId % (sizeof(tests) / sizeof(tests[0]));
	NSString *r = tests[testId];
	Class c = NSClassFromString(r);
	return c;
}

Class backTest()
{
	testId--;
	int total = (sizeof(tests) / sizeof(tests[0]));
	if (testId < 0)
		testId += total;	
	
	NSString *r = tests[testId];
	Class c = NSClassFromString(r);
	return c;
}

#pragma mark CCLayerPanZoomTestLayer

@implementation CCLayerPanZoomTestLayer

- (id) init
{
	if ((self = [super init])) 
    {
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLabelTTF* label = [CCLabelTTF labelWithString: [self title] 
                                               fontName: @"Arial"  
                                               fontSize: 24];
		[self addChild: label 
                     z: 1];
		[label setPosition: ccp(s.width / 2, s.height - 50.0f)];
		
        CCLabelTTF *labelLeft = [CCLabelTTF labelWithString: @"<<" 
                                                   fontName: @"Arial" 
                                                   fontSize: 32];
        CCMenuItemLabel *itemLeft = [CCMenuItemLabel itemWithLabel: labelLeft 
                                                            target: self 
                                                          selector: @selector(backCallback:)];
        itemLeft.position = ccp(s.width / 2 - 200.0f, s.height - 50.0f);
        CCLabelTTF *labelRight = [CCLabelTTF labelWithString: @">>" 
                                                    fontName: @"Arial" 
                                                    fontSize: 32];
        CCMenuItemLabel *itemRight = [CCMenuItemLabel itemWithLabel: labelRight 
                                                             target: self 
                                                           selector: @selector(nextCallback:)];
        itemRight.position = ccp(s.width / 2 + 200.0f, s.height - 50.0f);		
		CCMenu *menu = [CCMenu menuWithItems: itemLeft, itemRight, nil];
		menu.position = CGPointZero;
		[self addChild: menu 
                     z: 1];
	}
    
	return self;
}

- (void) dealloc
{
    _panZoomLayer.delegate = nil;
    [_panZoomLayer release];
	[super dealloc];
}

- (void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextTest() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

- (void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [backTest() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

- (NSString *) title
{
	return @"No title";
}

- (void) updateForScreenReshape
{
}

- (void) layerPanZoom: (CCLayerPanZoom *) sender 
	   clickedAtPoint: (CGPoint) point
             tapCount: (NSUInteger) tapCount
{
	NSLog(@"CCLayerPanZoomTestLayer#layerPanZoom: %@ clickedAtPoint: { %f, %f }", sender, point.x, point.y);
}

- (void) layerPanZoom: (CCLayerPanZoom *) sender 
 touchPositionUpdated: (CGPoint) newPos
{
    NSLog(@"CCLayerPanZoomTestLayer#layerPanZoom: %@ touchPositionUpdated: { %f, %f }", sender, newPos.x, newPos.y);
}

- (void) layerPanZoom: (CCLayerPanZoom *) sender touchMoveBeganAtPosition: (CGPoint) aPoint
{
    NSLog(@"CCLayerPanZoomTestLayer#layerPanZoom: %@ touchMoveBeganAtPosition: { %f, %f }", sender, aPoint.x, aPoint.y);
}

@end

#pragma mark -
#pragma mark SimpleSheetTest

@implementation CCLayerPanZoomSimpleSheetTestLayer

- (id) init
{
	if ((self = [super init])) 
    {
        _panZoomLayer = [[CCLayerPanZoom node] retain];
        [self addChild: _panZoomLayer];
		_panZoomLayer.delegate = self; 
        
        // background
        CCSprite *background = [CCSprite spriteWithFile: @"background.png"];
        background.anchorPoint = ccp(0,0);
		background.scale = CC_CONTENT_SCALE_FACTOR();
        [_panZoomLayer addChild: background 
                             z :0 
                            tag: kBackgroundTag];
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString: @"Try panning and zooming using drag and pinch" 
                                               fontName: @"Marker Felt" 
                                               fontSize: 24];
		label.scale = 0.7f; //< to be visible on iPod Touch screen.
		label.color = ccWHITE;
		// add the label as a child to this Layer
		[_panZoomLayer addChild: label 
                              z: 1 
                            tag: kLabelTag];
        _panZoomLayer.mode = kCCLayerPanZoomModeSheet;
        _panZoomLayer.minScale = 1.0f;
        _panZoomLayer.rubberEffectRatio = 0.0f;
		[self updateForScreenReshape];
	}
	
	return self;
	
}

- (NSString *) title
{
	return @"Test 1. Sheet (Rubber Effect OFF).";
}

- (void) updateForScreenReshape
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	CCNode *background = [_panZoomLayer getChildByTag: kBackgroundTag];
	// our bounding rect
	CGRect boundingRect = CGRectMake(0, 0, 0, 0);
	boundingRect.size = [background boundingBox].size;
	[_panZoomLayer setContentSize: boundingRect.size];
    
	_panZoomLayer.anchorPoint = ccp(0.5f, 0.5f);
	_panZoomLayer.position = ccp(0.5f * winSize.width, 0.5f * winSize.height);
    
    _panZoomLayer.panBoundsRect = CGRectMake(0, 0, winSize.width, winSize.height);
    
	// position the label on the center of the bounds
	CCNode *label = [_panZoomLayer getChildByTag: kLabelTag];
	label.position =  ccp(boundingRect.size.width * 0.5f, boundingRect.size.height * 0.5f);
}

@end

#pragma mark -
#pragma mark SimpleSheetTest

@implementation CCLayerPanZoomAdvancedSheetTestLayer

- (id) init
{
	if ((self = [super init])) 
    {
        _panZoomLayer = [[CCLayerPanZoom node] retain];
        [self addChild: _panZoomLayer];
		_panZoomLayer.delegate = self; 
        
        // background
        CCSprite *background = [CCSprite spriteWithFile: @"background.png"];
        background.anchorPoint = ccp(0,0);
		background.scale = CC_CONTENT_SCALE_FACTOR();
        [_panZoomLayer addChild: background 
                             z :0 
                            tag: kBackgroundTag];
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString: @"Try panning and zooming using drag and pinch" 
                                               fontName: @"Marker Felt" 
                                               fontSize: 24];
		label.scale = 0.7f; //< to be visible on iPod Touch screen.
		label.color = ccWHITE;
		// add the label as a child to this Layer
		[_panZoomLayer addChild: label 
                              z: 1 
                            tag: kLabelTag];
        _panZoomLayer.mode = kCCLayerPanZoomModeSheet;
		[self updateForScreenReshape];
	}
	
	return self;
	
}

- (NSString *) title
{
	return @"Test 2. Sheet (Rubber Effect ON).";
}

- (void) updateForScreenReshape
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	CCNode *background = [_panZoomLayer getChildByTag: kBackgroundTag];
	// our bounding rect
	CGRect boundingRect = CGRectMake(0, 0, 0, 0);
	boundingRect.size = [background boundingBox].size;
	[_panZoomLayer setContentSize: boundingRect.size];
    
	_panZoomLayer.anchorPoint = ccp(0.5f, 0.5f);
	_panZoomLayer.position = ccp(0.5f * winSize.width, 0.5f * winSize.height);
    
    _panZoomLayer.panBoundsRect = CGRectMake(0, 0, winSize.width, winSize.height);
    
	// position the label on the center of the bounds
	CCNode *label = [_panZoomLayer getChildByTag: kLabelTag];
	label.position =  ccp(boundingRect.size.width * 0.5f, boundingRect.size.height * 0.5f);
    
    // Allow panZoomLayer's contents occupy half of the screen.
    _panZoomLayer.minScale = 0.5f * _panZoomLayer.panBoundsRect.size.width  / boundingRect.size.width;
}

@end

#pragma mark -
#pragma mark Advanced sheet test consume

@implementation CCLayerPanZoomAdvancedSheetTestLayerConsume

- (id) init
{
	if ((self = [super init])) 
    {
        _panZoomLayer = [[CCLayerPanZoom node] retain];
        [self addChild: _panZoomLayer];
		_panZoomLayer.delegate = self; 
        
        // background
        CCSprite *background = [CCSprite spriteWithFile: @"background.png"];
        background.anchorPoint = ccp(0,0);
		background.scale = CC_CONTENT_SCALE_FACTOR();
        [_panZoomLayer addChild: background 
                             z :0 
                            tag: kBackgroundTag];
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString: @"Try panning and zooming using drag and pinch. Also try moving objects." 
                                               fontName: @"Marker Felt" 
                                               fontSize: 24];
		label.scale = 0.7f; //< to be visible on iPod Touch screen.
		label.color = ccWHITE;
		// add the label as a child to this Layer
		[_panZoomLayer addChild: label 
                              z: 1 
                            tag: kLabelTag];
        _panZoomLayer.mode = kCCLayerPanZoomModeSheet;
        
        // Add test objects.
        CCSprite *testObject1 = [CCSprite spriteWithFile: @"Icon-72.png"];
		[_panZoomLayer addChild: testObject1 
                              z: 1 
                            tag: kTestObject1];
        
        CCSprite *testObject2 = [CCSprite spriteWithFile: @"Icon-72.png"];
		[_panZoomLayer addChild: testObject2 
                              z: 1 
                            tag: kTestObject2];
        
        CCSprite *testObject3 = [CCSprite spriteWithFile: @"Icon-72.png"];
		[_panZoomLayer addChild: testObject3 
                              z: 1 
                            tag: kTestObject3];
        
		[self updateForScreenReshape];
	}
	
	return self;
	
}

- (NSString *) title
{
	return @"Test 4. Sheet (Special consume).";
}

- (void) updateForScreenReshape
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	CCNode *background = [_panZoomLayer getChildByTag: kBackgroundTag];
	// our bounding rect
	CGRect boundingRect = CGRectMake(0, 0, 0, 0);
	boundingRect.size = [background boundingBox].size;
	[_panZoomLayer setContentSize: boundingRect.size];
    
	_panZoomLayer.anchorPoint = ccp(0.5f, 0.5f);
	_panZoomLayer.position = ccp(0.5f * winSize.width, 0.5f * winSize.height);
    
    _panZoomLayer.panBoundsRect = CGRectMake(0, 0, winSize.width, winSize.height);
    
	// position the label on the center of the bounds
	CCNode *label = [_panZoomLayer getChildByTag: kLabelTag];
	label.position =  ccp(boundingRect.size.width * 0.5f, boundingRect.size.height * 0.5f);
    
    // Position test objects in the center.
    CCNode *testObject = [_panZoomLayer getChildByTag: kTestObject1];
	testObject.position =  ccp(boundingRect.size.width * 0.6f, boundingRect.size.height * 0.5f - 56);
    
    CCNode *testObject2 = [_panZoomLayer getChildByTag: kTestObject2];
	testObject2.position =  ccp(boundingRect.size.width * 0.5f, boundingRect.size.height * 0.5f - 56);
    
    CCNode *testObject3 = [_panZoomLayer getChildByTag: kTestObject3];
	testObject3.position =  ccp(boundingRect.size.width * 0.4f, boundingRect.size.height * 0.5f - 56);
    
    // Allow panZoomLayer's contents occupy half of the screen.
    _panZoomLayer.minScale = 0.5f * _panZoomLayer.panBoundsRect.size.width  / boundingRect.size.width;
}
-(BOOL)layerPanZoom:(CCLayerPanZoom *)sender 
       touchesBegan:(NSSet *)touches
          withEvent:(UIEvent *)event{
    _selectedTestObject = nil;
    if (touches.count!=1) {
        return YES;
    }
    UITouch* touch = [touches anyObject];
    CGPoint touchPosition = [[CCDirector sharedDirector] convertToGL: [touch previousLocationInView: [touch view]]];
    CGPoint point = [sender convertToNodeSpace: touchPosition];
    CCSprite *testObject1 = (CCSprite *)[_panZoomLayer getChildByTag: kTestObject1];
    CCSprite *testObject2 = (CCSprite *)[_panZoomLayer getChildByTag: kTestObject2];
    CCSprite *testObject3 = (CCSprite *)[_panZoomLayer getChildByTag: kTestObject3];
    
    
    // Select new test object.
    if ( CGRectContainsPoint( [testObject1 boundingBox], point))
    {
        _selectedTestObject = testObject1;
        return NO;
    }
    
    if ( CGRectContainsPoint( [testObject2 boundingBox], point))
    {
        _selectedTestObject = testObject2;
        return NO;
    }
    
    if ( CGRectContainsPoint( [testObject3 boundingBox], point))
    {
        _selectedTestObject = testObject3;
        return NO;
    }
    
    return YES;
}
-(void) layerPanZoom:(CCLayerPanZoom *) sender 
        touchesMoved:(NSSet *) touches 
           withEvent:(UIEvent *) event{
    if (_selectedTestObject){
        UITouch* touch = [touches anyObject];
        CGPoint touchPosition = [[CCDirector sharedDirector] convertToGL: [touch previousLocationInView: [touch view]]];
        CGPoint point = [sender convertToNodeSpace: touchPosition];
        _selectedTestObject.position = point;
    }
}
@end

#pragma mark -
#pragma mark FrameTest

@implementation CCLayerPanZoomFrameTestLayer

- (id) init
{
	if ((self = [super init])) 
    {
        _panZoomLayer = [[CCLayerPanZoom node] retain];
        [self addChild: _panZoomLayer];
		_panZoomLayer.delegate = self;         
        // background
        CCSprite *background = [CCSprite spriteWithFile: @"background.png"];
        background.anchorPoint = ccp(0,0);
		background.scale = CC_CONTENT_SCALE_FACTOR();
        [_panZoomLayer addChild: background 
                             z :0 
                            tag: kBackgroundTag];
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString: @"Pinch to zoom, drag icon to edges to scroll." 
                                               fontName: @"Marker Felt" 
                                               fontSize: 24];
		// add the label as a child to this Layer
		[_panZoomLayer addChild: label 
                              z: 1 
                            tag: kLabelTag];
        
        // Add test objects.
        CCSprite *testObject1 = [CCSprite spriteWithFile: @"Icon-72.png"];
		[_panZoomLayer addChild: testObject1 
                              z: 1 
                            tag: kTestObject1];
        
        CCSprite *testObject2 = [CCSprite spriteWithFile: @"Icon-72.png"];
		[_panZoomLayer addChild: testObject2 
                              z: 1 
                            tag: kTestObject2];
        
        CCSprite *testObject3 = [CCSprite spriteWithFile: @"Icon-72.png"];
		[_panZoomLayer addChild: testObject3 
                              z: 1 
                            tag: kTestObject3];
        
        _selectedTestObject = testObject1;
        _selectedTestObject.color = ccRED;

		[self updateForScreenReshape];
	}
	
	return self;
}

- (NSString *) title
{
	return @"Test 3. Frame test.";
}

- (void) onEnter
{
    [super onEnter];
    _panZoomLayer.mode = kCCLayerPanZoomModeFrame;
}

- (void) onExit
{
    _selectedTestObject = nil;
    
    [super onExit];
}

- (void) updateForScreenReshape
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	CCNode *background = [_panZoomLayer getChildByTag: kBackgroundTag];
	// our bounding rect
	CGRect boundingRect = CGRectMake(0, 0, 0, 0);
	boundingRect.size = [background boundingBox].size;
	[_panZoomLayer setContentSize: boundingRect.size];
		
	_panZoomLayer.anchorPoint = ccp(0.5f, 0.5f);
	_panZoomLayer.position = ccp(0.5f * winSize.width, 0.5f * winSize.height);
	
    _panZoomLayer.panBoundsRect = CGRectMake(0, 0, winSize.width, winSize.height);

	// position the label on the center of the bounds
	CCNode *label = [_panZoomLayer getChildByTag: kLabelTag];
	label.position =  ccp(boundingRect.size.width * 0.5f, boundingRect.size.height * 0.5f);
	
    // Position test objects in the center.
    CCNode *testObject = [_panZoomLayer getChildByTag: kTestObject1];
	testObject.position =  ccp(boundingRect.size.width * 0.6f, boundingRect.size.height * 0.5f - 56);
    
    CCNode *testObject2 = [_panZoomLayer getChildByTag: kTestObject2];
	testObject2.position =  ccp(boundingRect.size.width * 0.5f, boundingRect.size.height * 0.5f - 56);
    
    CCNode *testObject3 = [_panZoomLayer getChildByTag: kTestObject3];
	testObject3.position =  ccp(boundingRect.size.width * 0.4f, boundingRect.size.height * 0.5f - 56);
    
    // Stay in screen bounds (1 screen = minScale), allow to zoom 2x.
    _panZoomLayer.minScale =  1.0f *  winSize.width / [background boundingBox].size.width;
    _panZoomLayer.maxScale =  2.0f *  winSize.width / [background boundingBox].size.width;
}

- (void) selectTestObjectAtPoint: (CGPoint) point
{
    _selectedTestObject = nil;
    
    CCSprite *testObject1 = (CCSprite *)[_panZoomLayer getChildByTag: kTestObject1];
    CCSprite *testObject2 = (CCSprite *)[_panZoomLayer getChildByTag: kTestObject2];
    CCSprite *testObject3 = (CCSprite *)[_panZoomLayer getChildByTag: kTestObject3];
    
    
    // Select new test object.
    if ( CGRectContainsPoint( [testObject1 boundingBox], point))
    {
        _selectedTestObject = testObject1;
    }
    
    if ( CGRectContainsPoint( [testObject2 boundingBox], point))
    {
        _selectedTestObject = testObject2;
    }
    
    if ( CGRectContainsPoint( [testObject3 boundingBox], point))
    {
        _selectedTestObject = testObject3;
    }
    
    // Highlight only selected object with red.
    testObject1.color = ccWHITE;
    testObject2.color = ccWHITE;
    testObject3.color = ccWHITE;
    _selectedTestObject.color = ccRED;
}

#pragma mark CCLayerPanZoom Delegate Methods

- (void) layerPanZoom: (CCLayerPanZoom *) sender 
 touchPositionUpdated: (CGPoint) newPos
{
    [super layerPanZoom: sender touchPositionUpdated: newPos];
    
    _selectedTestObject.position = newPos;
}

- (void) layerPanZoom: (CCLayerPanZoom *) sender 
	   clickedAtPoint: (CGPoint) point
             tapCount: (NSUInteger) tapCount
{
    [self selectTestObjectAtPoint: point];
}

- (void) layerPanZoom: (CCLayerPanZoom *) sender touchMoveBeganAtPosition: (CGPoint) aPoint
{
    [super layerPanZoom:sender touchMoveBeganAtPosition:aPoint];    
    
    [self selectTestObjectAtPoint: aPoint];
    
     // Change anchorPoint & position of selectedTestObject to avoid jerky movement.
    if (_selectedTestObject)
    {
        CGFloat width = _selectedTestObject.contentSize.width;
        CGFloat height = _selectedTestObject.contentSize.height;
        
        CGPoint aPointInTestObjectCoordinates = [ _selectedTestObject convertToNodeSpace: [_panZoomLayer convertToWorldSpace: aPoint] ];
        CGPoint anchorPointInPoints = ccp( _selectedTestObject.anchorPoint.x * width, 
                                          _selectedTestObject.anchorPoint.y * height );
        CGPoint anchorShift = ccpSub(anchorPointInPoints, aPointInTestObjectCoordinates );
        _selectedTestObject.anchorPoint = ccp( (anchorPointInPoints.x - anchorShift.x )/ width, 
                                              (anchorPointInPoints.y - anchorShift.y) / height );
        _selectedTestObject.position = aPoint;
    }
}



@end

