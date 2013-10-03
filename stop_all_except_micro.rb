require 'aws-sdk'

config = eval File.read('./config.rb')


ec2 = AWS::EC2.new({
    :ec2_endpoint => config[:ec2_endpoint],
    :access_key_id => config[:access_key_id],
    :secret_access_key => config[:secret_access_key],
  })

ec2.instances.inject({}) { |m, inst|
  if inst.instance_type != "t1.micro" && inst.status == :running
    puts "Stopping " + inst.id
    inst.stop
  end
}
