require 'redmine'
# require_dependency 'issue_patch_kanban'

require 'aasm'

# Patches to the Redmine core.
require 'dispatcher'

Dispatcher.to_prepare :redmine_kanban do
  require_dependency 'issue'
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
#  unless Issue.included_modules.include? RedmineKanban::IssuePatch
#    Issue.send(:include, RedmineKanban::IssuePatch)
#  end
end


Redmine::Plugin.register :redmine_kanban do
  name 'Kanban'
  author 'Eric Davis - modified by Marianna Reis - NSI/IFF'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-kanban'
  author_url 'http://www.littlestreamsoftware.com'
  description 'The Redmine Kanban plugin is used to manage issues according to the Kanban system of project management.'
  version '0.2.1.customized'

  requires_redmine :version_or_higher => '0.9.0'
  project_module :kanban do
    permission(:view_kanban, {:kanbans => [:show]})
    permission(:edit_kanban, {:kanbans => [:update, :sync]})
    permission(:manage_kanban, {})
  end

  settings(:partial => 'settings/kanban_settings',
           :default => {
             'panes' => {
               'incoming' => { 'status' => nil, 'limit' => 5},
               'backlog' => { 'status' => nil, 'limit' => 15},
               'selected' => { 'status' => nil, 'limit' => 8},
               'quick-tasks' => {'limit' => 5},
               'active' => { 'status' => nil, 'limit' => 5},
               'testing' => { 'status' => nil, 'limit' => 5},
               'finished' => {'status' => nil, 'limit' => 7},
               'canceled' => {'status' => nil, 'limit' => 7}
             }
           })

  menu(:project_menu,
       :kanban,
       {:controller => 'kanbans', :action => 'show'},
       :caption => :kanban_title,
       :param => :project_id,
       :if => Proc.new {
         User.current.allowed_to?(:view_kanban, nil, :global => true)
       })
end

