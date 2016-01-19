module ActiveAdmin
  module Views
    class IndexAsGraph < ActiveAdmin::Component

      def t(key)
        I18n.t('metrics.'+key)
      end

      def data
        result = [ @metrics.times.unshift('x') ]
        @metrics.pluck(:key).uniq.each do |key|
          result << @metrics.by_key(key).unshift(t(key))
        end
        result
      end

      def show_by_default
        %w( active_users_total
            new_users_total
            paying_users_total ).map { |k| t(k) }
      end

      def build(page_presenter, collection)
        @metrics = collection
        div id: 'chart'
        script "
          var chart = c3.generate({
            size: { height: 500 },
            legend: { position: 'right' },
            bindto: '#chart',
            data: {
              x: 'x',
              columns: #{data.to_json}
            },
            axis: {
              x: {
               type: 'timeseries',
                 tick: {
                   format: '%Y-%m-%d'
                 }
               }
            }
          });
          chart.hide();
          chart.show(#{show_by_default.to_json});
        ".html_safe
      end

      def self.index_name
        "graph"
      end

    end
  end
end
