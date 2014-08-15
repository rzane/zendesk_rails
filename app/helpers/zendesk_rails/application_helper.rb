module ZendeskRails
  module ApplicationHelper
    def format_time(time)
      formatter = ZendeskRails.config.time_formatter
      if formatter.respond_to?(:call)
        instance_exec time, &formatter
      else
        time.strftime(formatter)
      end
    end

    def status_label_class(status)
      t('zendesk.tickets.status')[status.try(:to_sym)] || 'default'
    end

    def form_group_with_errors(object, field, &block)
      errors = object.errors.full_messages_for(field)
      group_classes, help = 'form-group', ''

      if errors.any?
        group_classes << ' has-error has-feedback'
        help = content_tag(:span, errors.first, class: 'help-block')
      end

      content_tag :div, class: group_classes do
        capture(errors, &block).concat(help)
      end
    end
  end
end
