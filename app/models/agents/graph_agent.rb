require 'date'

module Agents
  class GraphAgent < Agent
    cannot_be_scheduled!

    description <<-MD
      Pipe events into the GraphAgent and visualize in a graph.
      If `time_path` is not given or not present in the event payload, use the event creation date.
    MD

    def validate_options
        true
    end

    def default_options
      {
        'expected_receive_period_in_days' => "2",
        'group_by_path' => "series",
        'value_path' => "value",
        'time_path' => "",
      }
    end

    def working?
      last_receive_at && last_receive_at > options['expected_receive_period_in_days'].to_i.days.ago && !recent_error_logs?
    end

    def data
      series = {}
      received_events.pluck(:created_at, :payload).each do |created, payload|
          series_name = Utils.value_at(payload, options['group_by_path'])
          time = created.to_time.to_i
          if options['time_path']
             explicit_time = Utils.value_at(payload, options['time_path'])
             begin
                time = DateTime.parse(explicit_time).to_time.to_i
             rescue ArgumentError, TypeError
             end
          end
          series[series_name] ||= []
          series[series_name] << [time, Utils.value_at(payload, options['value_path']).to_f]
      end
      series.each do |name, values|
          values.sort!
      end
    end
  end
end
