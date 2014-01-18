$LOAD_PATH.unshift File.dirname(File.expand_path(__FILE__))

require 'heroku'
require 'heroku/command/fork'
require 'heroku/command/run'
require 'heroku/client/pgbackups'


@args = ARGV
raise "Not enough args" if @args.length < 3
original_repo_name = @args[0]
new_repo_name = @args[1]
branch_name = @args[2]

Heroku::Command.run("fork", %W"-a #{original_repo_name} #{new_repo_name}")

system "git push -f git@heroku.com:#{new_repo_name}.git #{branch_name}:master"

Heroku::Command.run("run", %W"./post_fork --app #{new_repo_name}")



# run = Heroku::Command::Run.new([""])
