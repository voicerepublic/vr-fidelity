# On console run with
#
#    Sync::Rp15.new.sync
#
# Update local copies with
#
#    curl http://re-publica.de/event/3013/json/sessions > rp15_sessions.json
#    curl http://re-publica.de/event/3013/json/speakers > rp15_speakers.json
#
module Sync
  class Rp15

    DATETIME_REGEX = /^(\d\d)\.(\d\d)\.(\d{4})\s+-\s+([\d:]+)\s+bis\s+([\d:]+)$/

    SESSIONS = 'https://re-publica.de/event/3013/json/sessions'
    SPEAKERS = 'https://re-publica.de/event/3013/json/speakers'

    STAGES = [
      'STG-1',
      'STG-2',
      'STG-3',
      'STG-4',
      'STG-5',
      'STG-6',
      'STG-7',
      'STG-8',
      'STG-9',
      'STG-10',
      'STG-11',
      'STG-J',
      'STG-T',
      'Fashiontech Lab',
      'MIZ',
      'Makerspace',
      'newthinking',
      're:publica',
      'store'
    ]

    def sync
      # data[<date>][<stage>] = [<event0>,<event1>,...]
      data = Hash.new { |h0, k0| h0[k0] = Hash.new { |h1, k1| h1[k1] = [] } }

      sessions.map do |session|
        datetime = session.datetime
        md = datetime.match(DATETIME_REGEX).to_a
        _, _day, _month, _year, _start, _end = md
        warn "%s Unknown date format: '%s'" % [session.nid, datetime] if _.nil?
        _day ||= 8
        _month ||= 5
        _year ||= 2015
        _start ||= '09:00'
        _end ||= '10:00'
        _start_hour, _start_min = _start.split(':')
        _end_hour, _end_min = _end.split(':')

        session._start, session._end = _start, _end
        session._time_window = "#{_start}&nbsp;-&nbsp;#{_end}"

        _s = DateTime.new(*[_year, _month, _day,
                            _start_hour, _start_min].map(&:to_i), 0, '+2')
        _e = DateTime.new(*[_year, _month, _day,
                            _end_hour, _end_min].map(&:to_i), 0, '+2')
        session._timestamps = [_s.utc.to_i, _e.utc.to_i] * '-'
        date = Date.new(_year.to_i, _month.to_i, _day.to_i)
        _stage = session.room || 'tbd'
        # horrible url hack
        session._url = "https://voicerepublic.com/talk/rp15-#{session.nid}"
        data[date][_stage] << session
      end

      today = Time.now.to_date
      days = data.keys.select { |d| d >= today }.sort
      days += data.keys.select { |d| d < today }.sort

      # sort
      days.each do |day|
        STAGES.each do |stage|
          data[day][stage] = data[day][stage].sort_by(&:_start)
        end
      end

      [days, STAGES, data]
    end

    def sessions
      return @sessions unless @sessions.nil?
      url = SESSIONS
      # test with local copy
      url = 'rp15_sessions.json' if File.exist?(Rails.root.join('rp15_sessions.json'))
      print 'Fetching sessions data...'
      json = open(url).read
      puts 'done.'
      data = JSON.load(json)
      @sessions = data['items'].map { |i| OpenStruct.new(i) }
      puts "Found #{@sessions.size} sessions."
      @sessions
    end

  end
end
