# frozen_string_literal: true

require 'time'

module Shellify
  module Utils
    def duration_to_s(duration)
      secs, _millis = duration.divmod(1000)
      mins, secs = secs.divmod(60)
      hours, mins = mins.divmod(60)
      hours = nil if hours.zero?
      [hours, mins, secs].compact.map { |s| s.to_s.rjust(2, '0') }.join(':')
    end

    def time_to_ms(time)
      time.split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b} * 1000
    end
  end
end
