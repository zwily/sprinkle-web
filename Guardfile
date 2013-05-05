# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :shell do
  watch(%r{^app/(?!application.js|index.js|templates.js)}) { |m|
    n m[0], "changed"
    `ember build`
  }
end
