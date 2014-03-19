# RBKeyboardManager

A keyboard manager designed to be sensible.

`RBKeyboardManager` is designed to be used with one scroll view.
It does not only manages the keyboard, but it also manages a text input accessory.
This text input accessory includes a previous, next and done button
and is provided by [DMFormInputAccessoryView](https://github.com/fumoboy007/DMFormInputAccessoryView).
The only thing you really need to do is give `RBKeyboardManager` is a `UIScrollView` and
an array of `UITextField`s and `UITexView`s, and `RBKeyboardManager` will do the rest.

Features:

* The next and previous button will only show views that are a subview of a `UIWindow`.
    That is, they are on screen.
* The done button will close the keyboard.
* Allows you to define a return key behaviour.

Currently, it has only been tested to work in portrait orientation.


## Installing

# CocoaPods

Since `RBKeyboardManager` is still under testing and the fact I am really lazy,
you cannot just add it to the pod file like so

    pod 'RBKeyboardManager', '~> 0.1.0'
    
instead, you have to

    pod 'RBKeyboardManager', {:git => 'https://github.com/NebulaFox/RBKeyboardManager.git'}

_TODO_

* Drag 'n' Drop

## Usage

### Basic Usage

Here you have an array of text fields and text views

    NSArray * textFieldsAndTextViews = @[ self.textField1, self.textField2, self.textView, self.textField31, self.textField32];
    
Start off by creating your keyboard manager by

    RBKeyboardManager * keyboardManager = [[RBKeyboardManager alloc] initWithScrollView:self.scrollView textFieldsAndTextViews:textFieldsAndTextViews];

Store it for later use

    self.keyboardManager = keyboardManager;
    
Then tell the keyboard manager to register for the keyboard notifications.

    [self.keyboardManager registerForKeyboardNotifications];

In great hierarchy of things, I recommended putting the registration for keyboard notifications
goes in `viewDidAppear:` and the deregistration of keyboard notifications in `viewWillDisappear:`

    - (void)viewDidAppear:(BOOL)animated
    {
        [super viewDidAppear:animated];
        
        [self.keyboardManager registerForKeyboardNotifications];
    }
    
    - (void)viewWillDisappear:(BOOL)animated
    {
        [super viewWillDisappear:animated];
        
        [self.keyboard deregisterForKeyboardNotifications];
    }

Build and Run. 

_TODO_: describe what is expected
   
   
### Return Key Usage

_TODO_ : Mention delegate


    - (UIReturnKeyType)returnKeyTypeForTextField:(UITextField *)textField
    {
        if ( textField == self.loginEmailField )
        {
            return UIReturnKeyNext;
        }
        else if ( textField == self.loginPasswordField )
        {
            return UIReturnKeyGo;
        }
    
        return UIReturnKeyDefault;
    }

    - (BOOL)keyboardManager:(RBKeyboardManager *)keyboardManager shouldReturnForTextField:(UITextField *)textField
    {
        if ( textField == self.loginEmailField )
        {
            [self.keyboardManager nextVisibleView];
        }
        else if ( textField == self.loginPasswordField )
        {
            [self _logIn];
        }
    
        return NO;
    }

You may find these methods useful.

> \- (void)nextVisibleView;
>
> Finds the next visible view to the active text field or text view and sets it as the first responder

> \- (void)previousVisibleView;
>
> Finds the previous visible view to the text field or text view and sets it as the first responder.

> \- (void)dismissKeyboard;
>
> Resigns as first responder for the active text field or text view, thus dismissing the keyboard.


### Force Position Example

_TODO_



    
