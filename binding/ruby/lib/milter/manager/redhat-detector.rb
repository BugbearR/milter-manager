# Copyright (C) 2009-2016  Kouhei Sutou <kou@clear-code.com>
#
# This library is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this library.  If not, see <http://www.gnu.org/licenses/>.

require "milter/manager/redhat-init-detector"
require "milter/manager/redhat-upstart-detector"
require "milter/manager/redhat-systemd-detector"

module Milter::Manager
  class RedHatDetector
    include Detector

    def detect
      @systemd_detector.detect
      @upstart_detector.detect
      @init_detector.detect
    end

    def apply(loader, &block)
      if @systemd_detector.enabled?
        @systemd_detector.apply(loader, &block)
      elsif @upstart_detector.enabled?
        @upstart_detector.apply(loader, &block)
      else
        @init_detector.apply(loader, &block)
      end
    end

    def run_command
      if @systemd_detector.enabled?
        @systemd_detector.command
      elsif @upstart_detector.enabled?
        @upstart_detector.command
      else
        @init_detector.command
      end
    end

    def command_options
      if @systemd_detector.enabled?
        @systemd_detector.command_options
      elsif @upstart_detector.enabled?
        @upstart_detector.command_options
      else
        @init_detector.command_options
      end
    end

    def enabled?
      @systemd_detector.enabled? or
        @upstart_detector.enabled? or
        @init_detector.enabled?
    end

    def systemd?
      @systemd_detector.enabled?
    end

    def upstart?
      @upstart_detector.enabled?
    end

    def sysv_init?
      @init_detector.enabled?
    end

    private
    def init_variables
      super
      @init_detector = RedHatInitDetector.new(@configuration, @script_name,
                                              &@connection_spec_detector)
      @upstart_detector = RedHatUpstartDetector.new(@configuration, @script_name,
                                                    &@connection_spec_detector)
      @systemd_detector = RedHatSystemdDetector.new(@configuration, @script_name,
                                                    &@connection_spec_detector)
    end
  end
end
