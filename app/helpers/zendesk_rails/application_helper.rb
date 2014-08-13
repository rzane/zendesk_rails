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
  end
end
