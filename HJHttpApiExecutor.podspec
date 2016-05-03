Pod::Spec.new do |s|

  s.name         = "HJHttpApiExecutor"
  s.version      = "1.2.0"
  s.summary      = "Simple and flexible communication module for HTTP based on Hydra framework."
  s.homepage     = "https://github.com/P9SOFT/HJHttpApiExecutor"
  s.license      = { :type => 'MIT' }
  s.author       = { "Tae Hyun Na" => "taehyun.na@gmail.com" }

  s.ios.deployment_target = '6.0'
  s.requires_arc = true

  s.source       = { :git => "https://github.com/P9SOFT/HJHttpApiExecutor.git", :tag => "1.2.0" }
  s.source_files  = "Sources/*.{h,m}"
  s.public_header_files = "Sources/*.h"

  s.dependency 'Hydra'
  s.dependency 'HJAsyncHttpDeliverer'

end
