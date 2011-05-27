class KanbansController < ApplicationController
  unloadable
  helper :kanbans
  include KanbansHelper

  before_filter :authorize
  before_filter :setup_settings
  before_filter :find_project

  def find_project
    if params[:project_id] != nil
      find_project = Project.find(params[:project_id])
      $project = find_project.id
    else
      $project = $project
    end
    @project = Project.find($project)
  end

  def show
    @kanban = Kanban.new
  end

  def update_hitch_of_issue
    @issue = Issue.find(params[:issue_id])
    @project = Project.find($project)
    if @issue.hitch == false
      @issue.hitch = true
    else
      @issue.hitch = false
    end
    @issue.save
    render :update do |p|
      p.redirect_to :action => :show
    end
  end

  def update
    @from = params[:from]
    @to = params[:to]
    user_and_user_id

    Kanban.update_sorted_issues(@to, params[:to_issue], @to_user_id) if Kanban.kanban_issues_panes.include?(@to)
    saved = Kanban.update_issue_attributes(params[:issue_id], params[:from], params[:to], User.current, @to_user)


    @kanban = Kanban.new
    respond_to do |format|

      if saved
        format.html {
          flash[:notice] = l(:kanban_text_saved)
          redirect_to kanban_path
        }
        format.js {
          render :text => ActiveSupport::JSON.encode({
                                                       'from' => render_pane_to_js(@from, @from_user),
                                                       'to' => render_pane_to_js(@to, @to_user),
                                                       'additional_pane' => render_pane_to_js(params[:additional_pane])
                                                     })
        }
      else
        format.html {
          flash[:error] = l(:kanban_text_error_saving)
          redirect_to kanban_path
        }
        format.js {
          render({:text => ({}.to_json), :status => :bad_request})
        }
      end
    end
  end

  def sync
    Issue.sync_with_kanban

    respond_to do |format|
      format.html {
        flash[:notice] = l(:kanban_text_notice_sync)
        redirect_to kanban_path, :params => {:project_id => params[:project]}
      }
    end
  end

  private
  # Override the default authorize and add in the global option. This will allow
  # the user in if they have any roles with the correct permission
  def authorize(ctrl = params[:controller], action = params[:action])
    allowed = User.current.allowed_to?({:controller => ctrl, :action => action}, nil, { :global => true})
    #allowed ? true : deny_access
    allowed ? false : deny_access
  end

  helper_method :allowed_to_edit?
  def allowed_to_edit?
    User.current.allowed_to?({:controller => params[:controller], :action => 'update'}, nil, :global => true)
  end

  helper_method :allowed_to_manage?
  def allowed_to_manage?
    User.current.allowed_to?(:manage_kanban, nil, :global => true)
  end

  # Sets instance variables based on the parameters
  # * @from_user_id
  # * @from_user
  # * @to_user_id
  # * @to_user
  def user_and_user_id
    @from_user_id, @from_user = *extract_user_id_and_user(params[:from_user_id])
    @to_user_id, @to_user = *extract_user_id_and_user(params[:to_user_id])
  end

  def extract_user_id_and_user(user_id_param)
    user_id = nil
    user = nil

    case user_id_param
    when 'null' # Javascript nulls
      user_id = nil
      user = nil
  when '0' # Unknown user
      user_id = 0
      user = UnknownUser.instance
    else
      user_id = user_id_param
      user = User.find_by_id(user_id) # only needed for user specific views
    end

    return [user_id, user]
  end

  def setup_settings
    @settings = Setting.plugin_redmine_kanban
  end
end

