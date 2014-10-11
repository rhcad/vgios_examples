//
//  WDUtilities.m
//  Inkpad
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2008-2013 Steve Sprang
//

#if TARGET_OS_MAC
#import <UIKit/UIKit.h>
#endif

#import "WDUtilities.h"
#include <CommonCrypto/CommonHMAC.h>

#define kMiterLimit 10

#pragma mark -
#pragma mark Drawing Functions

void WDDrawCheckersInRect(CGContextRef ctx, CGRect dest, int size)
{
    CGRect  square = CGRectMake(0, 0, size, size);
    float   startx = CGRectGetMinX(dest);
    float   starty = CGRectGetMinY(dest);
    
    CGContextSaveGState(ctx);
    CGContextClipToRect(ctx, dest);
    
    CGContextSetGrayFillColor(ctx, 0.9f, 1.0f);
    CGContextFillRect(ctx, dest);
    
    CGContextSetGrayFillColor(ctx, 0.78f, 1.0f);
    for (int y = 0; y * size < CGRectGetHeight(dest); y++) {
        for (int x = 0; x * size < CGRectGetWidth(dest); x++) {
            if ((y + x) % 2) {
                square.origin.x = startx + x * size;
                square.origin.y = starty + y * size;
                CGContextFillRect(ctx, square);
            }
        }
    }
    
    CGContextRestoreGState(ctx);
}

void WDDrawTransparencyDiamondInRect(CGContextRef ctx, CGRect dest)
{
    float   minX = CGRectGetMinX(dest);
    float   maxX = CGRectGetMaxX(dest);
    float   minY = CGRectGetMinY(dest);
    float   maxY = CGRectGetMaxY(dest);
    
    // preserve the existing color
    CGContextSaveGState(ctx);
    [[UIColor whiteColor] set];
    CGContextFillRect(ctx, dest);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, minX, minY);
    CGPathAddLineToPoint(path, NULL, maxX, minY);
    CGPathAddLineToPoint(path, NULL, minX, maxY);
    CGPathCloseSubpath(path);
    
    [[UIColor blackColor] set];
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
    
    CGPathRelease(path);
}

void WDContextDrawImageToFill(CGContextRef ctx, CGRect bounds, CGImageRef imageRef)
{
    size_t  width = CGImageGetWidth(imageRef);
    size_t  height = CGImageGetHeight(imageRef);
    float   wScale = CGRectGetWidth(bounds) / width;
    float   hScale = CGRectGetHeight(bounds) / height;
    float   scale = MAX(wScale, hScale);
    float   hOffset = 0.0f, vOffset = 0.0f;
    
    CGRect  rect = CGRectMake(0, 0, width * scale, height * scale);
    
    if (CGRectGetWidth(rect) > CGRectGetWidth(bounds)) {
        hOffset = CGRectGetWidth(rect) - CGRectGetWidth(bounds);
        hOffset /= -2;
    }
    
    if (CGRectGetHeight(rect) > CGRectGetHeight(bounds)) {
        vOffset = CGRectGetHeight(rect) - CGRectGetHeight(bounds);
        vOffset /= -2;
    }
    
    rect = CGRectOffset(rect, hOffset, vOffset);
    
    CGContextDrawImage(ctx, rect, imageRef);
}

#pragma mark -
#pragma mark Mathy Stuff

float WDSineCurve(float input)
{
    float result;
    
    input *= M_PI; // move from [0.0, 1.0] tp [0.0, Pi]
    input -= M_PI_2; // shift back onto a trough
    
    result = sin(input) + 1; // add 1 to put in range [0.0,2.0]
    result /= 2; // back to [0.0, 1.0];
    
    return result;
}

float WDRandomFloat()
{
    float r = random() % 10000;
    return r / 10000.0f;
}

NSData * WDSHA1DigestForData(NSData *data)
{
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, NULL, 0, [data bytes], [data length], cHMAC);
    
    return [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
}

#pragma mark -
#pragma mark Geometry

CGSize WDSizeOfRectWithAngle(CGRect rect, float angle, CGPoint *upperLeft, CGPoint *upperRight)
{
    CGPoint center, corners[4];
    
    center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle * M_PI / 180.0f);
    
    corners[0] = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    corners[1] = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    corners[2] = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    corners[3] = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    
    for (int i = 0; i < 4; i++) {
        corners[i] = CGPointApplyAffineTransform(corners[i], transform);
    }
    center = CGPointApplyAffineTransform(center, transform);
    
    float minx = corners[0].x;
    float maxx = corners[0].x;
    float miny = corners[0].y;
    float maxy = corners[0].y;
    
    for (int i = 1; i < 4; i++) {
        minx = MIN(minx, corners[i].x);
        maxx = MAX(maxx, corners[i].x);
        miny = MIN(miny, corners[i].y);
        maxy = MAX(maxy, corners[i].y);
    }
    
    if (upperLeft) {
        *upperLeft = WDSubtractPoints(corners[0], center);
    }
    
    if (upperRight) {
        *upperRight = WDSubtractPoints(corners[3], center);
    }
    
    return CGSizeMake(maxx - minx, maxy - miny);
}

CGPoint WDNormalizePoint(CGPoint vector)
{
    float distance = WDDistance(CGPointZero, vector);
    
    if (distance == 0.0f) {
        return vector;
    }
    
    return WDMultiplyPointScalar(vector, 1.0f / distance);
}

CGRect WDGrowRectToPoint(CGRect rect, CGPoint pt)
{
    double minX, minY, maxX, maxY;
    
    minX = MIN(CGRectGetMinX(rect), pt.x);
    minY = MIN(CGRectGetMinY(rect), pt.y);
    maxX = MAX(CGRectGetMaxX(rect), pt.x);
    maxY = MAX(CGRectGetMaxY(rect), pt.y);
    
    return CGRectUnion(rect, CGRectMake(minX, minY, maxX - minX, maxY - minY));
}

CGPoint WDSharpPointInContext(CGPoint pt, CGContextRef ctx)
{
    pt = CGContextConvertPointToDeviceSpace(ctx, pt);
    pt = WDFloorPoint(pt);
    pt = WDAddPoints(pt, CGPointMake(0.5f, 0.5f));
    pt = CGContextConvertPointToUserSpace(ctx, pt);
    
    return pt;
}

CGPoint WDConstrainPoint(CGPoint delta)
{
    float   angle = atan2(delta.y, delta.x);
    float   magnitude = WDDistance(delta, CGPointZero);
    
    angle = roundf(angle / M_PI_4) * M_PI_4;
    delta.x = cos(angle) * magnitude;
    delta.y = sin(angle) * magnitude;
    
    return delta;
}

CGRect WDRectFromPoint(CGPoint a, float width, float height)
{
    return CGRectMake(a.x - (width / 2), a.y - (height / 2), width, height);
}

BOOL WDCollinear(CGPoint a, CGPoint b, CGPoint c)
{
    float temp, distances[3];
    
    distances[0] = WDDistance(a, b);
    distances[1] = WDDistance(b, c);
    distances[2] = WDDistance(a, c);

    // sort the array...
    if (distances[0] > distances[1]) {
        temp = distances[1];
        distances[1] = distances[0];
        distances[0] = temp;
    }
    
    if (distances[1] > distances[2]) {
        temp = distances[2];
        distances[2] = distances[1];
        distances[1] = temp;
    }
    
    // if the points are collinear, the sum of the shortest 2 distances is equal to the longest distance
    float shortestSum = distances[0] + distances[1];
    float difference = fabs(shortestSum - distances[2]);
    
    return (difference < 1.0e-4);
}

BOOL WDLineSegmentsIntersectWithValues(CGPoint A, CGPoint B, CGPoint C, CGPoint D, float *rV, float *sV)
{
    float denom = (B.x - A.x) * (D.y - C.y) - (B.y - A.y) * (D.x - C.x);
    
    if (denom == 0) {
        return NO;
    }
    
    float r = (A.y - C.y) * (D.x - C.x) - (A.x - C.x) * (D.y - C.y);
    r /= denom;
    
    float s = (A.y - C.y) * (B.x - A.x) - (A.x - C.x) * (B.y - A.y);
    s /= denom;
    
    if (rV) {
        *rV = r;
    }
    
    if (sV) {
        *sV = s;
    }
    
    return (r < 0 || r > 1 || s < 0 || s > 1) ? NO : YES;;
}

BOOL WDLineSegmentsIntersect(CGPoint A, CGPoint B, CGPoint C, CGPoint D)
{
    return WDLineSegmentsIntersectWithValues(A, B, C, D, NULL, NULL);
}

CGRect WDShrinkRect(CGRect rect, float percentage)
{
    float   widthInset = CGRectGetWidth(rect) * percentage;
    float   heightInset = CGRectGetHeight(rect) * percentage;
    
    return CGRectInset(rect, widthInset, heightInset);
}

CGSize WDClampSize(CGSize size, float maxDimension)
{
    if (size.width > maxDimension || size.height > maxDimension) {
        if (size.width > size.height) {
            size.height = (size.height / size.width) * maxDimension;
            size.width = maxDimension;
        } else {
            size.width = (size.width / size.height) * maxDimension;
            size.height = maxDimension;
        }
    }
    
    return size;
}

#pragma mark -
#pragma mark Paths

void convertQuadraticPathElement(void *info, const CGPathElement *element)
{
    CGMutablePathRef    converted = (CGMutablePathRef) info;
    CGPoint             prev;
    
    switch (element->type) {
        case kCGPathElementMoveToPoint:
            CGPathMoveToPoint(converted, NULL, element->points[0].x, element->points[0].y);
            break;
        case kCGPathElementAddLineToPoint:
            CGPathAddLineToPoint(converted, NULL, element->points[0].x, element->points[0].y);
            break;
        case kCGPathElementAddQuadCurveToPoint:
            prev = CGPathGetCurrentPoint(converted);
            
            // convert quadratic to cubic: http://fontforge.sourceforge.net/bezier.html
            CGPoint outPoint = WDAddPoints(prev, WDMultiplyPointScalar(WDSubtractPoints(element->points[0], prev), 2.0f / 3));
            CGPoint inPoint = WDAddPoints(element->points[1], WDMultiplyPointScalar(WDSubtractPoints(element->points[0], element->points[1]), 2.0f / 3));
            
            CGPathAddCurveToPoint(converted, NULL, outPoint.x, outPoint.y, inPoint.x, inPoint.y, element->points[1].x, element->points[1].y);
            break;
        case kCGPathElementAddCurveToPoint:
            CGPathAddCurveToPoint(converted, NULL, element->points[0].x, element->points[0].y, element->points[1].x, element->points[1].y, element->points[2].x, element->points[2].y);
            break;
        case kCGPathElementCloseSubpath:
            CGPathCloseSubpath(converted);
            break;
    }
}

CGPathRef WDCreateCubicPathFromQuadraticPath(CGPathRef pathRef)
{
    CGMutablePathRef converted = CGPathCreateMutable();
        
    CGPathApply(pathRef, converted, &convertQuadraticPathElement);
    
    return converted;
}

typedef struct {
    CGMutablePathRef mutablePath;
    CGAffineTransform transform;
} WDPathAndTransform;

void transformPathElement(void *info, const CGPathElement *element)
{
    WDPathAndTransform  pathAndTransform = *((WDPathAndTransform *) info);
    CGAffineTransform   transform = pathAndTransform.transform;
    CGMutablePathRef    pathRef = pathAndTransform.mutablePath;
    
    switch (element->type) {
        case kCGPathElementMoveToPoint:
            CGPathMoveToPoint(pathRef, &transform, element->points[0].x, element->points[0].y);
            break;
        case kCGPathElementAddLineToPoint:
            CGPathAddLineToPoint(pathRef, &transform, element->points[0].x, element->points[0].y);
            break;
        case kCGPathElementAddQuadCurveToPoint:
            CGPathAddQuadCurveToPoint(pathRef, &transform, element->points[0].x, element->points[0].y, element->points[1].x, element->points[1].y);
            break;
        case kCGPathElementAddCurveToPoint:
            CGPathAddCurveToPoint(pathRef, &transform, element->points[0].x, element->points[0].y, element->points[1].x, element->points[1].y, element->points[2].x, element->points[2].y);
            break;
        case kCGPathElementCloseSubpath:
            CGPathCloseSubpath(pathRef);
            break;
            
    }
}

CGPathRef WDCreateTransformedCGPathRef(CGPathRef pathRef, CGAffineTransform transform)
{
    CGMutablePathRef    transformedPath = CGPathCreateMutable();
    WDPathAndTransform  pathAndTransform = {transformedPath, transform};
    
    CGPathApply(pathRef, &pathAndTransform, &transformPathElement);
    
    return transformedPath;
}

#pragma mark -
#pragma mark WDQuad

WDQuad WDQuadNull()
{
    CGPoint bogusPoint = CGPointMake(INFINITY, INFINITY);
    return WDQuadMake(bogusPoint, bogusPoint, bogusPoint, bogusPoint);
}

WDQuad WDQuadMake(CGPoint a, CGPoint b, CGPoint c, CGPoint d)
{
    WDQuad quad;
    
    quad.corners[0] = a;
    quad.corners[1] = b;
    quad.corners[2] = c;
    quad.corners[3] = d;
    
    return quad;
}

WDQuad WDQuadWithRect(CGRect rect, CGAffineTransform transform)
{
    WDQuad quad;
    
    quad.corners[0] = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    quad.corners[1] = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    quad.corners[2] = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    quad.corners[3] = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    
    for (int i = 0; i < 4; i++) {
        quad.corners[i] = CGPointApplyAffineTransform(quad.corners[i], transform);
    }
    
    return quad;
}

BOOL WDQuadEqualToQuad(WDQuad a, WDQuad b)
{
    for (int i = 0; i < 4; i++) {
        if (!CGPointEqualToPoint(a.corners[i], b.corners[i])) {
            return NO;
        }
    }
    
    return YES;
}

BOOL WDQuadIntersectsQuad(WDQuad a, WDQuad b)
{
    WDQuad nullQuad = WDQuadNull();
    if (WDQuadEqualToQuad(a, nullQuad) || WDQuadEqualToQuad(b, nullQuad)) {
        return NO;
    }
    
    for (int i = 0; i < 4; i++) {
        for (int n = 0; n < 4; n++) {
            if (WDLineSegmentsIntersect(a.corners[i], a.corners[(i+1)%4], b.corners[n], b.corners[(n+1)%4])) {
                return YES;
            }
        }
    }
    
    return NO;
}

NSString * NSStringFromWDQuad(WDQuad quad)
{
    return [NSString stringWithFormat:@"{{%@}, {%@}, {%@}, {%@}}", NSStringFromCGPoint(quad.corners[0]), NSStringFromCGPoint(quad.corners[1]),
            NSStringFromCGPoint(quad.corners[2]), NSStringFromCGPoint(quad.corners[3])];
}

CGPathRef WDCreateQuadPathRef(WDQuad q)
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    CGPathMoveToPoint(pathRef, NULL, q.corners[0].x, q.corners[0].y);
    for (int i = 1; i < 4; i++) {
        CGPathAddLineToPoint(pathRef, NULL, q.corners[i].x, q.corners[i].y);
    }
    CGPathCloseSubpath(pathRef);
    
    return pathRef;
}

BOOL WDDeviceIsPhone()
{
    static BOOL isPhone;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        isPhone = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? YES : NO;
    });
    
    return isPhone;
}
