//
//  VKGLObject.h
//  Asteroids
//
//  Created by kovtash on 25.08.13.
//
//

#import <Foundation/Foundation.h>
#import "VKGLView.h"

@class VKGLView;
@protocol VKGLObject <NSObject>
@property (strong ,nonatomic) VKGLView *glView;
- (void) render;
@end
