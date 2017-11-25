module GoogleChart
  class LineChart < Base
    include Legend
    include Color
    include DataArray
    include Fills
    include Axis
    include Grid
    include Markers

    data_type :numeric_array

    def initialize(options={})
      @chart_type = "lc"
      @show_legend = false
      super(options)
    end
  end
end
