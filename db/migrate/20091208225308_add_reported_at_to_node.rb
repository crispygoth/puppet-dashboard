class AddReportedAtToNode < ActiveRecord::Migration[4.2]
  def self.up
    add_column :nodes, :reported_at, :timestamp

    begin
      STDOUT.puts "-- migrate Node data"
      ms = Benchmark.ms do
        nodes = Node.all.to_a.select{|n| n.last_report.respond_to?(:report)}
        if nodes.size > 0
          pbar = ProgressBar.create(title: '   ->', total: nodes.size)
          ms = Benchmark.ms do
            nodes.each{|n| n.update_attribute(:reported_at, n.last_report.report.time); pbar.increment}
          pbar.finish
          end
        end
      end
    rescue => e
      STDERR.puts "   -> Error: " << e.message
    end
  end

  def self.down
    remove_column :nodes, :reported_at
  end
end
