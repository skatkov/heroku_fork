require 'heroku'
require 'heroku/command/fork'
require 'heroku/command/run'

@args = ARGV
raise "Not enough args" if @args.length < 3
original_repo_name = @args[0]
new_repo_name = @args[1]
branch_name = @args[2]

Heroku::Command.run("fork", %W"-a #{original_repo_name} #{new_repo_name}")
# fork = Heroku::Command::Fork.new([new_repo_name], { app: original_repo_name})
# fork.index()

system "git push -f git@heroku.com:#{new_repo_name}.git #{branch_name}:master"

Heroku::Command.run("run", %W"run #{new_repo_name} ./post_script")


# run = Heroku::Command::Run.new([""])
