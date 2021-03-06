module KubeAutoAnalyzer
  def self.check_authn
    @log.debug("Entering the Authentication Checker")
    target = @options.target_server
    @log.debug("Checking enabled Authentication Options on #{target}")
    @results[target][:authn] = Hash.new
    @results[target]['evidence'] = Hash.new
    pods = @client.get_pods
    pods.each do |pod|
      if pod['metadata']['name'] =~ /kube-apiserver/
        @api_server = pod
      end
    end

    api_server_command_line = @api_server['spec']['containers'][0]['command']
    if api_server_command_line.index{|line| line =~ /--basic-auth-file/}
      @results[target][:authn][:basic] = true
    else
      @results[target][:authn][:basic] = false
    end

    if api_server_command_line.index{|line| line =~ /--token-auth-file/}
      @results[target][:authn][:token] = true
    else
      @results[target][:authn][:token] = false
    end

    if api_server_command_line.index{|line| line =~ /--client-ca-file/}
      @results[target][:authn][:certificate] = true
    else
      @results[target][:authn][:certificate] = false
    end

    if api_server_command_line.index{|line| line =~ /--oidc-issuer-url/}
      @results[target][:authn][:oidc] = true
    else
      @results[target][:authn][:oidc] = false
    end

    if api_server_command_line.index{|line| line =~ /--authentication-token-webhook-config-file/}
      @results[target][:authn][:webhook] = true
    else
      @results[target][:authn][:webhook] = false
    end

    if api_server_command_line.index{|line| line =~ /--requestheader-username-headers/}
      @results[target][:authn][:proxy] = true
    else
      @results[target][:authn][:proxy] = false
    end
    #Gather evidence for the API server
    @results[target]['evidence']['API Server'] = api_server_command_line
  end
end