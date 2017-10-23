module ProcessorHelper

  def render_processor_interface_label(config, form)
    label_class = 'processor_interface_label'
    label_class << ' required' if config['type'] == "text" and config["required"]
    form.label(config["label"], nil, :class => label_class)
  end

  def render_processor_interface_item(config, form)
    if config["html"] && !config["html"].blank?
      raw config["html"]
    else
      case config["type"]
      when "text"
        render_textbox(config, form)
      when "dropdown"
        render_dropdown(config, form)
      when "checkbox"
        render_checkbox(config, form)
      when "button"
        render_button(config, form)
      when "upload"
        render_upload(config, form)
      else
        logger.debug "type #{config['type']} not known"
      end
    end
  end

  def render_textbox(config, form)
    form.text_field(config["label"], required: config["required"])
  end

  def render_dropdown(config, form)
    form.select(config["label"], options_for_select(config["items"], config["default"]))
  end

  def render_checkbox(config, form)
    @label = config["label"]
    @checks = config["items"]
    @form = form
    render(:partial => "checkbox")
  end

  def render_button(config, form)
    form.submit( config["label"],
      :type => "button",
      name: config["script"],
      class: config["class"],
      style: config["style"],
      onclick: "$('#run_#{config["script"].gsub(".","_")}').val(true); $('input[name=commit]').click()"
    ) +
    hidden_field_tag( "run[#{config["script"].gsub(".","_")}]", false)
  end

  def render_upload(config, form)
    form.file_field( config['label'], multiple: true)
  end
end
