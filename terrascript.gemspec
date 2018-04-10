Gem::Specification.new do |s|
  s.name = "terrascript"
  s.version = "0.1.3"
  s.summary = "Terraform wrapper which adds Ruby scripting capabilities to your infrastructure"

  s.add_development_dependency "minitest"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-doc"
  s.add_development_dependency "rake"

  s.executables << "terrascript"

  s.files = [
    ".gitignore",
    "lib/terrascript.rb"
  ]

  s.authors = ["Marcin Chmiel"]
  s.email = "marcin.k.chmiel@gmail.com"
  s.homepage = "https://github.com/mewa/terrascript"
  s.license = "MIT"
end
