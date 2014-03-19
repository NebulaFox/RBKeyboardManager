//
//  RBKeyboardManager.h
//
//  Created by Robbie Bykowski on 17/03/2014.
//

#import <UIKit/UIKit.h>

@class RBKeyboardManager;

@protocol  RBKeyboardManagerDelegate <NSObject>

@optional

- (UIReturnKeyType)returnKeyTypeForTextField:(UITextField *)textField;

- (BOOL)keyboardManager:(RBKeyboardManager *)keyboardManager shouldReturnForTextField:(UITextField *)textField;

@end

@interface RBKeyboardManager : NSObject

@property ( nonatomic, weak ) id <RBKeyboardManagerDelegate> delegate;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView textFieldsAndTextViews:(NSArray *)textFieldsAndTextViews;


/**
 When the keyboard appears it scrolls to the set position
 
 This will be overriden by `forcePositionWhenKeyboardShowsCentreOnView:`
 This will be overriden by `forcePositionWhenKeyboardShowsCentreOnArea:`
 
 @param position The position in the scroll view to scroll to
 */
- (void)forcePositionWhenKeyboardShows:(CGPoint)position;

/**
 When the keyboard appears it scrolls to a position that places
 the area in the centre of the remaining visible space.
 The area must be in the scroll view coordinates.
 
 This will be overriden by `forcePositionWhenKeyboardShows:`
 This will be overriden by `forcePositionWhenKeyboardShowsCentreOnView:`
 
 @param area The area to be centred on
 */
- (void)forcePositionWhenKeyboardShowsCentreOnArea:(CGRect)area;

/**
 When the keyboard appears it scrolls to a position that places
 the view in the centre of the remaining visible space.
 
 This will be overriden by `forcePositionWhenKeyboardShows:`
 This will be overriden by `forcePositionWhenKeyboardShowsCentreOnArea:`
 
 @param view The view to be centred on
 */
- (void)forcePositionWhenKeyboardShowsCentreOnView:(UIView *)view;


/**
 Finds the next visible view to the active text field or text view
 and sets it as the first responder
 */
- (void)nextVisibleView;

/** 
 Finds the previous visible view to the text field or text view
 and sets it as the first responder.
 */
- (void)previousVisibleView;

/**
 Resigns as first responder for the active text field or text view,
 thus dismissing the keyboard.
 */
- (void)dismissKeyboard;

/**
 Register for `UIKeyboardDidShowNotification` and `UIKeyboardWillHideNotification`
 */
- (void)registerForKeyboardNotifications;

/**
 Deregister for `UIKeyboardDidShowNotification` and `UIKeyboardWillHideNotification`
 */
- (void)deregisterForKeyboardNotifications;

@end
