# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'bundler' do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end

guard 'minitest' do
  # with Minitest::Unit
  watch(%r|^test/(.*)\/?(.*)\_test.rb|)
  watch(%r|^lib/(.*)([^/]+)\.rb|)     { |m| "test/lib/#{m[1]}#{m[2]}_test.rb" }
  watch(%r|^lib/core_ext/(.*)([^/]+)\.rb|)     { |m| "test/lib/core_ext/#{m[1]}#{m[2]}_test.rb" }
  watch(%r|^test/test_helper\.rb|)    { "test" }
end
