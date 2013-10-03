require 'aws-sdk'

image_id = ARGV[0]


config = eval File.read('./config.rb')

ec2 = AWS::EC2.new({
    :ec2_endpoint => config[:ec2_endpoint],
    :access_key_id => config[:access_key_id],
    :secret_access_key => config[:secret_access_key],
  });

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
  :instance_type => config[:instance_type] ? config[:instance_type] : 't1.micro',
  :key_name => config[:key_name],
  :security_group_ids => config[:security_group_ids],
)
inst_id = wait_running(ec2, image_id)
inst = ec2.instances[inst_id]
puts "Running " + image_id + "(" + inst.dns_name + ")"

