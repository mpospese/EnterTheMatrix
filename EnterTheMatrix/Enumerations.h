//
//  Enumerations.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 2/27/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#ifndef EnterTheMatrix_Enumerations_h
#define EnterTheMatrix_Enumerations_h

typedef enum {
	TransformSkew,
	TransformTranslate,
	TransformScale,
	TransformRotate
} TransformOperation;

typedef enum {
	AnchorPointTopLeft,
	AnchorPointTopCenter,
	AnchorPointTopRight,
	AnchorPointMiddleLeft,
	AnchorPointCenter,
	AnchorPointMiddleRight,
	AnchorPointBottomLeft,
	AnchorPointBottomCenter,
	AnchorPointBottomRight
} AnchorPointLocation;

typedef enum {
	SkewModeInverse,
	SkewModeNone,
	SkewModeLow,
	SkewModeNormal,
	SkewModeHigh
} SkewMode;

typedef enum {
	DurationMultiplier1x,
	DurationMultiplier2x,
	DurationMultiplier5x,
	DurationMultiplier10x
} DurationMultiplier;


#endif
