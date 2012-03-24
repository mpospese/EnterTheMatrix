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

#endif
