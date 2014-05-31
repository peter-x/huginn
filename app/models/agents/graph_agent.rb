module Agents
  class GraphAgent < Agent
    cannot_be_scheduled!

    description <<-MD
      Pipe events into the GraphAgent and visualize in a graph.
    MD

    def validate_options
        true
    end

    def default_options
      {
        'expected_receive_period_in_days' => "2",
        'group_by_path' => "series",
        'value_path' => "value",
      }
    end

    def working?
      last_receive_at && last_receive_at > options['expected_receive_period_in_days'].to_i.days.ago && !recent_error_logs?
    end

    def data
      series = {}
      received_events.pluck(:created_at, :payload).each do |t, pl|
          series_name = Utils.value_at(pl, options['group_by_path'])
          series[series_name] ||= []
          series[series_name] << [t.to_i, Utils.value_at(pl, options['value_path']).to_f]
      end
      series.each do |name, values|
          values.sort!
      end
    end
  end
end
