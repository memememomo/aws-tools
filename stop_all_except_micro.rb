require './config.rb'

ec2 = AWS::EC2.new;

ec2.instances.inject({}) { |m, inst|
  if inst.instance_type != "t1.micro" && inst.status == :running
    puts "Stopping " + inst.id
    inst.stop
  end
}
