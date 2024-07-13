module OpenWeatherMap
    class City
        include Comparable
      attr_reader :id, :lat, :lon, :temp_k, :name

      def initialize(id:, lat:, lon:, temp_k:, name:)
        @id = id
        @lat = lat
        @lon = lon
        @temp_k = temp_k
        @name = name
      end

      def temp
        (@temp_k - 273.15).round(2)
      end

      def <=>(other)
        if self.temp < other.temp
          -1
        elsif self.temp > other.temp
          1
        else
          self.name <=> other.name
        end
      end

      def self.parse(city_data)
        id = city_data['id']
        lat = city_data['coord']['lat']
        lon = city_data['coord']['lon']
        temp_k = city_data['main']['temp']
        name = city_data['name']
        new(id: id, lat: lat, lon: lon, temp_k: temp_k, name: name)
      end

    end
  end