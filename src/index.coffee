sysPath = require 'path'
fs = require 'fs'

module.exports = class HtmlAngularjsCompiler
  brunchPlugin: yes
  type: 'template'
  extension: 'html'
  pattern: /\.(?:html)$/

  constructor: (@config) ->
    null

  compile: (data, path, callback) ->
    try
      parsedHtml = @parseHtml(data)
      result = ".run(['$templateCache', function($templateCache){$templateCache.put('#{path}', '#{parsedHtml}')}])"
    catch err
      error = err
    finally
      callback error, result

  parseHtml: (str) ->
    return str.replace(/'/g, "\\'").replace(/\n/g, '')


  onCompile: (compiled) ->
    moduleName = @config.plugins?['html-angularjs-brunch']?.module or 'partials'
    filePaths = []
    filePaths.push(key) for key of @config.files.templates.joinTo
    pubDir = @config.paths.public

    for file in compiled
      for filePath in filePaths
        if file.path is "#{pubDir}/#{filePath}"
          data = fs.readFileSync(file.path)
          fs.writeFileSync(file.path, "angular.module('#{moduleName}', [])#{data};")