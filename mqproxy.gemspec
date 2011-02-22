Gem::Specification.new do |s|
  s.name = %q{mqproxy}
  s.version = '1.1.0'
  s.author = "Christopher Brady"
  s.email = 'chris@bradynet.net'
  s.date = %{2011-02-22}
  s.homepage = %q{http://github.com/cbrady/MQ-Proxy}
  s.description = %q{A wrapper for the MapQuest API, provides ability to get route and to geocode an address}
  s.summary = %q{A wrapper for the MapQuest API, provides ability to get route and to geocode an address}
  s.require_paths = ['lib']
  s.has_rdoc = true
  s.files = ['lib/mqproxy.rb','MIT-LICENSE','Rakefile','README.rdoc','test/mqproxy_test.rb','test/test_helper.rb']
  s.test_files = ['test/mqproxy_test.rb']
  s.rubygems_version = %q{1.3.1}
  s.add_dependency('json')
end