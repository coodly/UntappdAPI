Pod::Spec.new do |s|
  s.name = 'UntappdAPI'
  s.version = '0.1.0'
  s.license = 'Apache 2'
  s.summary = 'Untappd API in Swift'
  s.homepage = 'https://github.com/coodly/UntappdAPI'
  s.authors = { 'Jaanus Siim' => 'jaanus@coodly.com' }
  s.source = { :git => 'git@github.com:coodly//UntappdAPI.git', :tag => s.version }

  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '12.0'
  s.osx.deployment_target = '10.11'

  s.source_files = 'Sources/UntappdAPI/*.swift'

  s.requires_arc = true
end
