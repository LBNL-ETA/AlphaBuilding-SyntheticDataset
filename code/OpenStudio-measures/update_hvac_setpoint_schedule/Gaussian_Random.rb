
class RandomGaussian
  def initialize(mean = 0.0, sd = 1.0, range = lambda { Kernel.rand })
    @mean, @sd, @range = mean, sd, range
    @next_pair = false
  end

  def rand
    if (@next_pair = !@next_pair)
      # Compute a pair of random values with normal distribution.
      # See http://en.wikipedia.org/wiki/Box-Muller_transform
      theta = 2 * Math::PI * @range.call
      scale = @sd * Math.sqrt(-2 * Math.log(1 - @range.call))
      @g1 = @mean + scale * Math.sin(theta)
      @g0 = @mean + scale * Math.cos(theta)
    else
      @g1
    end
  end
end


file_name = 'adfasdf.csv'

gr = RandomGaussian.new(23.72, 1.19)
gr = RandomGaussian.new(22.81, 1.87)


for i in 1..1000 do
    puts gr.rand
end
