require "tabs-connector/version"
require "tabs-connector/contest"

module TabsConnector
  def session_prefix(token_name=:token)
    if ( token = params[token_name] ).present?
      return token
    end
  end

  def get_current_session
    if session_prefix
      session[session_prefix] ||= {}
      current_session = session[session_prefix]
    else
      current_session = session
    end
    current_session
  end

  def session_for_blocked_cookies
    Rails.logger.debug "---------- TabsConnector#session_for_blocked_cookies"
    Rails.logger.debug "---------- session is #{session.inspect}"
    # params[:session_id] exists if Third-party Cookies are blocked
    if params[:session_id].present? && request.cookies.empty?
      if /MemCacheStore/ =~ Rails.application.config.session_store.name
        memcached_settings = YAML.load_file("#{Rails.root}/config/memcached.yml")["defaults"]
        memcached_servers = MemCache.new(memcached_settings["servers"])
        previous_session = memcached_servers.get "rack:session:#{params[:session_id]}"
      elsif Rails.application.config.session_store == ActiveRecord::SessionStore
        previous_session_obj = ActiveRecord::SessionStore::Session.find_by_session_id(params[:session_id])
        previous_session = previous_session_obj.data if previous_session_obj
      elsif /SmartSessionStore/ =~ Rails.application.config.session_store.name
        if defined?(Mysql2Session) && Mysql2Session.class == Class
          previous_session_obj = Mysql2Session.find_session(params[:session_id])
          data = Marshal.load(Base64.decode64(previous_session_obj.data))
          previous_session = data if previous_session_obj
        end
      else
        fail "Unimplemented Session Store for TabsConnector#session_for_blocked_cookies"
      end

      if previous_session
        session.update(previous_session.to_hash)
        # set the current session's session_key to previous session's session_key
        request.session_options[:id] = params[:session_id]
      end

      Rails.logger.debug "---------- session_for_blocked_cookies session is #{previous_session.inspect}"
    end
  end

  def write_token_to_session(token_name=:token)
    if ( campaign_token = params[token_name] ).present?
      get_current_session[token_name] = campaign_token
    end
  end

  def write_client_id_to_session(id_name=:client_id)
    if ( tabs_client_id = params[id_name] ).present?
      get_current_session[id_name] = tabs_client_id
    end
  end

  def write_locale_to_session
    if ( locale = get_current_session[:tabs]['locale'] ).present?
      get_current_session[:locale] = locale
    end
  end


  def write_tabs_params_to_session
    Rails.logger.debug "---------- TabsConnector#write_tabs_params_to_session"
    # write all the params from Tabs to session
    if ( signature = params[:signature] ).present?
      get_current_session[:signature] = signature
    end

    begin
      if ( tabs_data = params[:tabs] ).present?
        get_current_session[:tabs] = ActiveSupport::JSON.decode(tabs_data)
        write_locale_to_session
      end
    rescue Exception => e
      Rails.logger.debug "---------- #{e.inspect}"
    end

    write_token_to_session

    write_client_id_to_session

    Rails.logger.debug "---------- after write, session is #{session.inspect}"
  end

  def get_tabs_data
    tabs_data = get_current_session[:tabs]
    if tabs_data
      tabs_data
    else
      {}
    end
  end

  def get_tabs_client_id(id_name=:client_id)
    get_current_session[id_name]
  end

  def get_campaign_token(debug=false, token_name=:token)
    if (debug) 
      Rails.logger.debug "---------- #{get_current_session[token_name]}"
    end
    get_current_session[token_name]
  end

  def get_simulated_time
    get_tabs_data['simulated_time']
  end

  def get_time_zone
    get_tabs_data['time_zone']
  end

end
