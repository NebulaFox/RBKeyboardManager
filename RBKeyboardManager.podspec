
Pod::Spec.new do |spec|
  spec.name              = "RBKeyboardManager"
  spec.version           = "0.5.0"
  spec.summary           = "A keyboard manager designed to be sensible"
  spec.description       = <<-DESC
                            `RBKeyboardManager` is designed to be used with one scroll view.
                            It does not only manages the keyboard, but it also manages a text input accessory.
                            This text input accessory includes a previous, next and done button
                            and is provided by [DMFormInputAccessoryView](https://github.com/fumoboy007/DMFormInputAccessoryView).
                            The only thing you really need to do is give `RBKeyboardManager` is a `UIScrollView` and
                            an array of `UITextField`s and `UITexView`s, and `RBKeyboardManager` will do the rest.
                            DESC
  spec.license          = { :type => 'NCSA', :license => 'LICENSE.md' }
  spec.homepage         = "https://github.com/NebulaFox/RBKeyboardManager"

  spec.author           = { "Robbie Bykowski" => "robbie.bykowski@heliumend.co.uk" }
  spec.social_media_url = "http://twitter.com/NebulaFox"

  spec.platform         = :ios, '6.0'
  spec.source           = { :git => "https://github.com/NebulaFox/RBKeyboardManager.git" }
  spec.source_files     = 'RBKeyboardManager/*.{h,m}', 'DMFormInputAccessoryView/*.{h,m}'
  spec.requires_arc     = true
end
