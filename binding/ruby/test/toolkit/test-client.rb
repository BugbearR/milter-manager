# Copyright (C) 2009  Yuto Hayamizu <y.hayamizu@gmail.com>
# Copyright (C) 2010-2011  Kouhei Sutou <kou@clear-code.com>
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

class TestClient < Test::Unit::TestCase
  include MilterTestUtils
  include MilterMultiProcessTestUtils

  def setup
    @client = Milter::Client.new
    setup_workers(@client)
  end

  def test_connection_spec
    @client.connection_spec = "inet:12345"
    assert_equal("inet:12345", @client.connection_spec)
  end

  def test_effective_user
    @client.effective_user = "nobody"
    assert_equal("nobody", @client.effective_user)
  end

  def test_effective_group
    @client.effective_group = "nogroup"
    assert_equal("nogroup", @client.effective_group)
  end

  def test_unix_socket_group
    @client.unix_socket_group = "nogroup"
    assert_equal("nogroup", @client.unix_socket_group)
  end

  def test_unix_socket_mode
    @client.unix_socket_mode = 0666
    assert_equal(0666, @client.unix_socket_mode)
  end

  def test_unix_socket_mode_string
    @client.unix_socket_mode = "666"
    assert_equal(0666, @client.unix_socket_mode)
  end

  def test_unix_socket_mode_invalid
    exception = ArgumentError.new("mode must be 'r', 'w' or 'x': 'Z': <a=rwZ>")
    assert_raise(exception) do
      @client.unix_socket_mode = "a=rwZ"
    end
  end

  def test_event_loop_backend
    assert_equal(Milter::Client::EVENT_LOOP_BACKEND_GLIB,
                 @client.event_loop_backend)
    @client.event_loop_backend = "libev"
    assert_equal(Milter::Client::EVENT_LOOP_BACKEND_LIBEV,
                 @client.event_loop_backend)
  end

  def test_n_workers
    assert_equal(@n_workers, @client.n_workers)
    @client.n_workers = 10
    assert_equal(10, @client.n_workers)
  end

  def test_n_workers_invalid
    assert_raise(TypeError) do
      @client.n_workers = nil
    end
    assert_raise(TypeError) do
      @client.n_workers = "foo"
    end
  end

  def test_listen
    port = 12345
    @client.connection_spec = "inet:#{port}"
    assert_raise(Errno::ECONNREFUSED) do
      TCPSocket.new("localhost", port)
    end
    @client.listen
    assert_nothing_raised do
      TCPSocket.new("localhost", port)
    end
  end

  def test_default_packet_size
    assert_equal(0, @client.default_packet_buffer_size)
    assert_equal(0, @client.create_context.packet_buffer_size)
    @client.default_packet_buffer_size = 4096
    assert_equal(4096, @client.default_packet_buffer_size)
    assert_equal(4096, @client.create_context.packet_buffer_size)
  end

  def test_maintenance_interval
    assert_equal(0, @client.maintenance_interval)
    @client.maintenance_interval = 100
    assert_equal(100, @client.maintenance_interval)
  end
end
