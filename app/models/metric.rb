class Metric < ActiveRecord::Base

  scope :ordered, -> { order('created_at ASC') }

  scope :by_key, ->(key) { where(key: key).ordered.pluck(:value) }
  scope :times, -> { where(key: 'metrics_figures_total').ordered.pluck(:created_at).map { |t| t.strftime('%Y-%m-%d') } }


  # sample output
  #
  #   <user_id>:
  #     name: <str>
  #     play_count: <int>
  #     series_count: <int>
  #     series:
  #       <series_id>:
  #          title: <str>
  #          play_count: <int>
  #          talks_count: <int>
  #          talks:
  #            <talk_id>:
  #              title: <str>
  #              play_count: <int>
  #
  def self.report
    tree = {}
    users = []
    series = []
    talks = []

    User.find_each do |user|
      tree[user.id] = {
        name: [user.firstname, user.lastname] * ' ',
        slug: user.slug,
        email: user.email,
        contact_email: user.contact_email,
        series_count: user.series.count,
        series: {}
      }
      user_play_count = 0
      user.series.each do |serie|
        next if serie.talks.empty?
        tree[user.id][:series][serie.id] = {
          title: serie.title,
          slug: serie.slug,
          talk_count: serie.talks.count,
          talks: {}
        }
        serie_play_count = 0
        serie.talks.each do |talk|
          tree[user.id][:series][serie.id][:talks][talk.id] = {
            title: talk.title,
            slug: talk.slug,
            play_count: talk.play_count
          }
          if talk.play_count
            talks << [talk.play_count, talk.slug, talk.title]
          end
          serie_play_count += talk.play_count
        end
        if tree[user.id][:series][serie.id][:play_count] = serie_play_count
          series << [serie_play_count, serie.slug, serie.title]
        end
        user_play_count += serie_play_count
      end
      if tree[user.id][:play_count] = user_play_count
        users << [user_play_count, user.slug, user.firstname, user.lastname, user.email, user.contact_email ]
      end
    end

    {
      users: users.select { |e| e.first>0 }.sort_by(&:first).reverse.map { |l| l * ', ' },
      series: series.select { |e| e.first>0 }.sort_by(&:first).reverse.map { |l| l * ', ' },
      talks: talks.select { |e| e.first>0 }.sort_by(&:first).reverse.map { |l| l * ', ' },
      #tree: tree
    }
  end

end
