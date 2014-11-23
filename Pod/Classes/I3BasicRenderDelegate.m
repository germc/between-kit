//
//  I3BasicRenderDelegate.m
//  Pods
//
//  Created by Stephen Fortune on 21/09/2014.
//
//

#import "I3BasicRenderDelegate.h"
#import "I3Logging.h"


@interface I3BasicRenderDelegate ()


/**
 
 Private method that renders a drop from one collection onto another. This is called on both
 appendation and exchange.
 
 */
-(void) renderDropOnCollection:(id<I3Collection>) dstCollection atPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator;


@end



/// @todo Remove all the code duplication here; lots of methods calculate rects and points
///       from common objects in the same way.

@implementation I3BasicRenderDelegate


-(id) init{

    self = [super init];
    
    if(self){
    
        _draggingItemOpacity = 0.01;
        _draggingViewOpacity = 1;
        
    }

    return self;
}


-(void) renderDragStart:(I3GestureCoordinator *)coordinator{
    
    id<I3Collection> draggingCollection = coordinator.currentDraggingCollection;
    CGPoint dragOrigin = coordinator.currentDragOrigin;
    
    UIView *sourceView = [draggingCollection itemAtPoint:dragOrigin];
    UIView *collectionView = draggingCollection.collectionView;
        
    _draggingView = [[I3CloneView alloc] initWithSourceView:sourceView];
    _draggingView.frame = [coordinator.arena.superview convertRect:sourceView.frame fromView:collectionView];
    _draggingView.alpha = _draggingViewOpacity;
    [coordinator.arena.superview addSubview:_draggingView];
    [_draggingView cloneSourceView];
    
    sourceView.alpha = _draggingItemOpacity;
}


-(void) renderDraggingFromCoordinator:(I3GestureCoordinator *)coordinator{
    
    [UIView animateWithDuration:0.05 animations:^{
        self.draggingView.center = [coordinator.gestureRecognizer locationInView:coordinator.arena.superview];
    }];
}


-(void) renderResetFromPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator{
    
    UIView *sourceView = [coordinator.currentDraggingCollection itemAtPoint:coordinator.currentDragOrigin];
    UIView *collectionView = coordinator.currentDraggingCollection.collectionView;

    CGRect dragOriginFrame = [coordinator.arena.superview convertRect:sourceView.frame fromView:collectionView];
    I3CloneView *draggingView = _draggingView;
    
    [UIView animateWithDuration:0.15 animations:^{

        draggingView.frame = dragOriginFrame;
    
    } completion:^(BOOL finished){
        
        [draggingView removeFromSuperview];
        sourceView.alpha = 1;
        
    }];

    _draggingView = nil;
    
}


-(void) renderRearrangeOnPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator{
    
    id<I3Collection> draggingCollection = coordinator.currentDraggingCollection;
    CGPoint dragOrigin = coordinator.currentDragOrigin;
    
    UIView *collectionView = draggingCollection.collectionView;
    UIView *superview = coordinator.arena.superview;
    
    UIView *dstSourceView = [draggingCollection itemAtPoint:at];
    UIView *sourceView = [draggingCollection itemAtPoint:dragOrigin];
    
    
    I3CloneView *exchangeView = [[I3CloneView alloc] initWithSourceView:dstSourceView];
    exchangeView.frame = [superview convertRect:dstSourceView.frame fromView:collectionView];
    [superview addSubview:exchangeView];
    [exchangeView cloneSourceView];
    
    I3CloneView *draggingView = _draggingView;
    [superview bringSubviewToFront:draggingView];

    CGRect dragOriginFrame = [superview convertRect:sourceView.frame fromView:collectionView];
    CGPoint draggingViewTargetCenter = CGPointMake(CGRectGetMidX(exchangeView.frame), CGRectGetMidY(exchangeView.frame));
    CGPoint exchangeViewTargetCenter = CGPointMake(CGRectGetMidX(dragOriginFrame), CGRectGetMidY(dragOriginFrame));
    
    
    [UIView animateWithDuration:0.15 animations:^{
        
        draggingView.center = draggingViewTargetCenter;
        exchangeView.center = exchangeViewTargetCenter;
        
    } completion:^(BOOL finished) {
        
        [exchangeView removeFromSuperview];
        [draggingView removeFromSuperview];
        
    }];

    _draggingView = nil;
    
    /// @note When would be need to re-show the item?
    /// @note Can we hide both the dragging and the exchange items while the animation plays out ?
    
}


-(void) renderDeletionAtPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator{

    I3CloneView *draggingView = self.draggingView;
    
    CGFloat midX = CGRectGetMidX(draggingView.frame);
    CGFloat midY = CGRectGetMidY(draggingView.frame);
    CGRect shrunkFrame = CGRectMake(midX, midY, 0, 0);
    
    [UIView animateWithDuration:0.15 animations:^{
    
        draggingView.frame = shrunkFrame;
        
    } completion:^(BOOL finished){
        
        [draggingView removeFromSuperview];
    
    }];
    
    _draggingView = nil;
    
}


-(void) renderExchangeToCollection:(id<I3Collection>) dstCollection atPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator{
    [self renderDropOnCollection:dstCollection atPoint:at fromCoordinator:coordinator];
}


-(void) renderAppendToCollection:(id<I3Collection>)dstCollection atPoint:(CGPoint)at fromCoordinator:(I3GestureCoordinator *)coordinator{
    [self renderDropOnCollection:dstCollection atPoint:at fromCoordinator:coordinator];
}


#pragma mark - Private methods


-(void) renderDropOnCollection:(id<I3Collection>) dstCollection atPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator{
    
    [_draggingView removeFromSuperview];
    _draggingView = nil;
    
    id<I3Collection> draggingCollection = coordinator.currentDraggingCollection;
    CGPoint dragOrigin = coordinator.currentDragOrigin;

    UIView *sourceView = [draggingCollection itemAtPoint:dragOrigin];
    sourceView.alpha = 1;

}

@end
