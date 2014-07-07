//
//  RBKeyboardManager.m
//
//  Created by Robbie Bykowski on 17/03/2014.
//

#import "DMFormInputAccessoryView.h"

#import "RBKeyboardManager.h"

typedef NS_ENUM( NSUInteger, ForceBehaviour )
{
    ForceBehaviourNone = 0,
    ForceBehaviourPositon,
    ForceBehaviourContreOnArea,
    ForceBehaviourCentreOnView
};

@interface RBKeyboardManager () <UITextFieldDelegate, UITextViewDelegate, DMFormInputAccessoryViewDataSource>

@property ( nonatomic, assign ) CGFloat keyboardHeight;
@property ( nonatomic, assign ) ForceBehaviour forceBehaviour;
@property ( nonatomic, strong ) id forceObject;

@property ( nonatomic, strong ) UIScrollView * scrollView;
@property ( nonatomic, copy ) NSArray * textFieldsAndTextViews;
@property ( nonatomic, weak ) UIView * activeView;
@property ( nonatomic, strong ) DMFormInputAccessoryView * inputAccessoryView;

@end

@implementation RBKeyboardManager

#pragma mark - 'Structor

- (instancetype)initWithScrollView:(UIScrollView *)scrollView textFieldsAndTextViews:(NSArray *)textFieldsAndTextViews
{
    self = [super init];
    if ( self )
    {
        self.scrollView = scrollView;
        self.inputAccessoryView = [DMFormInputAccessoryView new];
        self.inputAccessoryView.dataSource = self;
        self.textFieldsAndTextViews = textFieldsAndTextViews;
        self.forceBehaviour = ForceBehaviourNone;
        
        [self.textFieldsAndTextViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ( [obj isKindOfClass:[UITextField class]] )
            {
                UITextField * textField = (UITextField *) obj;
                textField.delegate = self;
                textField.inputAccessoryView = self.inputAccessoryView;
            }
            else if ( [obj isKindOfClass:[UITextView class]] )
            {
                UITextView * textView = (UITextView *) obj;
                textView.delegate = self;
                textView.inputAccessoryView = self.inputAccessoryView;
            }
            else
            {
                @throw [NSException exceptionWithName:@"NotTextFieldOrTextViewError" reason:@"Array can only contain UITextFields and UITextViews" userInfo:nil];
            }
        }];
    }
    return self;
}

#pragma mark -

- (void)forcePositionWhenKeyboardShows:(CGPoint)position
{
    self.forceBehaviour = ForceBehaviourPositon;
    self.forceObject = [NSValue valueWithCGPoint:position];
}

- (void)forcePositionWhenKeyboardShowsCentreOnArea:(CGRect)area
{
    self.forceBehaviour = ForceBehaviourContreOnArea;
    self.forceObject = [NSValue valueWithCGRect:area];
}

- (void)forcePositionWhenKeyboardShowsCentreOnView:(UIView *)view
{
    self.forceBehaviour = ForceBehaviourCentreOnView;
    self.forceObject = view;
}

- (void)nextVisibleView
{
    UIResponder * nextVisibleView = [self _nextVisibleView];
    
    [nextVisibleView becomeFirstResponder];
}

- (void)previousVisibleView
{
    UIResponder * previousVisibleView = [self _previousVisibleView];
    
    [previousVisibleView becomeFirstResponder];
}

- (void)registerForKeyboardNotifications
{
    [RBKeyboardManager _preloadKeyboard];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)deregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)dismissKeyboard
{
    [self.activeView resignFirstResponder];
    self.activeView = nil;
}

#pragma mark - Notifications

- (void)keyboardDidShow:(NSNotification *)notification
{
    NSDictionary * info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat kbHeight = MIN(kbSize.width, kbSize.height) + self.inputAccessoryView.frame.size.height;
    self.keyboardHeight = kbHeight;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake( 0.0, 0.0, kbHeight, 0.0);
    [self _setContentInset:contentInsets];
    
    switch ( self.forceBehaviour )
    {
        case ForceBehaviourNone:
            [self _updateScrollOffset];
            break;
            
        case ForceBehaviourPositon:
            NSAssert([self.forceObject isKindOfClass:[NSValue class]], @"Expecting NSValue for forceObject");
            [self.scrollView setContentOffset:[self.forceObject CGPointValue] animated:YES];
            break;
            
        case ForceBehaviourContreOnArea:
            NSAssert([self.forceObject isKindOfClass:[NSValue class]], @"Expecting NSValue for forceObject");
            [self _scrollToCentreOfArea:[self.forceObject CGRectValue]];
            break;

        case ForceBehaviourCentreOnView:
            NSAssert([self.forceObject isKindOfClass:[UIView class]], @"Expecting UIView for forceObject");
            [self _scrollToCentreOfArea:[self.scrollView convertRect:[self.forceObject bounds] fromView:self.forceObject]];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.keyboardHeight = 0;
    [self _setContentInset:UIEdgeInsetsZero];
}

#pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ( [self.delegate respondsToSelector:@selector(returnKeyTypeForTextField:)])
    {
        textField.returnKeyType = [self.delegate returnKeyTypeForTextField:textField];
    }
    
    [self _updateActiveViewWithView:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeView = nil;
    self.inputAccessoryView.attachedResponder = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ( [self.delegate respondsToSelector:@selector(keyboardManager:shouldReturnForTextField:)])
    {
        return [self.delegate keyboardManager:self shouldReturnForTextField:textField];
    }
    
    return NO;
}

#pragma mark - Text View Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self _updateActiveViewWithView:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.activeView = nil;
}

#pragma mark - DM Form Input Accessory View Data Source

- (UIResponder *)previousResponderForFormInputAccessoryView:(DMFormInputAccessoryView *)formInputAccessoryView
{
    return [self _previousVisibleView];
}

- (UIResponder *)nextResponderForFormInputAccessoryView:(DMFormInputAccessoryView *)formInputAccessoryView
{
    return [self _nextVisibleView];
}

#pragma mark - Helpers

- (UIResponder *)_nextVisibleView
{
    __block UIResponder * nextResponder = nil;
    NSUInteger index = [self.textFieldsAndTextViews indexOfObject:self.activeView];
    NSRange range = NSMakeRange( index + 1, self.textFieldsAndTextViews.count - index - 1 );
    
    [self.textFieldsAndTextViews enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:0 usingBlock:^(UIView * obj, NSUInteger idx, BOOL *stop)
     {
         if ( obj.window != nil )
         {
             nextResponder = obj;
             *stop = YES;
         }
     }];
    
    return nextResponder;
}

- (UIResponder *)_previousVisibleView
{
    __block UIResponder * previousResponder = nil;
    NSUInteger index = [self.textFieldsAndTextViews indexOfObject:self.activeView];
    NSRange range;
    
    if ( index != NSNotFound )
    {
        range = NSMakeRange( 0, index );
        [self.textFieldsAndTextViews enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:NSEnumerationReverse usingBlock:^(UIView * obj, NSUInteger idx, BOOL *stop)
         {
             if ( obj.window != nil )
             {
                 previousResponder = obj;
                 *stop = YES;
             }
         }];
    }
    
    return previousResponder;
}

- (void)_updateActiveViewWithView:(UIView *)view
{
    if ( [self.textFieldsAndTextViews containsObject:view] )
    {
        self.activeView = view;
        self.inputAccessoryView.attachedResponder = self.activeView;
        [self.inputAccessoryView reloadData];
        
        [self _updateScrollOffset];
    }
}

- (void)_updateScrollOffset
{
    NSAssert(self.activeView != nil, @"the keyboard cannot be show with no active view");
    
    // if the active field is hidden, move it up
    //UIView * view = self.scrollView;
    CGRect r = [self _viewableFrame];
    CGRect ar = [self _frameContainingMostTextFieldsAndTextViews];
    
    CGPoint currentScrollPoint = self.scrollView.contentOffset;
    
    //CGRect ar = [view convertRect:self.activeView.bounds fromView:self.activeView]; // the area of the active view in relation to the scroll view
    //ar.size.height = 44.0;
    
    if ( ! CGRectContainsRect( r, ar ) )
    {
        // active view is not contained in the displayed area
        
        CGFloat difference = 0.0;
        
        if ( ar.origin.y < r.origin.y )
        {
            difference = ar.origin.y - r.origin.y;
        }
        else if ( CGRectGetMaxY(r) < ar.origin.y )
        {
            difference = ar.origin.y - (CGRectGetMaxY(r) - ar.size.height);
        }
        else if ( CGRectGetMaxY(r) < CGRectGetMaxY(ar) )
        {
            difference = (CGRectGetMaxY(ar) - CGRectGetMaxY(r));
        }
        
        CGPoint scrollPoint = CGPointMake( 0.0, currentScrollPoint.y + difference );
        [self _setContentOffset:scrollPoint];
    }
}

- (CGRect)_viewableFrame
{
    CGRect r = self.scrollView.bounds;
    r.origin = self.scrollView.contentOffset;
    r.size.height -= self.keyboardHeight;
    // TODO: doesn't adjustInset need to be here?
    return r;
}

- (CGRect)_frameContainingMostTextFieldsAndTextViews
{
    NSInteger index = [self.textFieldsAndTextViews indexOfObject:self.activeView];
    NSInteger topIndex = index - 1;
    NSInteger bottomIndex = index + 1;
    
    NSUInteger count = [self.textFieldsAndTextViews count];
    CGRect viewableFrame = [self _viewableFrame];
    CGRect frame = [self.scrollView convertRect:self.activeView.bounds fromView:self.activeView];
    
    BOOL found = frame.size.height > viewableFrame.size.height;
    
    while ( ! found )
    {
        if (topIndex >= 0)
        {
            UIView * v = self.textFieldsAndTextViews[topIndex];
            CGRect vFrame = [self.scrollView convertRect:v.bounds fromView:v];
            CGRect newFrame = CGRectUnion(frame, vFrame);
            
            if (newFrame.size.height > viewableFrame.size.height)
            {
                // new frame is bigger than the viewable frame
                found = YES;
            }
            else
            {
                frame = newFrame;
                topIndex--;
            }
        }
        
        if (! found && bottomIndex < count)
        {
            UIView * v = self.textFieldsAndTextViews[bottomIndex];
            CGRect vFrame = [self.scrollView convertRect:v.bounds fromView:v];
            CGRect newFrame = CGRectUnion(frame, vFrame);
            
            if (newFrame.size.height > viewableFrame.size.height)
            {
                // new frame is bigger than the viewable frame
                found = YES;
            }
            else
            {
                frame = newFrame;
                bottomIndex++;
            }
        }
        
        if (! found && topIndex < 0 && bottomIndex >= count)
        {
            // all views have been exhausted
            found = YES;
        }
    }
    
    return frame;
}

// even though these setters would normally run on the main thread
// I found an instance where it would no update the scroll view
// I am explitely forcing

- (void)_setContentOffset:(CGPoint)contentOffset
{
    dispatch_async( dispatch_get_main_queue(), ^{
        [self.scrollView setContentOffset:contentOffset animated:YES];
    });
}

- (void)_setContentInset:(UIEdgeInsets)contentInsets
{
    dispatch_async( dispatch_get_main_queue(), ^{
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
    });
}

- (void)_scrollToCentreOfArea:(CGRect)area
{
    CGRect viewableBounds = [self _viewableFrame];
    CGRect viewBounds = area;
    
    CGPoint contentOffset;
    
    contentOffset.x = 0;
    contentOffset.y = viewBounds.origin.y - ( viewableBounds.size.height - viewBounds.size.height ) * 0.5;
    
    if ( self.scrollView.bounds.size.width > [UIScreen mainScreen].bounds.size.width )
    {
        // centre on x as well
        contentOffset.x = viewableBounds.origin.x + ( viewableBounds.size.width * 0.5 - viewBounds.size.width * 0.5 );
    }
    
    dispatch_async( dispatch_get_main_queue(), ^{
        [self.scrollView setContentOffset:contentOffset animated:YES];
    });
}

#pragma mark - Static

+ (void)_preloadKeyboard
{
    static BOOL hasPreloaded = NO;
    if (! hasPreloaded && floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        UIWindow * window = [[UIApplication sharedApplication].windows firstObject];
        
        UITextField *lagFreeField = [[UITextField alloc] init];
        [window addSubview:lagFreeField];
        [lagFreeField becomeFirstResponder];
        [lagFreeField resignFirstResponder];
        [lagFreeField removeFromSuperview];
        
        hasPreloaded = YES;
    }
}

@end
