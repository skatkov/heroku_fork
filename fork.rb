require 'heroku'
require 'heroku/command/fork'
require 'heroku/command/run'
require 'github_api'

raise "Not enough args" if ARGV.length < 5
repo_owner = ARGV[0]
original_repo_name = ARGV[1]
pr_num = ARGV[2]
branch_name = ARGV[3]
github_token = ARGV[4]
new_repo_name = "#{original_repo_name}-#{pr_num}"

def read_procfile
  file = File.new("Procfile", "r")
  ret = []
  while (line = file.gets)
    type = line.split().first
    type.slice(0, type.lenght - 1)
    ret << type
  end
  return ret
end

Heroku::Command.run("fork", %W"-a #{original_repo_name} #{new_repo_name}")
# fork = Heroku::Command::Fork.new([new_repo_name], { app: original_repo_name})
# fork.index()

system "git push -f git@heroku.com:#{new_repo_name}.git #{branch_name}:master"

Heroku::Command.run("run", %W"run #{new_repo_name} ./post_script")

Heroku::Command.run("ps:scale", read_procfile.map{|x| "#{x}=1"}.join(" "))

# github = Github.new(oauth_token: github_token)
new_url = "http://#{new_repo_name}.herokuapp.com"
github = Octokit::Client.new(oauth_token: github_token)
github.add_comment("#{repo_owner}/#{original_repo_name}", pr_num, "Check this PR on heroku at #{new_url}")
