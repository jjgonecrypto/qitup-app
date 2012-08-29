# CoffeeScript and Stylus watch/build cakefile
{spawn, exec} = require 'child_process'

runCommand = (name, args...) ->
	proc =           spawn name, args
	proc.stderr.on   'data', (buffer) -> console.log buffer.toString()
	proc.stdout.on   'data', (buffer) -> console.log buffer.toString()
	proc.on          'exit', (status) -> process.exit(1) if status isnt 0

task 'watch', 'Watch source files and build JS & CSS', (options) ->
  runCommand 'coffee', '-wc', '--lint', '-o', 'scripts/js/', 'scripts/coffee/'
  runCommand 'stylus', '-w', 'styles/stylus', '-o', 'styles/css'

task 'test', 'Run the testing suite', (options) ->
  runCommand './node_modules/mocha/bin/mocha', '--compilers', 'coffee:coffee-script', '--colors', '--recursive'