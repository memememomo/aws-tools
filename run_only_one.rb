require './config.rb'

image_id = ARGV[0]
instance_type = ARGV[1]

if !instance_type
  instance_type = 't1.micro'
end


ec2 = AWS::EC2.new;

def wait_running(ec2, image_id)
  puts "Wait running..."
  inst_id = 0
  while inst_id == 0
    sleep(2)
    ec2.instances.inject({}) { |m, inst|
      if inst.image_id == image_id
        if inst.status == :running
          inst_id = inst.id
        end
      end
    }
  end
  inst_id
end

ec2.instances.inject({}) { |m, inst|
  if inst.image_id == image_id
    if inst.status == :stopped
      inst.start
      inst_id = wait_running(ec2, image_id)
      inst_running = ec2.instances[inst_id]
      puts "Start running " + image_id + "(" + inst_running.dns_name + ")"
      exit
    end

    if inst.status == :running
      puts "Already running " + image_id + "(" + inst.dns_name + ")"
      exit
    end

    if inst.status == :pending
      inst_id = wait_running(ec2, image_id)
      puts "Start running " + image_id + "(" + inst_running.dns_name + ")"
      exit
    end

    if inst.status == :stopping || inst.status == :shutting_down
      puts "Stopping old server"
      exit
    end

    # Creating when terminated
  end
}

ec2.instances.create(
  :image_id => image_id,
  :instance_type => instance_type,
)
inst_id = wait_running(ec2, image_id)
inst = ec2.instances[inst_id]
puts "Running " + image_id + "(" + inst.dns_name + ")"

