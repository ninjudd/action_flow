
module Flow
  module Helper

    def flow_link_to(name, options={}, html_options={})
      options.merge!(flow_options)
      link_to(name, options, html_options)
    end
    
    def flow_form_tag(options={}, html_options={}, *args, &block)
      options.merge!(flow_options)
      html_options.merge!(:method => :post)
      form_tag(options, html_options, *args, &block)
    end

  private
    
    def flow_options
      {:controller=>@controller.controller_name, :action=>:next, :_fs=>@controller.context.state, :_fk=>@controller.context.key}
    end

  end # module FlowHelper
end # module Flow
