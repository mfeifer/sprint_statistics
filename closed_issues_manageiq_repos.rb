ACCESS_TOKEN = "your github access token"
MILESTONE    = "title of end of sprint milestone"

require_relative 'sprint_statistics'
def stats
  @stats ||= SprintStatistics.new(ACCESS_TOKEN, MILESTONE)
end

prs = []
title = ""

stats.default_repos.each do |repo|
  milestone = stats.find_milestone_in_repo(repo)
  if milestone
    puts "Milestone found for #{repo}, collecting."
    title = milestone.title
    stats.pull_requests(repo, :milestone => milestone[:number], :state => "closed").each { |pr| prs << pr }
  else
    puts "Milestone not found for #{repo}, skipping."
    next
  end
end

File.open("closed_issues_manageiq_repos.csv", 'w') do |f|
  f.puts "Milestone Statistics for: #{title}"
  f.puts "NUMBER,TITLE,AUTHOR,ASSIGNEE,LABELS,CLOSED AT,CHANGELOGTEXT"
  prs.each do |i|
    i.changelog = "#{i.title} [(##{i.number})](#{i.pull_request.html_url})"
    f.puts "#{i.number},#{i.title},#{i.user.login},#{i.assignee && i.assignee.login},#{i.labels.collect(&:name).join(" ")},#{i.closed_at},#{i.changelog}"
  end
end
