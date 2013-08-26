//
//  VKGLView.h
//  Asteroids
//
//  Created by kovtash on 25.08.13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "CC3GLMatrix.h"
#import "VKGLView.h"

@protocol VKGLObject;

@interface VKGLView : UIView
@property (strong, nonatomic) CC3GLMatrix *projection;
@property (readonly, nonatomic) CGSize glViewSize;

-(void) addGLObject:(id <VKGLObject>) glObject;
-(void) removeGLObject:(id <VKGLObject>) glObject;
@end
